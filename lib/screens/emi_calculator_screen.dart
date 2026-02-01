import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double loanAmount = 500000;
  double interestRate = 10.5;
  double tenure = 12; // in months

  double emi = 0;
  double totalInterest = 0;
  double totalPayment = 0;

  @override
  void initState() {
    super.initState();
    _calculateEmi();
  }

  void _calculateEmi() {
    double r = interestRate / (12 * 100);
    double n = tenure;
    
    if (r == 0) {
      emi = loanAmount / n;
    } else {
      emi = (loanAmount * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    }
    
    totalPayment = emi * n;
    totalInterest = totalPayment - loanAmount;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('EMI Calculator', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                  colors: [Color(0xFF6C3EE8), Color(0xFF8E66F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C3EE8).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Monthly EMI',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${emi.toStringAsFixed(0)}',
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
                      _buildResultItem('Total Interest', '₹${totalInterest.toStringAsFixed(0)}'),
                      _buildResultItem('Total Payment', '₹${totalPayment.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Input Section
            _buildSliderSection(
              'Loan Amount',
              '₹${loanAmount.toInt()}',
              loanAmount,
              10000,
              5000000,
              (val) {
                setState(() => loanAmount = val);
                _calculateEmi();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'Interest Rate (p.a)',
              '${interestRate.toStringAsFixed(1)}%',
              interestRate,
              1,
              30,
              (val) {
                setState(() => interestRate = val);
                _calculateEmi();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'Tenure (Months)',
              '${tenure.toInt()} Mo',
              tenure,
              3,
              360,
              (val) {
                setState(() => tenure = val);
                _calculateEmi();
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
            Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6C3EE8))),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: const Color(0xFF6C3EE8),
          inactiveColor: const Color(0xFF6C3EE8).withOpacity(0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
