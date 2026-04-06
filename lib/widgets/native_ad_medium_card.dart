import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_helper.dart';

/// Standard shell for [TemplateType.medium] native ads (headline + media + CTA).
///
/// Keeps one height and card styling across Loan Products and all calculator screens.
class NativeAdMediumCard extends StatelessWidget {
  const NativeAdMediumCard({super.key, required this.ad});

  final NativeAd ad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: AdHelper.nativeAdMediumCardHeight,
        width: double.infinity,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
