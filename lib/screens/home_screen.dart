import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'check_cibil_score_screen.dart';
import 'customize_loan_screen.dart';
import 'loan_products_screen.dart';
import 'emi_calculator_screen.dart';
import 'sip_calculator_screen.dart';
import 'income_tax_calculator_screen.dart';
import 'vat_calculator_screen.dart';
import 'house_rent_calculator_screen.dart';
import '../services/loan_api_service.dart';
import '../services/ad_helper.dart';

/// Play Store listing for this app (`applicationId` in Android).
const String _kPlayStorePackageId = 'com.easyloan.app';

const String _kPrefHomeVisitCount = 'home_screen_visit_count';
const String _kPrefRatingPromptDone = 'rating_prompt_completed';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isApplyNowActive = false;
  bool _isLoading = true;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bootstrapHome();
    _initializeAds();
    _loadRewardedAd();
    _trackHomeVisitAndMaybeShowRating();
  }

  Future<void> _markRatingPromptDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefRatingPromptDone, true);
  }

  Future<void> _trackHomeVisitAndMaybeShowRating() async {
    final prefs = await SharedPreferences.getInstance();
    final int nextCount = (prefs.getInt(_kPrefHomeVisitCount) ?? 0) + 1;
    await prefs.setInt(_kPrefHomeVisitCount, nextCount);

    final bool alreadyDone = prefs.getBool(_kPrefRatingPromptDone) ?? false;
    if (nextCount != 2 || alreadyDone) return;
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showRatingStarDialog();
    });
  }

  void _showRatingStarDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        int selected = 0;
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'How would you rate Easy Loan?',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your feedback helps us improve.',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final int star = i + 1;
                      return IconButton(
                        onPressed: () => setLocal(() => selected = star),
                        icon: Icon(
                          star <= selected ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber.shade700,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _markRatingPromptDone();
                  },
                  child: Text('Maybe later', style: GoogleFonts.inter()),
                ),
                FilledButton(
                  onPressed: selected == 0
                      ? null
                      : () async {
                          Navigator.of(dialogContext).pop();
                          if (selected >= 4) {
                            await _openPlayStoreListing();
                            await _markRatingPromptDone();
                          } else {
                            if (mounted) _showInternalReviewDialog();
                          }
                        },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInternalReviewDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Tell us more',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Please type your review below.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Type your review…',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _markRatingPromptDone();
              },
              child: Text('Skip', style: GoogleFonts.inter()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _markRatingPromptDone();
                if (mounted) _showReviewSubmittedDialog();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showReviewSubmittedDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Thank you!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'Your review has been submitted. We appreciate your feedback.',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPlayStoreListing() async {
    final Uri web = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_kPlayStorePackageId',
    );
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final Uri market = Uri.parse('market://details?id=$_kPlayStorePackageId');
        final bool opened = await launchUrl(
          market,
          mode: LaunchMode.externalApplication,
        );
        if (opened) return;
      }
      final bool openedWeb = await launchUrl(
        web,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Play Store.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Play Store.')),
        );
      }
    }
  }

  /// App settings are fetched first; then Apply Now status.
  Future<void> _bootstrapHome() async {
    final appResp = await LoanApiService.fetchAppSettings();
    if (!mounted) return;

    if (appResp.success &&
        appResp.appSettings.appUpdateRequired &&
        appResp.appSettings.appUrl != null) {
      final uri = Uri.tryParse(appResp.appSettings.appUrl!);
      if (uri != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showForcedUpdateDialog(uri);
        });
      }
    }

    await _checkApplyNowStatus();
  }

  void _showForcedUpdateDialog(Uri storeUri) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Update required',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            'A new version is available. Please update the app from the store.',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                try {
                  final ok = await launchUrl(
                    storeUri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open the store link.'),
                      ),
                    );
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open the store link.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeAds() async {
    await AdHelper.refreshAdsSettings();
    await AdHelper.preloadInterstitialAd();
    final bannerAd = await AdHelper.loadBannerAd();
    if (!mounted) return;
    setState(() {
      _bannerAd = bannerAd;
    });
  }

  void _loadRewardedAd() {
    AdHelper.loadRewardedAd().then((ad) {
      if (ad != null) {
        setState(() {
          _rewardedAd = ad;
        });
        
        // Set up full screen content callback
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedAd = null;
            _loadRewardedAd(); // Load a new ad
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('Ad failed to show: $error');
            ad.dispose();
            _rewardedAd = null;
            _loadRewardedAd(); // Load a new ad
          },
        );
      }
    });
  }

  void _showRewardedAd(BuildContext context) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          // Navigate to CIBIL screen after ad is watched
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckCibilScreen(),
            ),
          );
        },
      );
    } else {
      // If ad is not loaded, navigate directly
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CheckCibilScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _checkApplyNowStatus() async {
    try {
      final status = await LoanApiService.checkApplyNowStatus();
      if (mounted) {
        setState(() {
          _isApplyNowActive = status.isActive;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking Apply Now status: $e');
      // On error, default to inactive
      if (mounted) {
        setState(() {
          _isApplyNowActive = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light greyish background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCibilScoreCard(context),
              const SizedBox(height: 24),
              // Only show loan type section if isActive is true
              if (_isApplyNowActive) ...[
                _buildLoanTypeSection(),
                const SizedBox(height: 24),
              ],
              _buildCalculatorsSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bannerAd == null
          ? null
          : SafeArea(
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
    );
  }

  Widget _buildCibilScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50), // Green background like EMI Calculator
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check Free CIBIL Score',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your credit report monthly',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => AdHelper.handleClickWithInterstitial(
                    onContinue: () => _showRewardedAd(context),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Click Here',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Lottie Animation on the right
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset(
              'assets/CreditLottie.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanTypeSection() {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Loan Type',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const LoanProductsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2E7BFA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildLoanCard(context, Icons.account_balance_wallet_rounded, 'Personal Loan', color: Colors.blue),
                _buildLoanCard(context, Icons.home_rounded, 'Home Loan', color: Colors.orange),
                _buildLoanCard(context, Icons.business_center_rounded, 'Business Loan', color: Colors.purple),
                _buildLoanCard(context, Icons.school_rounded, 'Education Loan', color: Colors.amber),
                _buildLoanCard(context, Icons.directions_car_rounded, 'Car Loan', color: Colors.redAccent),
                _buildLoanCard(context, Icons.emoji_events_rounded, 'Gold Loan', color: Colors.amber[700]),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoanCard(BuildContext context, IconData icon, String title, {String? badge, Color? color}) {
    // Default blue if no color provided
    final iconColor = color ?? const Color(0xFF2E7BFA);
    
    return GestureDetector(
      onTap: () => AdHelper.handleClickWithInterstitial(
        onContinue: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomizeLoanScreen(
                loanType: title,
                loanIcon: icon,
                loanColor: iconColor,
              ),
            ),
          );
        },
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              iconColor.withOpacity(0.05),
              iconColor.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Calculators',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildCalcItem(context, 'GST', Colors.orange, const EmiCalculatorScreen()),
            _buildCalcItem(context, 'VAT', Colors.blue, const VatCalculatorScreen()),
            _buildCalcItem(context, 'PPF', Colors.green, const SipCalculatorScreen()),
            _buildCalcItem(context, 'SIP', Colors.red, const SipCalculatorScreen()),
            _buildCalcItem(context, 'RD', Colors.purple, const HouseRentCalculatorScreen()),
            _buildCalcItem(context, 'FD', Colors.amber[700]!, const HouseRentCalculatorScreen()),
          ],
        ),
      ],
    );
  }

  Widget _buildCalcItem(BuildContext context, String title, Color color, Widget screen) {
    return GestureDetector(
      onTap: () => AdHelper.handleClickWithInterstitial(
        onContinue: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background abstract shape
            Positioned(
              left: -10,
              top: 20,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Calculator',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Icon(Icons.arrow_forward_ios, color: color, size: 12),
                      ),
                      SizedBox(
                        width: 55,
                        height: 55,
                        child: Lottie.asset(
                          'assets/Calculator.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
