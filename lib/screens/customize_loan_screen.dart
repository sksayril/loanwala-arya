import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'personal_details_screen.dart';

class CustomizeLoanScreen extends StatefulWidget {
  final String loanType;
  final IconData loanIcon;
  final Color loanColor;

  const CustomizeLoanScreen({
    super.key,
    required this.loanType,
    required this.loanIcon,
    required this.loanColor,
  });

  @override
  State<CustomizeLoanScreen> createState() => _CustomizeLoanScreenState();
}

class _CustomizeLoanScreenState extends State<CustomizeLoanScreen> {
  double _loanAmount = 180000;
  int _selectedTenure = 9; // in months
  bool _agreedToTerms = true;

  final double _minLoan = 10000;
  final double _maxLoan = 500000;
  final double _interestRate = 12.0; // 12% p.a.

  double _calculateEMI() {
    double monthlyRate = _interestRate / (12 * 100);
    double emi = (_loanAmount * monthlyRate * pow(1 + monthlyRate, _selectedTenure)) /
        (pow(1 + monthlyRate, _selectedTenure) - 1);
    return emi;
  }

  @override
  Widget build(BuildContext context) {
    double emi = _calculateEMI();

    return Scaffold(
      backgroundColor: const Color(0xFF2C2E3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2E3A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customize Your Loan',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Amount Display and Slider
                  Center(
                    child: Text(
                      '₹${_loanAmount.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                            (Match m) => "${m[1]},",
                          )}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8,
                      activeTrackColor: const Color(0xFF8B5CF6),
                      inactiveTrackColor: const Color(0xFF4A4C5A),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 16,
                        elevation: 4,
                      ),
                      overlayColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: _loanAmount,
                      min: _minLoan,
                      max: _maxLoan,
                      divisions: 98,
                      onChanged: (double value) {
                        setState(() {
                          _loanAmount = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  // First Tenure Section
                  Text(
                    'Select Tenure',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTenureButton(3)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTenureButton(6)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTenureButton(12)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Second Tenure Section
                  Text(
                    'Select Tenure',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTenureButton(3)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTenureButton(9)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTenureButton(12)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // EMI Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3D4A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly EMI: ₹${emi.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                (Match m) => "${m[1]},",
                              )}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Interest: ${_interestRate.toStringAsFixed(0)}% p.a.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF6366F1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _agreedToTerms
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PersonalDetailsScreen(
                                      loanAmount: _loanAmount,
                                      tenure: _selectedTenure,
                                      loanType: widget.loanType,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
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
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenureButton(int months) {
    bool isSelected = _selectedTenure == months;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTenure = months;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.2) : const Color(0xFF3A3D4A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF4A4C5A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$months MONTHS',
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
