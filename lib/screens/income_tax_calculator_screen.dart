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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Income Tax Calculator', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                  colors: [Color(0xFFF39C12), Color(0xFFF1C40F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF39C12).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Net Tax Payable',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${netTax.toStringAsFixed(0)}',
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
                      _buildResultItem('Taxable Income', '₹${taxableIncome.toStringAsFixed(0)}'),
                      _buildResultItem('Cess (4%)', '₹${cess.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Input Section
            _buildSliderSection(
              'Annual Income',
              '₹${annualIncome.toInt()}',
              annualIncome,
              100000,
              10000000,
              (val) {
                setState(() => annualIncome = val);
                _calculateTax();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'Deductions (80C, etc)',
              '₹${deductions.toInt()}',
              deductions,
              0,
              500000,
              (val) {
                setState(() => deductions = val);
                _calculateTax();
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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
            Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFF39C12))),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: const Color(0xFFF39C12),
          inactiveColor: const Color(0xFFF39C12).withOpacity(0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
