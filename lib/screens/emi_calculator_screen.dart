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
      backgroundColor: const Color(0xFF0A0E1A), // Dark background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EMI Calculator',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Premium Result Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8A2BE2), Color(0xFF9370DB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A2BE2).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Monthly EMI',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹${emi.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 24),
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
                    const SizedBox(height: 40),
                    
                    // Premium Input Sections
                    _buildPremiumSliderSection(
                      'Loan Amount',
                      '₹${loanAmount.toInt()}',
                      loanAmount,
                      10000,
                      5000000,
                      Icons.account_balance_wallet_outlined,
                      (val) {
                        setState(() => loanAmount = val);
                        _calculateEmi();
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildPremiumSliderSection(
                      'Interest Rate (p.a)',
                      '${interestRate.toStringAsFixed(1)}%',
                      interestRate,
                      1,
                      30,
                      Icons.trending_up_outlined,
                      (val) {
                        setState(() => interestRate = val);
                        _calculateEmi();
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildPremiumSliderSection(
                      'Tenure (Months)',
                      '${tenure.toInt()} Mo',
                      tenure,
                      3,
                      360,
                      Icons.calendar_today_outlined,
                      (val) {
                        setState(() => tenure = val);
                        _calculateEmi();
                      },
                    ),
                  ],
                ),
              ),
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
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSliderSection(
    String label,
    String value,
    double current,
    double min,
    double max,
    IconData icon,
    Function(double) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A2BE2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF8A2BE2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8A2BE2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF8A2BE2),
              inactiveTrackColor: const Color(0xFF8A2BE2).withOpacity(0.15),
              thumbColor: const Color(0xFF8A2BE2),
              overlayColor: const Color(0xFF8A2BE2).withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: current,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
