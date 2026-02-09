
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loan_listing_screen.dart';

class BankVerificationLoaderScreen extends StatefulWidget {
  const BankVerificationLoaderScreen({super.key});

  @override
  State<BankVerificationLoaderScreen> createState() => _BankVerificationLoaderScreenState();
}

class _BankVerificationLoaderScreenState extends State<BankVerificationLoaderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoanListingScreen(
              loanType: 'Personal Loan',
              amountRange: '₹1,00,000 - ₹10,00,000',
              primaryColor: Color(0xFF1E3A5F),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Spinner
            SizedBox(
              width: 80,
              height: 80,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: CustomPaint(
                      painter: SpinnerPainter(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Verifying Details...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we check your eligibility',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;

    // Background Circle
    final bgPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Spinner Arc
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
           Color(0xFF2563EB),
           Color(0xFF93C5FD), 
           Colors.transparent,
        ],
        stops: [0.0, 0.7, 1.0],
        startAngle: 0.0,
        endAngle: 3.14 * 2,
        transform: GradientRotation(-3.14/2), 
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5, // Start slightly before top
      4.5, // 3/4 circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
