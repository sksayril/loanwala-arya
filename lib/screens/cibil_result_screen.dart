import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class CibilResultScreen extends StatefulWidget {
  final int score;

  const CibilResultScreen({
    super.key,
    required this.score,
  });

  @override
  State<CibilResultScreen> createState() => _CibilResultScreenState();
}

class _CibilResultScreenState extends State<CibilResultScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scoreAnimation;
  
  // Random data
  late String _paymentHistory;
  late String _utilization;
  late String _creditAge;
  late String _totalAccounts;
  late String _status;
  late String _statusLabel;

  @override
  void initState() {
    super.initState();
    _generateRandomData();
    _determineStatus();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(
      begin: 300.0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutCubic,
    ));
    
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _generateRandomData() {
    final random = Random();
    _paymentHistory = "${95 + random.nextInt(6)}%";
    _utilization = "${10 + random.nextInt(15)}%";
    _creditAge = "${2 + random.nextInt(4)}y ${random.nextInt(12)}m";
    _totalAccounts = "${3 + random.nextInt(5)} Active";
  }

  void _determineStatus() {
    if (widget.score >= 750) {
      _status = "EXCELLENT";
      _statusLabel = "• EXCELLENT";
    } else if (widget.score >= 700) {
      _status = "GOOD";
      _statusLabel = "• GOOD";
    } else if (widget.score >= 650) {
      _status = "FAIR";
      _statusLabel = "• FAIR";
    } else {
      _status = "AVERAGE";
      _statusLabel = "• AVERAGE";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Black-based dark background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCreditHealthSection(),
              const SizedBox(height: 32),
              _buildKeyFactors(),
              const SizedBox(height: 24),
              _buildScoreHistory(),
              const SizedBox(height: 24),
              _buildYourBenefits(),
              const SizedBox(height: 24),
              _buildViewLoanOffersButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Credit Report',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCreditHealthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Circular animated score gauge
          _scoreAnimation == null
              ? const SizedBox(width: 200, height: 200)
              : AnimatedBuilder(
                  animation: _scoreAnimation!,
                  builder: (context, child) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: CircularScorePainter(
                          score: _scoreAnimation!.value,
                          maxScore: 900,
                          minScore: 300,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CIBIL SCORE',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _scoreAnimation!.value.toInt().toString(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _statusLabel,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 16),
          Text(
            'Updated just now',
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          // Min and Max scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '300',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              Text(
                '900',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildKeyFactors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Factors',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _buildKeyFactorCard(
                  icon: Icons.calendar_today,
                  title: 'Payment History',
                  value: '100%',
                  status: 'Excellent',
                  statusColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKeyFactorCard(
                  icon: Icons.percent,
                  title: 'Credit Usage',
                  value: '12%',
                  status: 'Low Impact',
                  statusColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKeyFactorCard(
                  icon: Icons.history,
                  title: 'Credit Age',
                  value: '4y 2m',
                  status: 'Medium Impact',
                  statusColor: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKeyFactorCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Total Accounts',
                  value: '5 Active',
                  status: 'Stable',
                  statusColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFactorCard({
    required IconData icon,
    required String title,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF10B981), size: 20),
              ),
              Icon(
                statusColor == Colors.amber ? Icons.warning_amber : Icons.check_circle,
                color: statusColor,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score History',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Last 5 months',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+12 pts',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMonthLabel('JAN', false),
              _buildMonthLabel('FEB', false),
              _buildMonthLabel('MAR', false),
              _buildMonthLabel('APR', false),
              _buildMonthLabel('MAY', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthLabel(String month, bool isCurrent) {
    return Column(
      children: [
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981), width: 1),
            ),
            child: Text(
              widget.score.toString(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        if (isCurrent) const SizedBox(height: 4),
        Text(
          month,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCurrent ? const Color(0xFF10B981) : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildYourBenefits() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Benefits',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.percent,
            title: 'Lower Interest Rates',
            description: 'Eligible for rates as low as 8.5%',
          ),
          const SizedBox(height: 12),
          _buildBenefitCard(
            icon: Icons.speed,
            title: 'Faster Approval',
            description: 'Instant loan disbursement',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
        ],
      ),
    );
  }

  Widget _buildViewLoanOffersButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          // Navigate to home screen and clear the navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View Loan Offers',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreAnalysis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E), // Dark card background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score Analysis',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3441),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Text(
                  'View History',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You are in the top 20% of users.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          // Timeline Bar
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF5252), // Poor
                        Color(0xFFFFAB40), // Fair
                        Color(0xFFFFD740), // Good
                        Color(0xFF69F0AE), // Excellent
                      ],
                      stops: [0.0, 0.33, 0.66, 1.0],
                    ),
                  ),
                ),
                // Indicator caret
                AnimatedPositioned(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutCubic,
                  left: (constraints.maxWidth * ((widget.score - 300) / 600)).clamp(0.0, constraints.maxWidth - 10),
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 24),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreLabel('POOR'),
              _buildScoreLabel('FAIR'),
              _buildScoreLabel('GOOD'),
              _buildScoreLabel('EXCELLENT', isSelected: _status == 'EXCELLENT'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreLabel(String label, {bool isSelected = false}) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: isSelected ? const Color(0xFF00C853) : Colors.grey[400],
      ),
    );
  }

  Widget _buildProTip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3441).withOpacity(0.5), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keeping your credit utilization below 30% can consistently boost your score by up to 20 points.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[300],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditFactors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credit Factors',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        const SizedBox(height: 16),
        _buildFactorItem(
          icon: Icons.payments_outlined,
          color: Colors.green,
          title: 'Payment History',
          value: _paymentHistory,
          impact: 'High',
          status: 'Excellent',
        ),
        const SizedBox(height: 16),
        _buildFactorItem(
          icon: Icons.pie_chart_outline,
          color: Colors.blue,
          title: 'Utilization',
          value: _utilization,
          impact: 'High',
          status: 'Low Risk',
        ),
        const SizedBox(height: 16),
        _buildFactorItem(
          icon: Icons.calendar_today_outlined,
          color: Colors.orange,
          title: 'Credit Age',
          value: _creditAge,
          impact: 'Medium',
          status: 'Moderate',
        ),
        const SizedBox(height: 16),
        _buildFactorItem(
          icon: Icons.account_balance_outlined,
          color: Colors.purple,
          title: 'Total Accounts',
          value: _totalAccounts,
          impact: 'Low',
          status: 'Mix',
        ),
      ],
      ),
    );
  }

  Widget _buildFactorItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String impact,
    required String status,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Impact: $impact',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _status == "EXCELLENT" || _status == "GOOD" ? const Color(0xFF10B981) : Colors.white,
              ),
            ),
             Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreApprovedOffers() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E), // Dark card background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_open_rounded, color: Color(0xFF00C853), size: 20),
              const SizedBox(width: 10),
              Text(
                'Pre-approved Offers',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your excellent score of ${widget.score}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOfferButton(
                  icon: Icons.person,
                  label: 'Personal Loan',
                  color: const Color(0xFF00C853), // Green button
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOfferButton(
                  icon: Icons.home,
                  label: 'Home Loan',
                  color: const Color(0xFF334155), // Dark grey button
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CircularScorePainter extends CustomPainter {
  final double score;
  final double maxScore;
  final double minScore;

  CircularScorePainter({
    required this.score,
    required this.maxScore,
    required this.minScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    final thickness = 16.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle (dark grey)
    final backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Draw full circle background
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress color based on score
    Color progressColor;
    if (score >= 750) {
      progressColor = const Color(0xFF10B981); // Green
    } else if (score >= 700) {
      progressColor = const Color(0xFF10B981); // Green
    } else if (score >= 650) {
      progressColor = Colors.amber;
    } else {
      progressColor = Colors.orange;
    }

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Calculate progress (300 to 900 range = 600 total)
    final normalizedScore = ((score - minScore) / (maxScore - minScore)).clamp(0.0, 1.0);
    final sweepAngle = 2 * pi * normalizedScore;

    // Draw progress arc starting from top (-pi/2)
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CircularScorePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
