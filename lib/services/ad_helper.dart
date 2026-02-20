import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Rewarded ad unit ID
  static const String rewardedAdUnitId = 'ca-app-pub-3922595204055302/6968501787';
  
  /// Load a rewarded ad
  /// Returns null if ads are not configured
  static Future<RewardedAd?> loadRewardedAd() async {
    try {
      final Completer<RewardedAd?> completer = Completer<RewardedAd?>();
      
      RewardedAd.load(
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
  
  /// Show a rewarded ad with callbacks
  /// Returns true if ad was shown successfully, false otherwise
  static Future<bool> showRewardedAd({
    required Function() onAdDismissed,
    Function()? onAdFailedToShow,
    Function()? onUserEarnedReward,
  }) async {
    try {
      final RewardedAd? rewardedAd = await loadRewardedAd();
      
      if (rewardedAd == null) {
        print('Rewarded ad not available');
        if (onAdFailedToShow != null) {
          onAdFailedToShow();
        }
        return false;
      }
      
      // Set full screen content callback
      rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('Rewarded ad dismissed');
          ad.dispose();
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Rewarded ad failed to show: ${error.message}');
          ad.dispose();
          if (onAdFailedToShow != null) {
            onAdFailedToShow();
          }
        },
        onAdShowedFullScreenContent: (ad) {
          print('Rewarded ad showed full screen content');
        },
      );
      
      // Set rewarded ad callback
      rewardedAd.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          if (onUserEarnedReward != null) {
            onUserEarnedReward();
          }
        },
      );
      
      return true;
    } catch (e) {
      print('Error showing rewarded ad: $e');
      if (onAdFailedToShow != null) {
        onAdFailedToShow();
      }
      return false;
    }
  }
}
