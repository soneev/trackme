import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_location_traker_app/utils/app_images.dart';
import 'package:my_location_traker_app/utils/utils_funtions.dart';
import 'package:my_location_traker_app/view/common/custom_image.dart';
import 'package:my_location_traker_app/view/common/no_data_found.dart';
import 'package:my_location_traker_app/view/home/active_session_map/active_session_map.dart';
import 'package:my_location_traker_app/view/home/widget/session_sheet.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeData extends StatefulWidget {
  const HomeData({super.key});

  @override
  State<HomeData> createState() => _HomeDataState();
}

class _HomeDataState extends State<HomeData> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final trackVm = Provider.of<TrackingProvider>(context, listen: false);
      trackVm.setSessionId(null);
      await trackVm.checkLocationPermission().then((value) {
        if (value) {
          log("permission added");
        } else {
          toast(
              "❌ Unable to fetch location (possibly denied) please add permssion to continue",
              // ignore: use_build_context_synchronously
              context,
              isError: true);
          trackVm.checkLocationPermission();
        }
      });

      // Load sessions first from local DB
      await trackVm.loadSessionsWithLocations();

      // Then start automatic sync listener
      trackVm.startAutoSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          color: Colors.white,
          height: double.maxFinite,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenHeight * 0.6,
          child: Consumer<TrackingProvider>(builder: (context, tvm, _) {
            if (tvm.currentSessionId != null) {
              return ActiveSessionMapScreen(
                sessionId: tvm.currentSessionId!,
              );
            } else {
              return NoDataFOund();
            }
          }),
        ),
        TrackingSessionSheet()
      ],
    );
  }
}
