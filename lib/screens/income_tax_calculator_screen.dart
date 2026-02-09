import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomeTaxCalculatorScreen extends StatefulWidget {
  const IncomeTaxCalculatorScreen({super.key});

  @override
  State<IncomeTaxCalculatorScreen> createState() => _IncomeTaxCalculatorScreenState();
}

class _IncomeTaxCalculatorScreenState extends State<IncomeTaxCalculatorScreen> {
  double annualIncome = 1000000;
  double deductions = 150000;
  
  double taxableIncome = 0;
  double totalTax = 0;
  double cess = 0;
  double netTax = 0;

  @override
  void initState() {
    super.initState();
    _calculateTax();
  }

  void _calculateTax() {
    taxableIncome = annualIncome - deductions;
    if (taxableIncome < 0) taxableIncome = 0;
    
    totalTax = 0;
    
    // New Regime (Simplified for example)
    if (taxableIncome <= 300000) {
      totalTax = 0;
    } else if (taxableIncome <= 600000) {
      totalTax = (taxableIncome - 300000) * 0.05;
    } else if (taxableIncome <= 900000) {
      totalTax = 15000 + (taxableIncome - 600000) * 0.10;
    } else if (taxableIncome <= 1200000) {
      totalTax = 45000 + (taxableIncome - 900000) * 0.15;
    } else if (taxableIncome <= 1500000) {
      totalTax = 90000 + (taxableIncome - 1200000) * 0.20;
    } else {
      totalTax = 150000 + (taxableIncome - 1500000) * 0.30;
    }
    
    // Rebate under 87A (Simplified)
    if (taxableIncome <= 700000) {
      totalTax = 0;
    }
    
    cess = totalTax * 0.04;
    netTax = totalTax + cess;
    
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
                    'Income Tax Calculator',
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
                          colors: [Color(0xFFF39C12), Color(0xFFF1C40F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF39C12).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Net Tax Payable',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹${netTax.toStringAsFixed(0)}',
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
                              _buildResultItem('Taxable Income', '₹${taxableIncome.toStringAsFixed(0)}'),
                              _buildResultItem('Cess (4%)', '₹${cess.toStringAsFixed(0)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Premium Input Sections
                    _buildPremiumSliderSection(
                      'Annual Income',
                      '₹${annualIncome.toInt()}',
                      annualIncome,
                      100000,
                      10000000,
                      Icons.account_balance_outlined,
                      const Color(0xFFF39C12),
                      (val) {
                        setState(() => annualIncome = val);
                        _calculateTax();
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildPremiumSliderSection(
                      'Deductions (80C, etc)',
                      '₹${deductions.toInt()}',
                      deductions,
                      0,
                      500000,
                      Icons.receipt_long_outlined,
                      const Color(0xFFF39C12),
                      (val) {
                        setState(() => deductions = val);
                        _calculateTax();
                      },
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Calculated based on FY 2024-25 New Tax Regime.',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.blue[900]),
                            ),
                          ),
                        ],
                      ),
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
    Color color,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.15),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
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
