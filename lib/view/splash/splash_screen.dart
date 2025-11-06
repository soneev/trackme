import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_location_traker_app/utils/size_config.dart';
import 'package:my_location_traker_app/view/common/custom_button.dart';
import 'package:my_location_traker_app/view/common/custom_image.dart';
import 'package:my_location_traker_app/view/home/home_screen.dart';
import 'package:my_location_traker_app/view/splash/widget/icon_card.dart';
import 'package:my_location_traker_app/utils/app_images.dart';
import 'package:my_location_traker_app/view_model/common_data_viewmodel.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final trackVm = Provider.of<TrackingProvider>(context, listen: false);
      final provider = context.read<CommonDataViewmodel>();
      provider.startContinuousAnimation();

      await trackVm.restoreActiveSession().then((value) {
        if (value) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          log("no active trip found");
        }
      });

      // Load sessions first from local DB
      await trackVm.loadSessionsWithLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<CommonDataViewmodel>(builder: (ctx, cdv, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: IconCard(
                color: Theme.of(context).colorScheme.primary,
                child: IconCard(
                  color: Theme.of(context).colorScheme.secondary,
                  child: IconCard(
                    color: Theme.of(context).colorScheme.tertiary,
                    child: ClipOval(
                      child: CustomPngImage(
                        imageName: AppImages.logo,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Consumer<TrackingProvider>(builder: (ctx, trk, _) {
          if (trk.isFetching) {
            return Container(
              height: 45,
              width: SizeConfig.screenWidth / 3,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color(0xFF3E0066),
                          const Color(0xFF1B1F3B),
                        ]
                      : [
                          const Color(0xFF6D0EB5),
                          const Color(0xFF4059F1),
                        ],
                ),
              ),
              child: Center(
                  child: const CupertinoActivityIndicator(color: Colors.white)),
            );
          } else {
            return CustomButton(
              isGradient: true,
              color: Theme.of(context).colorScheme.primary,
              width: SizeConfig.screenWidth / 3,
              text: "Go",
              onPressed: () {
                if (!trk.isFetching) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
                } else {
                  log("waiting");
                }

                // Provider.of<CommonDataViewmodel>(context, listen: false)
                //     .stopAnimation();
              },
            );
          }
        }),
      ),
    );
  }
}
