import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_location_traker_app/db_hepler/app_db_helper.dart';
import 'package:my_location_traker_app/model/local_response.dart';
import 'package:my_location_traker_app/services/location_services/location_helper.dart';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class TrackingProvider with ChangeNotifier {
  final TrackingDBHelper _dbHelper = TrackingDBHelper();
  bool _dbInitialized = false;
  Future<void> initDB() async {
    if (_dbInitialized) return; // prevents re-init
    await _dbHelper.initDB();
    _dbInitialized = true;
  }

  Timer? _refreshTimer;

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  final bool _isSessionLoading = false;
  final bool _isLocationLoading = false;

  bool get isSessionLoading => _isSessionLoading;
  bool get isLocationLoading => _isLocationLoading;
  List<LatLng> currentPath = [];

  bool _isTrackin = false;
  bool get isTracking => _isTrackin;
  // ➕ Start new session
  Future<void> startSession() async {
    final sessionId = const Uuid().v4();
    final startTime = DateTime.now().toIso8601String();
    await initDB();
    _currentSessionId = sessionId;

    await _dbHelper.insertSession({
      'session_id': _currentSessionId,
      'start_time': startTime,
      'end_time': null,
      'synced': 0,
    });

    _isTrackin = true;
    currentPath.clear();

    notifyListeners();

    // return sessionId;
    // await addLocation(lat: lat, lon: lon); // example Koch
  }

  Future<void> stopSession({
    String? sessionId,
  }) async {
    if (sessionId != null) {
      await _dbHelper.updateSession(sessionId, {
        'end_time': DateTime.now().toIso8601String(),
      });
      // await addLocation(lat: lat, lon: lon);
    }
    _isTrackin = false;

    notifyListeners();
  }

  setSessionId(String? id) {
    _currentSessionId = id;
    notifyListeners();
  }

  /* Future<void> loadSessionLocations({String? id}) async {
    if (id == null) return;

    final rows = await _dbHelper.database.query(
      'locations',
      where: 'session_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );

    currentPath = rows.map((r) {
      return LatLng(
        (r['latitude'] as num).toDouble(),
        (r['longitude'] as num).toDouble(),
      );
    }).toList();

    notifyListeners();
    //  Print each location in provider.....................
    for (final loc in rows) {
      final lat = (loc['latitude'] as num).toDouble();
      final lon = (loc['longitude'] as num).toDouble();
      final time = loc['timestamp'] ?? 'unknown';
      print('📍 Location -> lat: $lat, lon: $lon, time: $time');
    }

    print(
        '✅ Total locations loaded for session $currentSessionId: ${currentPath.length}');
  }*/

  Future<void> loadSessionLocations({String? id}) async {
    if (id == null) return;

    final rows = await _dbHelper.database.query(
      'locations',
      where: 'session_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );

    final newPath = rows.map((r) {
      return LatLng(
        (r['latitude'] as num).toDouble(),
        (r['longitude'] as num).toDouble(),
      );
    }).toList();

    // Only notify if list changed
    if (newPath.length != currentPath.length) {
      currentPath = newPath;
      notifyListeners();
      log("✅ Updated polyline with ${newPath.length} points");
    }
  }

  /// Optional periodic refresh (when app in foreground)
  Future<void> refreshLivePath() async {
    await loadSessionLocations();
  }

  Future<bool> deleteSession(String sessionId) async {
    try {
      await _dbHelper.deleteSession(sessionId);

      _sessionsdata.removeWhere((s) => s.sessionId == sessionId);

      notifyListeners();
      return true; // ✅ indicate success
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting session: $e");
      }

      return false; // ❌ indicate failure
    }
  }

  // Future<void> restoreActiveSession() async {
  //   final activeSession = await _dbHelper.getActiveSession();
  //   if (activeSession != null) {
  //     _currentSessionId = activeSession['session_id'];
  //     _isTrackin = true;
  //     print('♻️ Restored active session: $currentSessionId');
  //   } else {
  //     _currentSessionId = null;
  //     _isTrackin = false;
  //     print('ℹ️ No active session found');
  //   }
  //   notifyListeners();
  // }
  bool _isFetchingId = false;
  bool get isFetching => _isFetchingId;
  Future<bool> restoreActiveSession() async {
    _isFetchingId = true;
    notifyListeners();
    final activeSession = await _dbHelper.getActiveSession();

    if (activeSession != null) {
      _currentSessionId = activeSession['session_id'];
      _isFetchingId = false;
      _isTrackin = true;
      print('♻️ Restored active session: $_currentSessionId');
      notifyListeners();
      return true; // ✅ Active session found
    } else {
      _currentSessionId = null;
      _isTrackin = false;
      _isFetchingId = false;
      print('ℹ️ No active session found');
      notifyListeners();
      return false; // ❌ No active session
    }
  }

  final List<SessionModel> _sessionsdata = [];
  bool _isLoading = false;

  List<SessionModel> get sessionsdata => _sessionsdata;
  bool get isLoading => _isLoading;
  Future<bool> loadSessionsWithLocations() async {
    await initDB();
    _isLoading = true;
    notifyListeners();

    try {
      final rawData = await _dbHelper.getSessionsWithLocationsRaw();

      final sessionsList = rawData.map((sessionMap) {
        final locationsRaw = sessionMap['locations'] as List<dynamic>? ?? [];

        final locationList = locationsRaw
            .map((locMap) => LocationModel.fromMap(locMap))
            .toList();

        return SessionModel.fromMap(sessionMap).copyWith(
          locations: locationList,
        );
      }).toList();

      _sessionsdata
        ..clear()
        ..addAll(sessionsList);
      _isLoading = false;
      notifyListeners();

      print("✅ Loaded ${_sessionsdata.length} sessions with locations");
      return true; // ✅ Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("❌ Error loading sessions: $e");
      return false; // ❌ Failed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //--------------get check location permissions---------------

  Future<bool> checkLocationPermission() async {
    try {
      final position = await LocationHelper.getCurrentLocation();
      if (position != null) {
        print('✅ Location permission granted');
        notifyListeners();
        return true;
      } else {
        print('❌ Unable to fetch location (possibly denied)');
        return false;
      }
    } catch (e) {
      print('⚠️ Location permission error: $e');
      notifyListeners();
      return false;
    }
  }

  void startAutoRefresh(String? id) {
    stopAutoRefresh(); // prevent duplicates
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!_isTrackin) {
        stopAutoRefresh();
        log("Provider lat list paused");
        return;
      }

      await loadSessionLocations(id: currentSessionId ?? id);
      log("Provider lat list restored");
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    notifyListeners();
  }

  //------------firebase--- auto sync----------------------

  Future<bool> syncUnsyncedSessions() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    final hasInternet = connectivityResults.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    if (!hasInternet) {
      print("🚫 No internet. Sync postponed.");
      return false;
    }

    print("🌐 Internet active — syncing unsynced sessions...");
    final firestore = FirebaseFirestore.instance;
    bool allSynced = true;

    for (final session in _sessionsdata) {
      if (session.synced == false) {
        try {
          final sessionRef =
              firestore.collection('sessions').doc(session.sessionId);

          await sessionRef.set({
            'sessionId': session.sessionId,
            'startTime': session.startTime,
            'endTime': session.endTime,
            'distance': session.distance,
            'createdAt': FieldValue.serverTimestamp(),
            'synced': session.synced == false ? true : true,
          });

          final locs = session.locations ?? [];
          for (final loc in locs) {
            await sessionRef.collection('locations').add({
              'latitude': loc.latitude,
              'longitude': loc.longitude,
              'speed': loc.speed,
              'accuracy': loc.accuracy,
              'timestamp': loc.timestamp,
            });
          }
          await _dbHelper.markSynced(session.sessionId ?? "");
          await _dbHelper.updateSessionSynced(session.sessionId ?? '');
          session.copyWith(synced: true);

          print("✅ Synced session ${session.sessionId}");
        } catch (e) {
          allSynced = false;
          print("❌ Failed to sync session ${session.sessionId}: $e");
        }
      }
    }
    try {
      final syncedSessions =
          await _dbHelper.getAllSyncedSessions(); // ← add this helper
      print("📦 Synced Sessions from DB (${syncedSessions.length}):");
      for (final s in syncedSessions) {
        print(
            "  ➤ ID: ${s.sessionId}, Distance: ${s.distance}, Start: ${s.startTime}, End: ${s.endTime}  ${s.synced}");
      }
    } catch (e) {
      print("⚠️ Error fetching synced sessions: $e");
    }

    notifyListeners();

    if (allSynced) {
      print("🎉 All sessions synced successfully!");
    } else {
      print("⚠️ Some sessions failed to sync.");
    }

    return allSynced;
  }

// auto sync Stream call----------------

  bool _isSyncing = false;
  Timer? _autoSyncTimer;

  void startAutoSync() {
    _autoSyncTimer?.cancel();

    if (_isTrackin == true) {
      stopAutoSync();
      print(">>>>/ Background tracking active — Timer not started for now.");

      return;
    } else {
      _autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
        await _checkAndSync();
      });

      Connectivity().onConnectivityChanged.listen((statuses) async {
        await _checkAndSync();
      });
    }
  }

  Future<void> _checkAndSync() async {
    final connectivity = await Connectivity().checkConnectivity();

    // Handle multiple results (new Connectivity package returns list)
    bool hasInternet = connectivity.any((c) =>
        c == ConnectivityResult.mobile ||
        c == ConnectivityResult.wifi ||
        c == ConnectivityResult.ethernet);

    if (!hasInternet) {
      print("🚫 No internet — skipping sync.");
      return;
    }

    if (_isTrackin == true) {
      print("📍 Background tracking active — skipping sync for now.");
      return;
    }

    if (_isSyncing) {
      print("⏳ Sync already in progress — waiting...");
      return;
    }

    _isSyncing = true;

    print("🌐 Internet active — syncing data...");
    final success = await syncUnsyncedSessions();

    if (success) {
      notifyListeners(); // ✅ only if data changed

      // Fluttertoast.showToast(
      //   msg: "✅ All sessions synced successfully!",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.TOP,
      // );
    } else {
      Fluttertoast.showToast(
          msg: "⚠️ Some sessions failed to sync.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP);
    }

    _isSyncing = false;
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    print("🛑 firebase Auto sync stopped.");
  }

  /// get location distance
  ///
  ///
  String? startAddress;
  String? endAddress;
  double? distanceKm;

  Future<bool> fetchRouteInfo({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      var distance =
          Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;

      distanceKm = convertMilesToKm("$distance");

      final startUrl =
          'https://nominatim.openstreetmap.org/reverse?lat=$startLat&lon=$startLng&format=json';
      final endUrl =
          'https://nominatim.openstreetmap.org/reverse?lat=$endLat&lon=$endLng&format=json';

      final startRes = await http
          .get(Uri.parse(startUrl), headers: {'User-Agent': 'FlutterApp'});
      final endRes = await http
          .get(Uri.parse(endUrl), headers: {'User-Agent': 'FlutterApp'});

      if (startRes.statusCode == 200 && endRes.statusCode == 200) {
        final startData = json.decode(startRes.body);
        final endData = json.decode(endRes.body);

        startAddress = startData['display_name'] ?? 'Unknown location';
        endAddress = endData['display_name'] ?? 'Unknown location';
        print('📏 Calculated Distance: ${distanceKm?.toStringAsFixed(2)} km');
      } else {
        startAddress = 'Failed to fetch';
        endAddress = 'Failed to fetch';
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ Error fetching route info: $e");
      startAddress = 'Error';
      endAddress = 'Error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  double convertMilesToKm(String? val) {
    String input = val ?? "";
    if (input.toLowerCase().endsWith(" mi")) {
      input = input.substring(0, input.length - 3).trim();
    }

    double miles = double.tryParse(input) ?? 0.0;
    double km = miles * 1.60934;
    return (km * 2).round() / 2;
  }

  clearPlaces() {
    startAddress = null;
    endAddress = null;
    distanceKm = null;
    notifyListeners();
  }
}
