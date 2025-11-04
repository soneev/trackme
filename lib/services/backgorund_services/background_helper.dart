import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:geolocator/geolocator.dart';
import 'package:my_location_traker_app/db_hepler/app_db_helper.dart';

@pragma('vm:entry-point')
Future<void> initializeService() async {
  WidgetsFlutterBinding.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'tracking_channel',
    'Tracking Service',
    description: 'Used for background location tracking',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'tracking_channel',
      initialNotificationTitle: 'Tracking Service',
      initialNotificationContent: 'Idle',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = TrackingDBHelper();
  await db.initDB();

  String? activeSessionId;
  StreamSubscription<Position>? positionSub;
  Timer? retryTimer;

  StreamSubscription<ServiceStatus>? serviceStatusSub;
  bool retryPending = false;

  /// Stop current stream safely
  Future<void> stopPositionStream({bool updateNotification = true}) async {
    print('🛑 [Tracker] stopPositionStream called');
    await positionSub?.cancel();
    positionSub = null;

    retryTimer?.cancel();
    retryTimer = null;
    retryPending = false;

    await serviceStatusSub?.cancel();
    serviceStatusSub = null;

    if (updateNotification && service is AndroidServiceInstance) {
      await service.setForegroundNotificationInfo(
        title: "Tracking stopped",
        content: activeSessionId != null
            ? "Session $activeSessionId paused"
            : "Service idle",
      );
    }
  }

  /// Start new stream only if valid
  Future<void> startPositionStream() async {
    // Prevent concurrent start attempts
    if (positionSub != null) {
      print('⚠️ [Tracker] positionSub already active — skipping start.');
      return;
    }
    print('📡 [Tracker] startPositionStream invoked');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      print(
          '❌ [Tracker] Location service disabled (background). Will poll for enable.');
      await stopPositionStream(updateNotification: false);

      if (!retryPending) {
        retryPending = true;

        // Periodically check for service enablement — only one timer
        retryTimer = Timer.periodic(const Duration(seconds: 10), (t) async {
          final nowEnabled = await Geolocator.isLocationServiceEnabled();
          if (nowEnabled) {
            print(
                '✅ [Tracker] Device location enabled again — starting stream');
            retryPending = false;
            retryTimer?.cancel();
            retryTimer = null;
            await startPositionStream();
          } else {
            print('⏳ [Tracker] Still disabled — waiting');
          }
        });
      }
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print(
          '🚫 [Tracker] Permissions denied. Will poll permissions again in 10s.');
      await stopPositionStream(updateNotification: false);
      if (!retryPending) {
        retryPending = true;
        retryTimer = Timer.periodic(const Duration(seconds: 10), (t) async {
          var p = await Geolocator.checkPermission();
          if (p == LocationPermission.always ||
              p == LocationPermission.whileInUse) {
            retryPending = false;
            retryTimer?.cancel();
            retryTimer = null;
            await startPositionStream();
          } else {
            print('⏳ [Tracker] Permission still not granted.');
          }
        });
      }
      return;
    }

    // Final sanity single-call check (helps detect "disabled" that appears after start)
    try {
      // small timeout so it fails quickly if service is disabled
      await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      // Common case: location service disabled or provider off
      print('❌ [Tracker] getCurrentPosition failed: $e');
      // Schedule retry as above
      if (!retryPending) {
        retryPending = true;
        retryTimer = Timer.periodic(const Duration(seconds: 10), (t) async {
          final nowEnabled = await Geolocator.isLocationServiceEnabled();
          if (nowEnabled) {
            retryPending = false;
            retryTimer?.cancel();
            retryTimer = null;
            await startPositionStream();
          } else {
            print('⏳ [Tracker] Waiting for device location to be enabled...');
          }
        });
      }
      return;
    }

    print('[Tracker] Subscribing to position stream now.');

    final positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    );

    positionSub = positionStream.listen((pos) async {
      if (activeSessionId == null) return;

      await db.insertLocation({
        'session_id': activeSessionId,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'speed': pos.speed,
        'accuracy': pos.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
      });

      print(
          '📍 [Tracker] Inserted ${pos.latitude},${pos.longitude} for $activeSessionId');

      service.invoke('new_location', {
        'sessionId': activeSessionId,
        'lat': pos.latitude,
        'lon': pos.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Tracking active",
          content:
              "Session: $activeSessionId — ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}",
        );
      }
    }, onError: (error) async {
      print(' [Tracker] positionSub onError: $error');
      await stopPositionStream();
      // schedule a safe retry
      if (!retryPending) {
        retryPending = true;
        retryTimer = Timer(const Duration(seconds: 10), () {
          retryPending = false;
          startPositionStream();
        });
      }
    }, cancelOnError: false);

    // Optionally subscribe to service status to auto-resume when user enables system location
    serviceStatusSub ??= Geolocator.getServiceStatusStream().listen((status) {
      print(' [Tracker] ServiceStatus changed: $status');
      if (status == ServiceStatus.enabled && (positionSub == null)) {
        // If we have a recovered session id, restart
        if (activeSessionId != null) startPositionStream();
      }
    });
  }

  /// Recover previous session (if any)
  Future<void> recoverActiveSessionIfAny() async {
    try {
      final rows = await db.database.query(
        'tracking_sessions',
        where: 'end_time IS NULL OR end_time = ?',
        whereArgs: [''],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (rows.isNotEmpty) {
        final candidate = rows.first['session_id'] as String?;
        if (candidate != null && candidate.isNotEmpty) {
          activeSessionId = candidate;
          print(' [Tracker] Recovered active session: $activeSessionId');
          await startPositionStream();
        }
      }
    } catch (e) {
      print(' [Tracker] Error recovering session: $e');
    }
  }

  // 🔹 SERVICE EVENT HANDLERS
  service.on('startTracking').listen((event) async {
    final sessionId = event?['sessionId'] as String?;
    if (sessionId == null || sessionId.isEmpty) return;

    if (activeSessionId != null && activeSessionId != sessionId) {
      await stopPositionStream();
    }

    activeSessionId = sessionId;
    print('▶ [Tracker] startTracking for $activeSessionId');

    await db.updateSession(sessionId, {'end_time': null});
    await startPositionStream();

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Tracking active",
        content: "Session: $activeSessionId",
      );
    }
  });

  service.on('stopTracking').listen((event) async {
    final sessionId = event?['sessionId'] as String?;
    if (sessionId == null || sessionId.isEmpty) return;

    if (activeSessionId == sessionId) {
      print('⏹ [Tracker] stopTracking $activeSessionId');
      await stopPositionStream();
      activeSessionId = null;

      await db.updateSession(sessionId, {
        'end_time': DateTime.now().toIso8601String(),
      });

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Tracking stopped",
          content: "Session: $sessionId stopped",
        );
      }
    }
  });

  service.on('stopService').listen((_) async {
    print(' [Tracker] stopService received');
    await stopPositionStream();
    service.stopSelf();
  });

  // Try to restore previous active session
  await recoverActiveSessionIfAny();
}
