import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'check_cibil_score_screen.dart';
import 'customize_loan_screen.dart';
import 'emi_calculator_screen.dart';
import 'sip_calculator_screen.dart';
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
      backgroundColor: const Color(0xFF0A0E1A), // Black-based background
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A), // Dark background
      ),
      child: Row(
        children: [
          // App logo
          Image.asset(
            'assets/loanguru.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          // Welcome text and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell with badge
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E), // Dark circular background
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
              // Red notification badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), // Red badge
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
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
          color: const Color(0xFF1A2C2E), // Dark green/teal background to match second image
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
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
                      color: Colors.grey[400],
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
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Excellent text (bright green, not in badge)
                  Text(
                    'Excellent',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34D399), // Bright green to match second image
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Check Now button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399), // Bright green button to match second image
                      borderRadius: BorderRadius.circular(20),
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
            // Right side - Lottie animated circular gauge
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
                    color: Colors.white,
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
                    'Instant cash',
                    Icons.person_rounded,
                    const Color(0xFF3B82F6), // Blue circle
                    const Color(0xFFE8F4FD),
                    const Color(0xFFF0F7FF),
                    'Personal Loan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLoanGridCard(
                    context,
                    'Home Loan',
                    'Buy your dream',
                    Icons.home_rounded,
                    const Color(0xFFEF4444), // Red/orange circle
                    const Color(0xFFF0EFFF),
                    const Color(0xFFF8F7FF),
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
                    'Invest in future',
                    Icons.school_rounded,
                    const Color(0xFF14B8A6), // Teal circle
                    const Color(0xFFFAF5FF),
                    const Color(0xFFFDF8FF),
                    'Education Loan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLoanGridCard(
                    context,
                    'Business Loan',
                    'Expand scale',
                    Icons.business_center_rounded,
                    const Color(0xFF8B5CF6), // Purple circle
                    const Color(0xFFF0FDF4),
                    const Color(0xFFF5FFF8),
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
          color: const Color(0xFF1C1E26), // Much darker card background to match second image
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular icon container with solid color background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor, // Use the icon color as background
                shape: BoxShape.circle, // Make it circular
              ),
              child: Icon(
                icon,
                color: Colors.white, // White icon
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle/rate
            Text(
              rate,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quick Tools',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Vertical 2-column grid layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // First row - 2 cards
              Row(
                children: [
                  Expanded(
                    child: _buildCalculatorCard(
                      context,
                      'EMI',
                      'Calculator',
                      Icons.calculate_rounded,
                      const Color(0xFF10B981), // Green
                      const EmiCalculatorScreen(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCalculatorCard(
                      context,
                      'Interest',
                      'Rate Checker',
                      Icons.percent_rounded,
                      const Color(0xFF10B981), // Green
                      const VatCalculatorScreen(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Second row - 2 cards
              Row(
                children: [
                  Expanded(
                    child: _buildCalculatorCard(
                      context,
                      'SIP',
                      'Calculator',
                      Icons.trending_up_rounded,
                      const Color(0xFF3B82F6), // Blue
                      const SipCalculatorScreen(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCalculatorCard(
                      context,
                      'PPF',
                      'Calculator',
                      Icons.savings_outlined,
                      const Color(0xFF8B5CF6), // Purple
                      const SipCalculatorScreen(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Third row - 2 cards
              Row(
                children: [
                  Expanded(
                    child: _buildCalculatorCard(
                      context,
                      'RD',
                      'Calculator',
                      Icons.account_balance_outlined,
                      const Color(0xFFEF4444), // Red
                      const HouseRentCalculatorScreen(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCalculatorCard(
                      context,
                      'FD',
                      'Calculator',
                      Icons.lock_outline_rounded,
                      const Color(0xFFF59E0B), // Amber
                      const HouseRentCalculatorScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E26), // Dark card background
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            // Title and Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

