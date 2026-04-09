import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  /// AdMob unit IDs (production).
  static const String nativeAdUnitId =
      'ca-app-pub-3922595204055302/3907936557';
  static const String interstitialAdUnitId =
      'ca-app-pub-3922595204055302/1045534720';
  static const String rewardedAdUnitId =
      'ca-app-pub-3922595204055302/7587033593';

  /// Load an interstitial ad. Returns null on failure or unsupported platforms.
  static Future<InterstitialAd?> loadInterstitialAd() async {
    if (kIsWeb) return null;
    try {
      final Completer<InterstitialAd?> completer = Completer<InterstitialAd?>();

      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );

      return completer.future;
    } catch (_) {
      return null;
    }
  }

  /// Shows a loading indicator, loads an interstitial, displays it, then runs
  /// [onComplete] after the ad is dismissed or if load/show fails.
  static Future<void> showInterstitialThen(
    BuildContext context, {
    required VoidCallback onComplete,
  }) async {
    if (kIsWeb || !context.mounted) {
      onComplete();
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final ad = await loadInterstitialAd();
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (ad != null) {
        var completed = false;
        void finish() {
          if (completed) return;
          completed = true;
          onComplete();
        }

        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            finish();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            finish();
          },
        );
        try {
          await ad.show();
        } catch (_) {
          ad.dispose();
          finish();
        }
      } else {
        onComplete();
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      onComplete();
    }
  }

  /// Load a rewarded ad
  /// Returns null if ads are not configured
  static Future<RewardedAd?> loadRewardedAd() async {
    try {
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

  /// Loads and shows a rewarded ad, then runs [onComplete] when the fullscreen
  /// ad is dismissed or if load/show fails. Use between quiz steps so the user
  /// does not advance until the ad closes.
  static Future<void> showRewardedThen(
    BuildContext context, {
    required VoidCallback onComplete,
  }) async {
    if (kIsWeb || !context.mounted) {
      onComplete();
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final ad = await loadRewardedAd();
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (ad == null) {
        onComplete();
        return;
      }

      var completed = false;
      void finish() {
        if (completed) return;
        completed = true;
        onComplete();
      }

      showRewardedAd(
        ad,
        onRewardEarned: () {},
        onAdDismissed: finish,
      );
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      onComplete();
    }
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
