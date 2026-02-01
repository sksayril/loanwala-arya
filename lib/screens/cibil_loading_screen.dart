
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cibil_result_screen.dart';

class CibilLoadingScreen extends StatefulWidget {
  const CibilLoadingScreen({super.key});

  @override
  State<CibilLoadingScreen> createState() => _CibilLoadingScreenState();
}

class _CibilLoadingScreenState extends State<CibilLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<String> _loadingTexts = [
    "Connecting to CIBIL Bureau...",
    "Verifying your details...",
    "Analyzing credit history...",
    "Generating report...",
    "Finalizing your score..."
  ];
  int _currentTextIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Cycle through loading texts
    _textTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_currentTextIndex < _loadingTexts.length - 1) {
        setState(() {
          _currentTextIndex++;
        });
      }
    });

    // Navigate to result after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final random = Random();
        // Generate random score between 645 and 798
        final int score = 645 + random.nextInt(798 - 645 + 1);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CibilResultScreen(score: score),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Loader Animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing rings
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double value = (_controller.value + (index * 0.33)) % 1.0;
                      return Opacity(
                        opacity: 1.0 - value, // Fade out as it expands
                        child: Container(
                          width: 100 + (value * 100),
                          height: 100 + (value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2E7BFA).withOpacity(0.2),
                          ),
                        ),
                      );
                    },
                  );
                }),
                // Central Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7BFA),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x402E7BFA),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.speed_rounded, color: Colors.white, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Loading Text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _loadingTexts[_currentTextIndex],
                key: ValueKey<int>(_currentTextIndex),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Please wait, this won't take long",
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
