import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HouseRentCalculatorScreen extends StatefulWidget {
  const HouseRentCalculatorScreen({super.key});

  @override
  State<HouseRentCalculatorScreen> createState() => _HouseRentCalculatorScreenState();
}

class _HouseRentCalculatorScreenState extends State<HouseRentCalculatorScreen> {
  double basicSalary = 50000;
  double hraReceived = 20000;
  double rentPaid = 15000;
  bool isMetroCity = true;

  double exemptHra = 0;
  double taxableHra = 0;

  @override
  void initState() {
    super.initState();
    _calculateHra();
  }

  void _calculateHra() {
    // HRA Exemption is least of:
    // 1. Actual HRA received
    // 2. 50% of salary (metro) or 40% (non-metro)
    // 3. Rent paid minus 10% of salary
    
    double option1 = hraReceived;
    double option2 = isMetroCity ? (basicSalary * 0.5) : (basicSalary * 0.4);
    double option3 = rentPaid - (basicSalary * 0.1);
    if (option3 < 0) option3 = 0;
    
    exemptHra = [option1, option2, option3].reduce((a, b) => a < b ? a : b);
    taxableHra = hraReceived - exemptHra;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HRA Calculator',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E44AD).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Exempt HRA',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹${exemptHra.toStringAsFixed(0)}',
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
                              _buildResultItem('Taxable HRA', '₹${taxableHra.toStringAsFixed(0)}'),
                              _buildResultItem('City Type', isMetroCity ? 'Metro' : 'Non-Metro'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Metro Toggle
                    Container(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Living in a Metro City?',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Delhi, Mumbai, Kolkata, Chennai',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isMetroCity,
                            activeColor: const Color(0xFF8E44AD),
                            onChanged: (val) {
                              setState(() => isMetroCity = val);
                              _calculateHra();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Premium Input Sections
                    _buildPremiumSliderSection(
                      'Basic Salary (Monthly)',
                      '₹${basicSalary.toInt()}',
                      basicSalary,
                      10000,
                      500000,
                      Icons.account_balance_outlined,
                      const Color(0xFF8E44AD),
                      (val) {
                        setState(() => basicSalary = val);
                        _calculateHra();
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildPremiumSliderSection(
                      'HRA Received (Monthly)',
                      '₹${hraReceived.toInt()}',
                      hraReceived,
                      0,
                      200000,
                      Icons.home_outlined,
                      const Color(0xFF8E44AD),
                      (val) {
                        setState(() => hraReceived = val);
                        _calculateHra();
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildPremiumSliderSection(
                      'Rent Paid (Monthly)',
                      '₹${rentPaid.toInt()}',
                      rentPaid,
                      0,
                      200000,
                      Icons.payment_outlined,
                      const Color(0xFF8E44AD),
                      (val) {
                        setState(() => rentPaid = val);
                        _calculateHra();
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
