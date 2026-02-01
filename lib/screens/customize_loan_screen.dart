import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
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
  double _loanAmount = 150000;
  int _selectedTenure = 9; // in months
  bool _agreedToTerms = true;

  final double _minLoan = 5000;
  final double _maxLoan = 200000;
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customize Your Loan',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Interactive Circular Amount Display
                  SleekCircularSlider(
                    min: _minLoan,
                    max: _maxLoan,
                    initialValue: _loanAmount,
                    appearance: CircularSliderAppearance(
                      size: 280,
                      startAngle: 270,
                      angleRange: 360,
                      customColors: CustomSliderColors(
                        progressBarColor: const Color(0xFF8B5CF6),
                        trackColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                        dotColor: Colors.white,
                        shadowColor: const Color(0xFF8B5CF6),
                        shadowMaxOpacity: 0.2,
                      ),
                      customWidths: CustomSliderWidths(
                        progressBarWidth: 15,
                        trackWidth: 15,
                        handlerSize: 12,
                      ),
                    ),
                    onChange: (double value) {
                      setState(() {
                        _loanAmount = value;
                      });
                    },
                    innerWidget: (double value) {
                      return Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '₹${value.toStringAsFixed(0).replaceAllMapped(
                                    RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                    (Match m) => "${m[1]},",
                                  )}',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1A1A1A),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Tenure Selection Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTenureChip(3),
                      const SizedBox(width: 12),
                      _buildTenureChip(9),
                      const SizedBox(width: 12),
                      _buildTenureChip(12),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // EMI Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Monthly EMI: ₹${emi.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                (Match m) => "${m[1]},",
                              )}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Interest: ${_interestRate.toStringAsFixed(0)}% p.a.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Continue Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
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
                    backgroundColor: const Color(0xFF8B5CF6),
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTenureChip(int months) {
    bool isSelected = _selectedTenure == months;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTenure = months;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          '$months MONTHS',
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
