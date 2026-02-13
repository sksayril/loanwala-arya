import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'personal_details_screen.dart';
import '../services/ad_helper.dart';

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
  double _loanAmount = 20000;
  int _selectedTenure = 12; // in months
  bool _agreedToTerms = true;

  final double _minLoan = 1000;
  final double _maxLoan = 50000;
  final double _interestRate = 18.0; // 18% p.a.

  double _calculateEMI() {
    double monthlyRate = _interestRate / (12 * 100);
    double emi = (_loanAmount * monthlyRate * pow(1 + monthlyRate, _selectedTenure)) /
        (pow(1 + monthlyRate, _selectedTenure) - 1);
    return emi;
  }

  Future<void> _showRewardedAdAndNavigate(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Load the rewarded ad
      final rewardedAd = await AdHelper.loadRewardedAd();
      
      if (!mounted) return;
      
      // Dismiss loading indicator
      Navigator.of(context).pop();

      if (rewardedAd != null) {
        // Show the rewarded ad
        rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            // Navigate to PersonalDetailsScreen after ad is dismissed
            if (mounted) {
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
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('Failed to show rewarded ad: $error');
            ad.dispose();
            // Navigate even if ad fails to show
            if (mounted) {
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
          },
        );

        // Show the ad
        await rewardedAd.show(
          onUserEarnedReward: (ad, reward) {
            print('User earned reward: ${reward.amount} ${reward.type}');
          },
        );
      } else {
        // If ad failed to load, navigate directly
        if (mounted) {
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
      }
    } catch (e) {
      print('Error showing rewarded ad: $e');
      // Dismiss loading indicator if still showing
      if (mounted) {
        Navigator.of(context).pop();
        // Navigate even if there's an error
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
    }
  }

  @override
  Widget build(BuildContext context) {
    double emi = _calculateEMI();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Loan Amount',
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
                  const SizedBox(height: 10),
                  // Amount Display
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'TOTAL AMOUNT',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_loanAmount.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                (Match m) => "${m[1]},",
                              )}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: const Color(0xFF10B981), // Green
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: const Color(0xFF10B981),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 4,
                      ),
                      overlayColor: const Color(0xFF10B981).withOpacity(0.2),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: _loanAmount,
                      min: _minLoan,
                      max: _maxLoan,
                      onChanged: (double value) {
                        setState(() {
                          _loanAmount = (value / 1000).round() * 1000.0;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹1,000', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                        Text('₹50,000', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Amount Presets Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildAmountPreset(1000),
                      _buildAmountPreset(10000),
                      _buildAmountPreset(20000),
                      _buildAmountPreset(50000),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Select Tenure Section
                  Text(
                    'SELECT TENURE',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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
                  // EMI Info Card (Gradient)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withOpacity(0.2), // Reddish
                          const Color(0xFF3B82F6).withOpacity(0.2), // Bluish
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMATED MONTHLY EMI',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹${emi.toStringAsFixed(0).replaceAllMapped(
                                        RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                                        (Match m) => "${m[1]},",
                                      )}',
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/mo',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Interest Rate', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text('${_interestRate.toStringAsFixed(0)}% p.a.', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Tenure', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text('$_selectedTenure Months', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Info points
                  _buildInfoPoint('Instant approval in 5 mins'),
                  const SizedBox(height: 12),
                  _buildInfoPoint('Minimal documentation required'),
                  const SizedBox(height: 12),
                  _buildInfoPoint('No hidden fees or charges'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showRewardedAdAndNavigate(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to KYC',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPreset(double amount) {
    bool isSelected = _loanAmount == amount;
    return GestureDetector(
      onTap: () => setState(() => _loanAmount = amount),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '₹${amount.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                  (Match m) => "${m[1]},",
                )}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
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
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '$months MONTHS',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
