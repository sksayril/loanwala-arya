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
      appBar: AppBar(
        title: Text('HRA Calculator', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                  colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E44AD).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Exempt HRA',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${exemptHra.toStringAsFixed(0)}',
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
                      _buildResultItem('Taxable HRA', '₹${taxableHra.toStringAsFixed(0)}'),
                      _buildResultItem('City Type', isMetroCity ? 'Metro' : 'Non-Metro'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Metro Toggle
            SwitchListTile(
              title: Text('Living in a Metro City?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Delhi, Mumbai, Kolkata, Chennai', style: GoogleFonts.inter(fontSize: 12)),
              value: isMetroCity,
              activeColor: const Color(0xFF8E44AD),
              onChanged: (val) {
                setState(() => isMetroCity = val);
                _calculateHra();
              },
            ),
            const SizedBox(height: 24),

            // Input Section
            _buildSliderSection(
              'Basic Salary (Monthly)',
              '₹${basicSalary.toInt()}',
              basicSalary,
              10000,
              500000,
              (val) {
                setState(() => basicSalary = val);
                _calculateHra();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'HRA Received (Monthly)',
              '₹${hraReceived.toInt()}',
              hraReceived,
              0,
              200000,
              (val) {
                setState(() => hraReceived = val);
                _calculateHra();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'Rent Paid (Monthly)',
              '₹${rentPaid.toInt()}',
              rentPaid,
              0,
              200000,
              (val) {
                setState(() => rentPaid = val);
                _calculateHra();
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
            Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF8E44AD))),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: const Color(0xFF8E44AD),
          inactiveColor: const Color(0xFF8E44AD).withOpacity(0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
