import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_location_traker_app/core/app_theme.dart';
import 'package:my_location_traker_app/db_hepler/app_db_helper.dart';
import 'package:my_location_traker_app/firebase_options.dart';
import 'package:my_location_traker_app/services/backgorund_services/background_helper.dart';
import 'package:my_location_traker_app/utils/size_config.dart';
import 'package:my_location_traker_app/view/splash/splash_screen.dart';

import 'package:my_location_traker_app/view_model/common_data_viewmodel.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
    } else {
      rethrow;
    }
  }

  await TrackingDBHelper().initDB();
  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MultiProvider(
      providers: providerList(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: lightMode,
          darkTheme: darkMode,
          home: SplashScreen()),
    );
  }
}

List<SingleChildWidget> providerList() {
  return [
    ChangeNotifierProvider(create: (_) => CommonDataViewmodel()),
    ChangeNotifierProvider(create: (_) => TrackingProvider()),
  ];
}
