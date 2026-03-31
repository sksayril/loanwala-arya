import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  /// Load a rewarded ad
  /// Returns null if ads are not configured
  static Future<RewardedAd?> loadRewardedAd() async {
    try {
      // Replace with your actual rewarded ad unit ID
      const String rewardedAdUnitId = 'ca-app-pub-3922595204055302/7587033593'; // Production rewarded ad unit ID
      
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

  /// Show a rewarded ad and execute callbacks
  static void showRewardedAd(RewardedAd ad, {
    required VoidCallback onRewardEarned,
    required VoidCallback onAdDismissed,
  }) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Ad failed to show: $error');
        ad.dispose();
        onAdDismissed();
      },
    );
    ad.show(onUserEarnedReward: (ad, reward) {
      onRewardEarned();
    });
  }

  /// Helper to show ad and then navigate/complete action
  static Future<void> showRewardedAdWithNavigation(BuildContext context, {required VoidCallback onComplete}) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final ad = await loadRewardedAd();
      if (context.mounted) {
        Navigator.pop(context); // Pop loading dialog
      }

      if (ad != null) {
        showRewardedAd(
          ad,
          onRewardEarned: () {
            if (context.mounted) {
              onComplete();
            }
          },
          onAdDismissed: () {
            // Optionally could just complete anyway to avoid getting stuck
            // Users usually want to proceed even if they cancel if the reward is minor
            // But if it's "Rewarded", usually it's required.
            // Let's allow proceeding on dismissal too to prevent user frustration
            // if (context.mounted) onComplete(); 
          },
        );
      } else {
        // Fallback if ad fails
        if (context.mounted) {
          onComplete();
        }
      }
    } catch (e) {
      print('Error showing rewarded ad: $e');
      if (context.mounted) {
        Navigator.pop(context); // Pop loading dialog
        onComplete();
      }
    }
  }
}
