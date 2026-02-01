import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VatCalculatorScreen extends StatefulWidget {
  const VatCalculatorScreen({super.key});

  @override
  State<VatCalculatorScreen> createState() => _VatCalculatorScreenState();
}

class _VatCalculatorScreenState extends State<VatCalculatorScreen> {
  double amount = 1000;
  double vatRate = 18;
  bool isVatInclusive = false;

  double vatAmount = 0;
  double totalAmount = 0;
  double netAmount = 0;

  @override
  void initState() {
    super.initState();
    _calculateVat();
  }

  void _calculateVat() {
    if (isVatInclusive) {
      totalAmount = amount;
      netAmount = totalAmount / (1 + (vatRate / 100));
      vatAmount = totalAmount - netAmount;
    } else {
      netAmount = amount;
      vatAmount = netAmount * (vatRate / 100);
      totalAmount = netAmount + vatAmount;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('VAT Calculator', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                  colors: [Color(0xFFE74C3C), Color(0xFFFF7675)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE74C3C).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
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
                      _buildResultItem('Net Amount', '₹${netAmount.toStringAsFixed(2)}'),
                      _buildResultItem('VAT Amount', '₹${vatAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isVatInclusive = false);
                        _calculateVat();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isVatInclusive ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Exclusive', style: GoogleFonts.inter(fontWeight: !isVatInclusive ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isVatInclusive = true);
                        _calculateVat();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isVatInclusive ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Inclusive', style: GoogleFonts.inter(fontWeight: isVatInclusive ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Input Section
            _buildSliderSection(
              'Amount',
              '₹${amount.toInt()}',
              amount,
              100,
              100000,
              (val) {
                setState(() => amount = val);
                _calculateVat();
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              'VAT Rate',
              '${vatRate.toInt()}%',
              vatRate,
              1,
              28,
              (val) {
                setState(() => vatRate = val);
                _calculateVat();
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
            Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFE74C3C))),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: const Color(0xFFE74C3C),
          inactiveColor: const Color(0xFFE74C3C).withOpacity(0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
