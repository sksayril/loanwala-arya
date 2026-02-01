
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
              _buildTopBar(),
              const SizedBox(height: 24),
              _buildCibilScoreCard(context),
              const SizedBox(height: 24),
              _buildTrustBadges(),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Image.asset(
                  'assets/20260130_231228.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              'Easy Loan',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            const Icon(Icons.notifications_none_rounded, size: 28, color: Colors.black87),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCibilScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7BFA), Color(0xFF5C9DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7BFA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your credit report monthly',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stacked Avatars Placeholder
              SizedBox(
                width: 80,
                height: 30,
                child: Stack(
                  children: [
                    _buildAvatarPlaceholder(0, Colors.grey),
                    _buildAvatarPlaceholder(20, Colors.grey[400]!),
                    Positioned(
                       left: 40,
                       child: CircleAvatar(
                         radius: 15,
                         backgroundColor: const Color(0xFF1E5BB0),
                         child: Text(
                           '+2M',
                           style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                         ),
                       ),
                    )
                  ],
                ),
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Check Now',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2E7BFA),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2E7BFA), size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(double left, Color color) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 13,
          backgroundColor: color,
          child: const Icon(Icons.person, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrustItem(Icons.verified_user_rounded, '100% Secure'),
          Container(width: 1, height: 20, color: Colors.grey[300]),
          _buildTrustItem(Icons.lock_rounded, 'RBI Registered'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7BFA), size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFF1A3B6E), // Darker status blue
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
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
              childAspectRatio: 1.0,
              children: [
                _buildLoanCard(context, Icons.payments_rounded, 'Personal Loan',),
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
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E8E3E),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
          childAspectRatio: 2.2,
          children: [
            _buildCalcItem(context, Icons.calculate_rounded, 'EMI Calculator', Colors.blue, const EmiCalculatorScreen()),
            _buildCalcItem(context, Icons.trending_up_rounded, 'SIP Calculator', Colors.green, const SipCalculatorScreen()),
            _buildCalcItem(context, Icons.account_balance_rounded, 'Income Tax', Colors.orange, const IncomeTaxCalculatorScreen()),
            _buildCalcItem(context, Icons.receipt_long_rounded, 'VAT Calculator', Colors.red, const VatCalculatorScreen()),
            _buildCalcItem(context, Icons.home_work_rounded, 'House Rent', Colors.purple, const HouseRentCalculatorScreen()),
          ],
        ),
      ],
    );
  }

  Widget _buildCalcItem(BuildContext context, IconData icon, String title, Color color, Widget screen) {
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
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
