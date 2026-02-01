
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckCibilScreen(),
                      ),
                    );
                  },
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
      onTap: () {
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
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const Spacer(),
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
                        width: 70,
                        height: 70,
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
