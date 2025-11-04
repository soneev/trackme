import 'package:flutter/material.dart';
import 'package:my_location_traker_app/utils/size_config.dart';
import 'package:my_location_traker_app/view/common/custom_button.dart';
import 'package:my_location_traker_app/view/common/custom_image.dart';
import 'package:my_location_traker_app/view/home/home_screen.dart';
import 'package:my_location_traker_app/view/splash/widget/icon_card.dart';
import 'package:my_location_traker_app/utils/app_images.dart';
import 'package:my_location_traker_app/view_model/common_data_viewmodel.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final provider = context.read<CommonDataViewmodel>();
      // provider.startContinuousAnimation();
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
                    child: Center(
                      child: CustomPngImage(
                        imageName: AppImages.gpsIc,
                        height: 60,
                        width: 60,
                        color: Colors.teal.shade400,
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
        child: CustomButton(
          isGradient: true,
          color: Theme.of(context).colorScheme.primary,
          width: SizeConfig.screenWidth / 3,
          text: "Go",
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomeScreen()));
            // Provider.of<CommonDataViewmodel>(context, listen: false)
            //     .stopAnimation();
          },
        ),
      ),
    );
  }
}
