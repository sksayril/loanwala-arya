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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isApplyNowActive = false;
  bool _isLoading = true;

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: const Color(0xFF1A3B5D),
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
            'Super Loan',
            style: GoogleFonts.inter(
              color: const Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Bell icon
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A1A1A),
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCibilScoreCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckCibilScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2744), // Dark navy blue
              Color(0xFF243B5C), // Slightly lighter navy
              Color(0xFF1E3250), // Medium navy
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2744).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side - Score info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Your Credit Score',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Score number
                      Text(
                        '780',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Excellent badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: Color(0xFF10B981),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Excellent',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Check Now button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Check Now',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Lottie animated circular gauge with shield
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Lottie.asset(
                      'assets/CreditLottie.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTypeSection() {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: const Color(0xFF2E7BFA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid of loan cards
            Row(
              children: [
                Expanded(
                  child: _buildLoanGridCard(
                    context,
                    'Personal Loan',
                    'From 10.5%',
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFF2E7BFA),
                    const Color(0xFFE8F4FD),
                    const Color(0xFFF0F7FF), // Light blue card background
                    'Personal Loan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLoanGridCard(
                    context,
                    'Home Loan',
                    'From 8.5%',
                    Icons.home_rounded,
                    const Color(0xFF6366F1),
                    const Color(0xFFF0EFFF),
                    const Color(0xFFF8F7FF), // Light purple card background
                    'Home Loan',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLoanGridCard(
                    context,
                    'Education Loan',
                    'From 9.0%',
                    Icons.school_rounded,
                    const Color(0xFF9333EA),
                    const Color(0xFFFAF5FF),
                    const Color(0xFFFDF8FF), // Light lavender card background
                    'Education Loan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLoanGridCard(
                    context,
                    'Business Loan',
                    'From 11.5%',
                    Icons.business_center_rounded,
                    const Color(0xFF16A34A),
                    const Color(0xFFF0FDF4),
                    const Color(0xFFF5FFF8), // Light green card background
                    'Business Loan',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoanGridCard(
    BuildContext context,
    String title,
    String rate,
    IconData icon,
    Color iconColor,
    Color iconBgColor,
    Color cardBgColor,
    String loanType,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomizeLoanScreen(
              loanType: loanType,
              loanIcon: icon,
              loanColor: iconColor,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container with gradient background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconBgColor,
                    iconBgColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            // Loan title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            // Interest rate
            Text(
              rate,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
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
          'Financial Tools',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Vertical list of horizontal calculator cards
        _buildCalcItem(
          context,
          'EMI Calculator',
          'Plan your loan effectively',
          Icons.calculate_rounded,
          const Color(0xFFFFF7ED),
          const Color(0xFFEA580C),
          const EmiCalculatorScreen(),
        ),
        const SizedBox(height: 12),
        _buildCalcItem(
          context,
          'GST Calculator',
          'Calculate your taxes',
          Icons.receipt_long_outlined,
          const Color(0xFFEFF6FF),
          const Color(0xFF2563EB),
          const VatCalculatorScreen(),
        ),
        const SizedBox(height: 12),
        _buildCalcItem(
          context,
          'SIP Calculator',
          'Estimate your returns',
          Icons.trending_up_rounded,
          const Color(0xFFFFF1F2),
          const Color(0xFFE11D48),
          const SipCalculatorScreen(),
        ),
        const SizedBox(height: 12),
        _buildCalcItem(
          context,
          'PPF Calculator',
          'Public provident fund',
          Icons.savings_outlined,
          const Color(0xFFF0FDF4),
          const Color(0xFF16A34A),
          const SipCalculatorScreen(),
        ),
        const SizedBox(height: 12),
        _buildCalcItem(
          context,
          'RD Calculator',
          'Recurring deposit',
          Icons.account_balance_outlined,
          const Color(0xFFFAF5FF),
          const Color(0xFF9333EA),
          const HouseRentCalculatorScreen(),
        ),
        const SizedBox(height: 12),
        _buildCalcItem(
          context,
          'FD Calculator',
          'Fixed deposit returns',
          Icons.lock_outline_rounded,
          const Color(0xFFFEFCE8),
          const Color(0xFFCA8A04),
          const HouseRentCalculatorScreen(),
        ),
      ],
    );
  }

  Widget _buildCalcItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow button
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
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
      ),
    );
  }
}
