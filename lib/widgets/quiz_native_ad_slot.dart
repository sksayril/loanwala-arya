import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_helper.dart';

/// Native ad for quiz flows. Pass [reloadKey] (e.g. current step index) so a
/// fresh ad loads whenever the question changes.
enum QuizNativeAdVariant {
  /// Light card on grey background (loan application quiz).
  light,

  /// Dark navy theme (financial check-in quiz).
  dark,
}

class QuizNativeAdSlot extends StatefulWidget {
  const QuizNativeAdSlot({
    super.key,
    required this.reloadKey,
    this.variant = QuizNativeAdVariant.light,
  });

  /// Change when the quiz step changes to load a new native ad.
  final int reloadKey;
  final QuizNativeAdVariant variant;

  @override
  State<QuizNativeAdSlot> createState() => _QuizNativeAdSlotState();
}

class _QuizNativeAdSlotState extends State<QuizNativeAdSlot> {
  /// Medium template; slightly shorter than default to save vertical space.
  static const double _adHeight = 270;

  NativeAd? _nativeAd;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant QuizNativeAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadKey != widget.reloadKey ||
        oldWidget.variant != widget.variant) {
      _disposeAd();
      if (mounted) {
        setState(() {});
      }
      _loadAd();
    }
  }

  void _disposeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _loaded = false;
    _failed = false;
  }

  NativeTemplateStyle _templateStyle() {
    switch (widget.variant) {
      case QuizNativeAdVariant.light:
        return NativeTemplateStyle(
          templateType: TemplateType.medium,
          cornerRadius: 12,
          mainBackgroundColor: Colors.white,
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF1A1A1A),
            size: 14,
            style: NativeTemplateFontStyle.bold,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF6B7280),
            size: 12,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF9CA3AF),
            size: 11,
          ),
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF2E7BFA),
            size: 13,
            style: NativeTemplateFontStyle.bold,
          ),
        );
      case QuizNativeAdVariant.dark:
        return NativeTemplateStyle(
          templateType: TemplateType.medium,
          cornerRadius: 12,
          mainBackgroundColor: const Color(0xFF1E2D45),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            size: 14,
            style: NativeTemplateFontStyle.bold,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Color(0xFFB8C5D6),
            size: 12,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: Color(0xFF8A9BAE),
            size: 11,
          ),
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF0F172A),
            backgroundColor: const Color(0xFF10B981),
            size: 13,
            style: NativeTemplateFontStyle.bold,
          ),
        );
    }
  }

  void _loadAd() {
    if (kIsWeb) return;

    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      nativeTemplateStyle: _templateStyle(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _loaded = false;
              _failed = true;
            });
          }
        },
      ),
      request: const AdRequest(),
      nativeAdOptions: NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.landscape,
        adChoicesPlacement: AdChoicesPlacement.bottomRightCorner,
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }
    if (_failed) {
      return const SizedBox.shrink();
    }

    final borderColor = widget.variant == QuizNativeAdVariant.light
        ? const Color(0xFFE5E7EB)
        : Colors.white.withValues(alpha: 0.14);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _loaded && _nativeAd != null
            ? Container(
                key: ValueKey<int>(widget.reloadKey),
                width: double.infinity,
                height: _adHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: widget.variant == QuizNativeAdVariant.light
                            ? 0.06
                            : 0.25,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: AdWidget(ad: _nativeAd!),
              )
            : SizedBox(
                key: const ValueKey<String>('loading'),
                height: 88,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: widget.variant == QuizNativeAdVariant.light
                          ? const Color(0xFF2E7BFA)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
