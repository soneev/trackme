import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:my_location_traker_app/utils/utils_funtions.dart';
import 'package:my_location_traker_app/view/common/custom_app_bar.dart';

import 'package:my_location_traker_app/view/home/widget/home_data.dart';

import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackVm = Provider.of<TrackingProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
        leading: null,
        title: 'Home',
        bgcolor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: HomeData(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<TrackingProvider>(builder: (context, tvm, _) {
          return InkWell(
            onTap: () async {
              UtilFunctions.loaderPopup(context);
              bool? success = await trackVm.checkLocationPermission();
              if (success) {
                final service = FlutterBackgroundService();
                if (!tvm.isTracking!) {
                  try {
                    await trackVm.startSession();

                    bool isRunning = await service.isRunning();

                    if (!isRunning) {
                      await service.startService();
                      print('🚀 Background service started');
                    }

// Then send command
                    service.invoke(
                        'startTracking', {'sessionId': tvm.currentSessionId});

                    await trackVm.loadSessionsWithLocations().then((value) {
                      if (value) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        toast("Session started", context, isError: false);
                      } else {}
                    });
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    // ignore: use_build_context_synchronously
                    toast(e.toString(), context, isError: true);
                  }
                } else {
                  bool isRunning = await service.isRunning();
                  if (isRunning) {
                    service.invoke(
                        'stopTracking', {'sessionId': tvm.currentSessionId});
                    print('🛑 Background service stop command sent');
                  }
                  await trackVm.stopSession(
                    sessionId: tvm.currentSessionId,
                  );

                  if (tvm.currentSessionId == null) return;

                  await trackVm.loadSessionsWithLocations().then((value) {
                    if (value) {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      toast("Session Ended", context, isError: false);
                      trackVm.setSessionId(null);
                    } else {}
                  });
                }
              } else {
                print("location data not available");
              }

              // Add a static location (example: Kochi)
            },
            child: Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: !tvm.isTracking!
                      ? [
                          Colors.teal.shade400,
                          Colors.teal.shade700,
                        ]
                      : [
                          Colors.amber.shade400,
                          Colors.amber.shade700,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer background inside the circular button
                  ClipOval(
                    child: Shimmer.fromColors(
                      baseColor: !tvm.isTracking!
                          ? Colors.amber.shade50
                          : Colors.teal.shade50,
                      highlightColor: !tvm.isTracking!
                          ? Colors.amber.shade200
                          : Colors.teal.shade100,
                      period: const Duration(seconds: 3),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          // gradient: LinearGradient(
                          //   colors: [Colors.teal.shade400, Colors.teal.shade700],
                          //   begin: Alignment.topLeft,
                          //   end: Alignment.bottomRight,
                          // ),
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Foreground text (always visible)
                  Text(
                    !tvm.isTracking! ? "Start" : "End",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
