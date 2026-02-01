import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Random data
  late String _paymentHistory;
  late String _utilization;
  late String _creditAge;
  late String _totalAccounts;
  late String _status;
  late Color _statusColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 300, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _generateRandomData();
    _determineStatus();
  }

  void _generateRandomData() {
    final random = Random();
    _paymentHistory = "${95 + random.nextInt(6)}% On Time";
    _utilization = "${15 + random.nextInt(20)}% Used";
    _creditAge = "${2 + random.nextInt(4)} Yrs ${random.nextInt(12)} Mos";
    _totalAccounts = "${3 + random.nextInt(5)} Active";
  }

  void _determineStatus() {
    if (widget.score >= 750) {
      _status = "EXCELLENT";
      _statusColor = const Color(0xFF00C853);
    } else if (widget.score >= 700) {
      _status = "GOOD";
      _statusColor = const Color(0xFFB2D900); // Light Green/Yellow-Green
    } else if (widget.score >= 650) {
      _status = "FAIR";
      _statusColor = const Color(0xFFFFAB00); // Amber
    } else {
      _status = "AVERAGE";
      _statusColor = const Color(0xFFFF3D00); // Red/Orange
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CIBIL Report',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildGaugeSection(),
            const SizedBox(height: 20),
            _buildScoreAnalysis(),
            const SizedBox(height: 20),
            _buildProTip(),
            const SizedBox(height: 24),
            _buildCreditFactors(),
            const SizedBox(height: 24),
            _buildPreApprovedOffers(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeSection() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              height: 200,
              width: 300,
              child: CustomPaint(
                painter: GaugePainter(score: _animation.value, maxScore: 900),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Push text down a bit
                    Text(
                      _animation.value.toInt().toString(),
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                    ),
                    Text(
                      'out of 900',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _status,
                        style: GoogleFonts.inter(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Updated on ${DateTime.now().day} ${_getMonth(DateTime.now().month)}, ${DateTime.now().year}',
              style: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'POWERED BY CIBIL',
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildScoreAnalysis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Very light grey
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
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  'View History',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
              color: Colors.grey[600],
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
                    child: const Icon(Icons.arrow_drop_up, color: Colors.black, size: 24),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withOpacity(0.4), // Light yellow bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFF9C4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF176),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Color(0xFFF57F17), size: 20),
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keeping your credit utilization below 30% can consistently boost your score by up to 20 points.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black87,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit Factors',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
                  color: Colors.black87,
                ),
              ),
              Text(
                'Impact: $impact',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
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
                color: _status == "EXCELLENT" || _status == "GOOD" ? const Color(0xFF00C853) : Colors.black87,
              ),
            ),
             Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreApprovedOffers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark blue/slate
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

class GaugePainter extends CustomPainter {
  final double score;
  final double maxScore;

  GaugePainter({required this.score, required this.maxScore});

  @override
  void paint(Canvas canvas, Size size) {
    // Center point
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = min(size.width / 2, size.height * 0.9);
    final thickness = 20.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background Arc (Grey/Light)
    final backgroundPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Draw full semi-circle background (from -PI to 0)
    canvas.drawArc(rect, pi, pi, false, backgroundPaint);

    // Active Arc Gradient
    // We want a gradient that goes from Red -> Yellow -> Green along the arc
    // But Flutter's sweep gradient centers at the rect center.
    // We can use a SweepGradient.
    
    final gradient = SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: const [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
      ],
      tileMode: TileMode.clamp,
      transform: GradientRotation(0), // No rotation needed if matched correctly, but check
    );

    // However, for the *progress*, typically we want the color to match the score level SO FAR or just show the solid color of the *current* level.
    // The "Second Image" typically shows a solid green bar if the score is excellent.
    // But let's look at standard "Semi Circle Gauge". Often it is a gradient track OR a segmented track.
    // Let's draw the BACKGROUND track as the colored segments (Red -> Green).
    // And then we draw a MASK or we just don't draw the empty part?
    // Actually, usually the gauge IS the colored bar, and the needles points to it.
    // BUT the user asked for "fill up" animation.
    // So let's draw a light grey background, and a colored foreground arc that fills up.
    
    // Foreground Color based on score
    Color progressColor;
    if (score >= 750) {
      progressColor = const Color(0xFF00C853);
    } else if (score >= 700) {
      progressColor = const Color(0xFFB2D900);
    } else if (score >= 650) {
      progressColor = const Color(0xFFFFAB00);
    } else {
      progressColor = const Color(0xFFFF3D00);
    }

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Calculate sweep angle based on score (300 to 900 range)
    // 300 is min, 900 is max. Range = 600.
    // If score is 300, angle is 0. If score is 900, angle is PI.
    final normalizedScore = (score - 300).clamp(0, 600) / 600;
    final sweepAngle = normalizedScore * pi;

    canvas.drawArc(rect, pi, sweepAngle, false, progressPaint);
    
    // Draw Needle? User said "Clock like". 
    // A needle would be a line from center to the radius at the specific angle.
    // Let's add a small needle tip just outside or inside the arc?
    // Or just the filled arc is enough? The "Second Image" usually has a clean modern look without a literal vintage needle.
    // Typically "Clock like" might refer to the circular nature.
    // I will add a small indicator circle at the end of the arc to make it look active.
    
    if (score > 300) {
        final indicatorAngle = pi + sweepAngle;
        final indicatorX = center.dx + radius * cos(indicatorAngle);
        final indicatorY = center.dy + radius * sin(indicatorAngle);
        
        final knobPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
          
        final knobBorderPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

        canvas.drawCircle(Offset(indicatorX, indicatorY), thickness / 1.5, knobPaint);
        canvas.drawCircle(Offset(indicatorX, indicatorY), thickness / 1.5, knobBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
