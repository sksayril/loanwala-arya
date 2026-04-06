import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart'
    show VoidCallback, debugPrint, kDebugMode, kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'loan_api_service.dart';

class AdHelper {
  // Google test ad unit IDs (AdMob demo).
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testNativeAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeAdUnitIdIos =
      'ca-app-pub-3940256099942544/3986624511';
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  static AdsSettings _adsSettings = const AdsSettings();
  static int _clickCount = 0;
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;

  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenLoading = false;
  static DateTime? _appOpenLoadTime;

  /// Google recommends not showing a cached app open ad older than ~4 hours.
  static const Duration _appOpenMaxCacheAge = Duration(hours: 4);

  static bool get _hasInterstitialUnitIdFromApi {
    final s = _pickFirstNonEmpty(
      _adsSettings.interstitialAdsId,
      _adsSettings.interracialAdsId,
    );
    return s != null && s.isNotEmpty;
  }

  static bool get _hasRewardedUnitIdFromApi {
    final t = _adsSettings.rewardedAdsId?.trim();
    return t != null && t.isNotEmpty;
  }

  static bool get _hasAppOpenUnitIdFromApi {
    final t = _adsSettings.appOpenAdsId?.trim();
    return t != null && t.isNotEmpty;
  }

  static bool get _hasBannerUnitIdFromApi {
    final t = _adsSettings.bannerAdsId?.trim();
    return t != null && t.isNotEmpty;
  }

  static bool get _shouldShowInterstitialBySettings =>
      _adsSettings.allAdsEnabled &&
      (_adsSettings.interstitialAdsEnabled || _hasInterstitialUnitIdFromApi) &&
      _adsSettings.interstitialAdsShowCounter > 0;

  static bool get _shouldShowAppOpenBySettings =>
      _adsSettings.allAdsEnabled &&
      (_adsSettings.appOpenAdsEnabled || _hasAppOpenUnitIdFromApi);

  static String _maskAdUnitId(String id) {
    final t = id.trim();
    if (t.length <= 20) return '***';
    return '${t.substring(0, 14)}…${t.substring(t.length - 10)}';
  }

  /// Uses the server-provided AdMob unit ID when non-empty; otherwise Google test IDs.
  /// (API IDs apply in debug and release so `GET /api/public/ads-settings` controls real units.)
  static String _effectiveUnitId(String? apiId, String testId) {
    final t = apiId?.trim();
    if (t != null && t.isNotEmpty) return t;
    return testId;
  }

  static String? _pickFirstNonEmpty(String? a, String? b) {
    final x = a?.trim();
    if (x != null && x.isNotEmpty) return x;
    final y = b?.trim();
    if (y != null && y.isNotEmpty) return y;
    return null;
  }

  static String get _rewardedAdUnitId =>
      _effectiveUnitId(_adsSettings.rewardedAdsId, _testRewardedAdUnitId);

  static String get _interstitialAdUnitId => _effectiveUnitId(
        _pickFirstNonEmpty(
          _adsSettings.interstitialAdsId,
          _adsSettings.interracialAdsId,
        ),
        _testInterstitialAdUnitId,
      );

  static String get _bannerAdUnitId =>
      _effectiveUnitId(_adsSettings.bannerAdsId, _testBannerAdUnitId);

  static String get _appOpenAdUnitId =>
      _effectiveUnitId(_adsSettings.appOpenAdsId, _testAppOpenAdUnitId);

  static String get _nativeAdUnitId {
    final String? api = _adsSettings.nativeAdsId;
    if (kIsWeb) {
      return _effectiveUnitId(api, _testNativeAdUnitIdAndroid);
    }
    try {
      if (Platform.isIOS) {
        return _effectiveUnitId(api, _testNativeAdUnitIdIos);
      }
    } catch (_) {}
    return _effectiveUnitId(api, _testNativeAdUnitIdAndroid);
  }

  static bool get shouldShowBannerBySettings =>
      _adsSettings.allAdsEnabled &&
      (_adsSettings.bannerAdsEnabled || _hasBannerUnitIdFromApi);

  /// Whether the API supplied a non-empty native AdMob unit id (`nativeAdsId`).
  static bool get _hasNativeAdUnitIdFromApi {
    final t = _adsSettings.nativeAdsId?.trim();
    return t != null && t.isNotEmpty;
  }

  /// Native ads: global ads on, and either `nativeAdsEnabled` **or** a non-empty `nativeAdsId`.
  ///
  /// Some backends send `nativeAdsId` but leave `nativeAdsEnabled` false; if a unit id is present
  /// we still load native so production IDs from `GET /api/public/ads-settings` work.
  static bool get shouldShowNativeBySettings =>
      _adsSettings.allAdsEnabled &&
      (_adsSettings.nativeAdsEnabled || _hasNativeAdUnitIdFromApi);

  /// Fixed height for [TemplateType.medium] native ads (headline + large media + CTA).
  /// Used app-wide with [NativeAdMediumCard] in `lib/widgets/native_ad_medium_card.dart`.
  static const double nativeAdMediumCardHeight = 400.0;

  static bool _isAppOpenExpired() {
    final t = _appOpenLoadTime;
    if (t == null) return true;
    return DateTime.now().difference(t) > _appOpenMaxCacheAge;
  }

  static Future<void> refreshAdsSettings() async {
    final response = await LoanApiService.fetchAdsSettings();
    // Apply whenever the endpoint returned 200 — do not drop parsed `adsSettings` if JSON `success` is false.
    if (response.httpOk) {
      _adsSettings = response.adsSettings;
    } else {
      _adsSettings = const AdsSettings();
    }
    if (kDebugMode) {
      final n = _adsSettings.nativeAdsId?.trim();
      debugPrint(
        'AdHelper.refreshAdsSettings: httpOk=${response.httpOk} '
        'nativeAdsId=${n == null || n.isEmpty ? "empty" : _maskAdUnitId(n)} '
        'nativeAdsEnabled=${_adsSettings.nativeAdsEnabled} '
        'shouldShowNative=$shouldShowNativeBySettings',
      );
    }
    if (!_shouldShowInterstitialBySettings) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialLoading = false;
    }
    if (!_shouldShowAppOpenBySettings) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
      _isAppOpenLoading = false;
    }
  }

  /// Preload an app open ad (e.g. during splash). No-op on web.
  static Future<void> preloadAppOpenAd() async {
    if (kIsWeb) return;
    if (!_shouldShowAppOpenBySettings) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
      _isAppOpenLoading = false;
      return;
    }
    if (_appOpenAd != null && !_isAppOpenExpired()) {
      return;
    }
    if (_isAppOpenExpired()) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
    }
    if (_isAppOpenLoading) return;
    _isAppOpenLoading = true;

    await AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isAppOpenLoading = false;
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _isAppOpenLoading = false;
          _appOpenAd = null;
          _appOpenLoadTime = null;
          debugPrint('App open ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows a preloaded app open ad if allowed and loaded; otherwise runs [onDone] immediately.
  static void showAppOpenAdIfReady(VoidCallback onDone) {
    if (kIsWeb) {
      onDone();
      return;
    }
    final ad = _appOpenAd;
    if (!_shouldShowAppOpenBySettings || ad == null || _isAppOpenExpired()) {
      onDone();
      return;
    }

    _appOpenAd = null;
    _appOpenLoadTime = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        preloadAppOpenAd();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        debugPrint('App open ad failed to show: ${error.message}');
        shownAd.dispose();
        preloadAppOpenAd();
        onDone();
      },
    );
    ad.show();
  }

  static Future<void> preloadInterstitialAd() async {
    if (!_shouldShowInterstitialBySettings) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialLoading = false;
      return;
    }
    if (_interstitialAd != null || _isInterstitialLoading) {
      return;
    }
    _isInterstitialLoading = true;
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialLoading = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  static Future<void> handleClickWithInterstitial({
    required VoidCallback onContinue,
  }) async {
    if (!_shouldShowInterstitialBySettings) {
      onContinue();
      return;
    }

    _clickCount += 1;
    final int showCounter = _adsSettings.interstitialAdsShowCounter;
    final bool shouldShowNow = _clickCount % showCounter == 0;

    if (!shouldShowNow) {
      onContinue();
      return;
    }

    if (_interstitialAd == null) {
      await preloadInterstitialAd();
    }

    final ad = _interstitialAd;
    if (ad == null) {
      onContinue();
      return;
    }

    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        onContinue();
        preloadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        debugPrint('Interstitial failed to show: ${error.message}');
        shownAd.dispose();
        onContinue();
        preloadInterstitialAd();
      },
    );
    ad.show();
  }

  static Future<BannerAd?> loadBannerAd() async {
    if (!shouldShowBannerBySettings) {
      return null;
    }

    final completer = Completer<BannerAd?>();
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!completer.isCompleted) {
            completer.complete(loadedAd as BannerAd);
          }
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          debugPrint('Banner ad failed to load: ${error.message}');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
      request: const AdRequest(),
    );

    await ad.load();
    return completer.future;
  }

  /// Native template ad. Returns null if global ads are off or neither `nativeAdsEnabled`
  /// nor a non-empty `nativeAdsId` is set.
  ///
  /// Use [templateType] `medium` for the larger layout (headline + main media + CTA),
  /// similar to native advanced / in-feed placements. Use `small` for compact rows.
  static Future<NativeAd?> loadNativeAd({
    TemplateType templateType = TemplateType.medium,
    Color? mainBackgroundColor,
    double? cornerRadius,
  }) async {
    if (!shouldShowNativeBySettings) {
      if (kDebugMode) {
        debugPrint(
          'AdHelper.loadNativeAd skipped: allAds=${_adsSettings.allAdsEnabled} '
          'nativeEnabled=${_adsSettings.nativeAdsEnabled} hasNativeId=$_hasNativeAdUnitIdFromApi',
        );
      }
      return null;
    }

    final String unitId = _nativeAdUnitId;
    if (kDebugMode) {
      debugPrint('AdHelper.loadNativeAd loading unitId=${_maskAdUnitId(unitId)}');
    }

    final completer = Completer<NativeAd?>();
    final nativeAd = NativeAd(
      adUnitId: unitId,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            debugPrint('AdHelper.loadNativeAd onAdLoaded');
          }
          if (!completer.isCompleted) {
            completer.complete(ad as NativeAd);
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint(
            'AdHelper.loadNativeAd onAdFailedToLoad: code=${error.code} domain=${error.domain} '
            'message=${error.message}',
          );
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: templateType,
        mainBackgroundColor: mainBackgroundColor ?? const Color(0xFFFFFFFF),
        cornerRadius: cornerRadius ?? 12,
      ),
    );

    try {
      await nativeAd.load();
    } catch (e, st) {
      debugPrint('AdHelper.loadNativeAd load() threw: $e $st');
      try {
        nativeAd.dispose();
      } catch (_) {}
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    }

    try {
      return await completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          debugPrint(
            'AdHelper.loadNativeAd: SDK did not call onAdLoaded/onAdFailedToLoad within 45s '
            '(unitId=${_maskAdUnitId(unitId)})',
          );
          nativeAd.dispose();
          return null;
        },
      );
    } catch (e, st) {
      debugPrint('AdHelper.loadNativeAd await error: $e $st');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    }
  }

  /// Load a rewarded ad. Returns null if ads are disabled by API.
  static Future<RewardedAd?> loadRewardedAd() async {
    try {
      if (!(_adsSettings.allAdsEnabled &&
          (_adsSettings.rewardedAdsEnabled || _hasRewardedUnitIdFromApi))) {
        return null;
      }

      final Completer<RewardedAd?> completer = Completer<RewardedAd?>();

      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (!completer.isCompleted) {
              completer.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: ${error.message}');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );

      return completer.future;
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      return null;
    }
  }
}
