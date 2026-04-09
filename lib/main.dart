import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await _initMetaAppEvents();
  runApp(const MyApp());
}

/// Meta (Facebook) App Events — App ID 1363430877341928. Set the client token in
/// `android/.../values/strings.xml` and `ios/Runner/Info.plist` (Meta → App → Settings → Advanced).
Future<void> _initMetaAppEvents() async {
  if (kIsWeb) return;
  try {
    final facebookAppEvents = FacebookAppEvents();
    await facebookAppEvents.setGraphApiVersion('v24.0');
    await facebookAppEvents.activateApp();
  } catch (_) {
    // Invalid/missing client token until configured in native resources.
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
