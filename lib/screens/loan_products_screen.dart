import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_helper.dart';
import '../widgets/native_ad_medium_card.dart';
import 'customize_loan_screen.dart';

/// Full list of loan products (matches home grid + featured flow in mockups).
class LoanProductsScreen extends StatefulWidget {
  const LoanProductsScreen({super.key});

  @override
  State<LoanProductsScreen> createState() => _LoanProductsScreenState();
}

class _LoanProductsScreenState extends State<LoanProductsScreen> {
  NativeAd? _nativeAd;

  static const String _rateLabel = 'Get 8.4% p.a.';

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  Future<void> _loadNativeAd() async {
    await AdHelper.refreshAdsSettings();
    final ad = await AdHelper.loadNativeAd();
    if (!mounted) return;
    setState(() => _nativeAd = ad);
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _openCustomize({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    AdHelper.handleClickWithInterstitial(
      onContinue: () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => CustomizeLoanScreen(
              loanType: title,
              loanIcon: icon,
              loanColor: color,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Loan Products',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FeaturedLoanCard(
                title: 'Home Loan',
                rateText: _rateLabel,
                icon: Icons.home_rounded,
                color: Colors.orange,
                onTap: () => _openCustomize(
                  title: 'Home Loan',
                  icon: Icons.home_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _GridLoanTile(
                    title: 'Car Loan',
                    subtitle: 'Quick approval',
                    icon: Icons.directions_car_rounded,
                    color: Colors.redAccent,
                    onTap: () => _openCustomize(
                      title: 'Car Loan',
                      icon: Icons.directions_car_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                  _GridLoanTile(
                    title: 'Gold Loan',
                    subtitle: 'Against gold',
                    icon: Icons.emoji_events_rounded,
                    color: Colors.amber.shade700,
                    onTap: () => _openCustomize(
                      title: 'Gold Loan',
                      icon: Icons.emoji_events_rounded,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  _GridLoanTile(
                    title: 'Business Loan',
                    subtitle: 'Grow your business',
                    icon: Icons.business_center_rounded,
                    color: Colors.purple,
                    onTap: () => _openCustomize(
                      title: 'Business Loan',
                      icon: Icons.business_center_rounded,
                      color: Colors.purple,
                    ),
                  ),
                  _GridLoanTile(
                    title: 'Education Loan',
                    subtitle: 'Study abroad',
                    icon: Icons.school_rounded,
                    color: Colors.amber,
                    onTap: () => _openCustomize(
                      title: 'Education Loan',
                      icon: Icons.school_rounded,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FeaturedLoanCard(
                title: 'Personal Loan',
                rateText: _rateLabel,
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.blue,
                onTap: () => _openCustomize(
                  title: 'Personal Loan',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.blue,
                ),
              ),
              if (_nativeAd != null) ...[
                const SizedBox(height: 20),
                NativeAdMediumCard(ad: _nativeAd!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedLoanCard extends StatelessWidget {
  const _FeaturedLoanCard({
    required this.title,
    required this.rateText,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String rateText;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rateText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF2E7BFA),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridLoanTile extends StatelessWidget {
  const _GridLoanTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
