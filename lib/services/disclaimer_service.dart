import 'package:shared_preferences/shared_preferences.dart';

const String _kDisclaimerAccepted = 'disclaimer_accepted_v1';

class DisclaimerService {
  DisclaimerService._();

  static Future<bool> hasAcceptedDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDisclaimerAccepted) ?? false;
  }

  static Future<void> setDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDisclaimerAccepted, true);
  }
}
