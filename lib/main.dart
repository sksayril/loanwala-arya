import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseAnalytics();
  await MobileAds.instance.initialize();
  await _initMetaAppEvents();
  runApp(const MyApp());
}

Future<void> _initFirebaseAnalytics() async {
  if (kIsWeb) return;
  try {
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (_) {
    // Ignore startup analytics failures to avoid blocking app launch.
  }
}

/// Meta (Facebook) App Events — App ID 1622082262369468 (client token in native resources).
Future<void> _initMetaAppEvents() async {
  if (kIsWeb) return;
  try {
    final facebookAppEvents = FacebookAppEvents();
    await facebookAppEvents.setGraphApiVersion('v24.0');
    await facebookAppEvents.activateApp();
  } catch (_) {
    // Ignore Meta SDK startup failures so the app still launches.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Easy Loan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7BFA)),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7BFA),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
