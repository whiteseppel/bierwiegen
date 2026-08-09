import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../features/home/start_screen.dart';
import '../ui/tokens.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
    });

    return MaterialApp(
      title: 'Bierwiegen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColors.primaryColor),
        useMaterial3: true,
        scaffoldBackgroundColor: CustomColors.background,
        // The zoom transition otherwise fills with colorScheme.surface, which
        // flashes behind the pages on push/pop since the scaffolds use a
        // different background.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(
              backgroundColor: CustomColors.background,
            ),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const StartScreen(),
    );
  }
}
