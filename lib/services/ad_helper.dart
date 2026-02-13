import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  /// Load a rewarded ad
  /// Returns null if ads are not configured
  static Future<RewardedAd?> loadRewardedAd() async {
    try {
      // Rewarded ad unit ID
      const String rewardedAdUnitId = 'ca-app-pub-3922595204055302/4671801079';
      
      final Completer<RewardedAd?> completer = Completer<RewardedAd?>();
      
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print('Rewarded ad loaded successfully');
            if (!completer.isCompleted) {
              completer.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: ${error.message}');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );
      
      return completer.future;
    } catch (e) {
      print('Error loading rewarded ad: $e');
      return null;
    }
  }
}
