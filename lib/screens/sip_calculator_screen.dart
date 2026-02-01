import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  double monthlyInvestment = 5000;
  double expectedReturn = 12;
  double timePeriod = 10; // in years

  double totalValue = 0;
  double investedAmount = 0;
  double estimatedReturns = 0;

  @override
  void initState() {
    super.initState();
    _calculateSip();
  }

  void _calculateSip() {
    double i = expectedReturn / (12 * 100);
    double n = timePeriod * 12;
    
    investedAmount = monthlyInvestment * n;
    
    if (i == 0) {
      totalValue = investedAmount;
    } else {
      totalValue = monthlyInvestment * ((pow(1 + i, n) - 1) / i) * (1 + i);
    }
    
    estimatedReturns = totalValue - investedAmount;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('SIP Calculator', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B894).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Total Value',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalValue.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildResultItem('Invested', '₹${investedAmount.toStringAsFixed(0)}'),
                      _buildResultItem('Est. Returns', '₹${estimatedReturns.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Input Section
            _buildSliderSection(
              'Monthly Investment',
              '₹${monthlyInvestment.toInt()}',
              monthlyInvestment,
              500,
              100000,
              (val) {
                setState(() => monthlyInvestment = val);
                _calculateSip();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'Expected Return (p.a)',
              '${expectedReturn.toStringAsFixed(1)}%',
              expectedReturn,
              1,
              30,
              (val) {
                setState(() => expectedReturn = val);
                _calculateSip();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'Time Period (Years)',
              '${timePeriod.toInt()} Yr',
              timePeriod,
              1,
              40,
              (val) {
                setState(() => timePeriod = val);
                _calculateSip();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSliderSection(String label, String value, double current, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF00B894))),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: const Color(0xFF00B894),
          inactiveColor: const Color(0xFF00B894).withOpacity(0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
