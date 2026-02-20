
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'check_cibil_score_screen.dart';
import 'customize_loan_screen.dart';
import 'emi_calculator_screen.dart';
import 'sip_calculator_screen.dart';
import 'income_tax_calculator_screen.dart';
import 'vat_calculator_screen.dart';
import 'house_rent_calculator_screen.dart';
import '../services/loan_api_service.dart';
import '../services/ad_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isApplyNowActive = false;
  bool _isLoading = true;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _checkApplyNowStatus();
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

  Future<void> _handleCheckCibilScore() async {
    setState(() {
      _isLoadingAd = true;
    });

    // Show rewarded ad before navigating to CIBIL screen
    final bool adShown = await AdHelper.showRewardedAd(
      onAdDismissed: () {
        // Navigate to CIBIL screen after ad is dismissed
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckCibilScreen(),
            ),
          );
        }
      },
      onAdFailedToShow: () {
        // If ad fails to show, still navigate to CIBIL screen
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckCibilScreen(),
            ),
          );
        }
      },
      onUserEarnedReward: () {
        // User earned reward - can add any reward logic here
        print('User earned reward for watching ad');
      },
    );

    // If ad couldn't be loaded/shown, navigate directly
    if (!adShown && mounted) {
      setState(() {
        _isLoadingAd = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CheckCibilScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light greyish background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderBar(),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A3B5D), // Match CIBIL card top color
            Color(0xFF244A70), // Match CIBIL card bottom color
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bank icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // App name
          Text(
            'LoanKart',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Bell icon
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCibilScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A3B5D), // Darker blue at top
            const Color(0xFF244A70), // Slightly lighter blue at bottom
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Credit Health label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  'Credit Health',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Score Placeholder (---)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Lottie.asset(
                      'assets/CreditLottie.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Updated status
              Text(
                'Updated 2 days ago',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              // Call to action text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Unlock better loan offers by tracking your score.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Check CIBIL Score button
              GestureDetector(
                onTap: _isLoadingAd ? null : _handleCheckCibilScore,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isLoadingAd 
                        ? const Color(0xFF5CCB86).withOpacity(0.6)
                        : const Color(0xFF5CCB86), // Brighter green matching image
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5CCB86).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoadingAd
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Check CIBIL Score',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
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
                  'Apply for Loan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5CCB86),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLoanListItem(
              context,
              'Personal Loan',
              'Unsecured • Quick',
              'Up to ₹5 Lakhs',
              'FAST',
              const Color(0xFFE0F2FE),
              const Color(0xFF2E7BFA),
              Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 12),
            _buildLoanListItem(
              context,
              'Home Loan',
              'Dream Home • Easy EMI',
              'Up to ₹5 Crores',
              'LOW RATES',
              const Color(0xFFF0FDF4),
              const Color(0xFF16A34A),
              Icons.home_rounded,
            ),
            const SizedBox(height: 12),
            _buildLoanListItem(
              context,
              'Education Loan',
              'For Higher Studies',
              'Up to ₹20 Lakhs',
              'FLEXIBLE',
              const Color(0xFFFAF5FF),
              const Color(0xFF9333EA),
              Icons.school_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoanListItem(
    BuildContext context,
    String title,
    String subtitle,
    String amount,
    String badgeText,
    Color bgColor,
    Color accentColor,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomizeLoanScreen(
              loanType: title,
              loanIcon: icon,
              loanColor: accentColor,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Image/Icon Section
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: accentColor,
                  ),
                ),
              ),
              // Right Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Up to',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                amount.substring(6), // Just the amount part
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A3B5D),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Tools',
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
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildCalcItem(context, 'GST', 'Plan your taxes', Icons.calculate_outlined, const Color(0xFFFFF7ED), const Color(0xFFEA580C), const EmiCalculatorScreen()),
            _buildCalcItem(context, 'VAT', 'Value added tax', Icons. receipt_long_outlined, const Color(0xFFEFF6FF), const Color(0xFF2563EB), const VatCalculatorScreen()),
            _buildCalcItem(context, 'PPF', 'Public provident fund', Icons.savings_outlined, const Color(0xFFF0FDF4), const Color(0xFF16A34A), const SipCalculatorScreen()),
            _buildCalcItem(context, 'SIP', 'Estimate your returns', Icons.trending_up_rounded, const Color(0xFFFFF1F2), const Color(0xFFE11D48), const SipCalculatorScreen()),
            _buildCalcItem(context, 'RD', 'Recurring deposit', Icons.account_balance_outlined, const Color(0xFFFAF5FF), const Color(0xFF9333EA), const HouseRentCalculatorScreen()),
            _buildCalcItem(context, 'FD', 'Fixed deposit', Icons.lock_outline_rounded, const Color(0xFFFEFCE8), const Color(0xFFCA8A04), const HouseRentCalculatorScreen()),
          ],
        ),
      ],
    );
  }

  Widget _buildCalcItem(BuildContext context, String title, String subtitle, IconData icon, Color bgColor, Color iconColor, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
