
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoanOffersScreen extends StatefulWidget {
  const LoanOffersScreen({super.key});

  @override
  State<LoanOffersScreen> createState() => _LoanOffersScreenState();
}

class _LoanOffersScreenState extends State<LoanOffersScreen> {
  int _selectedToggleIndex = 0; // 0 for Lowest Interest, 1 for Highest Amount

  @override
  Widget build(BuildContext context) {
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
          'Loan Offers',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Congratulations Banner
            _buildCongratsBanner(),
            const SizedBox(height: 24),
            
            // Toggle Section
            _buildToggleSection(),
            const SizedBox(height: 24),

            // Loan Offers List
            _buildLoanOfferCard(
              providerName: 'Ram Fincorp',
              providerSub: 'Get ₹10,000 Loan',
              tag: 'BEST VALUE',
              tagColor: const Color(0xFFE8F5E9),
              tagTextColor: const Color(0xFF2E7D32),
              amount: '₹5,00,000',
              interestRate: '3% p.a.',
              tenure: '60 months',
              features: [
                'Zero Pre-closure charges',
                'Proc. Fee: ₹999 + GST',
              ],
              icon: Icons.currency_rupee_rounded,
              iconBgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF1976D2),
            ),
            const SizedBox(height: 20),
            _buildLoanOfferCard(
              providerName: 'Poonawalla fincorp',
              providerSub: 'Home Loan',
              tag: 'INSTANT DISBURSAL',
              tagColor: const Color(0xFFFFF3E0),
              tagTextColor: const Color(0xFFE65100),
              amount: '₹3,50,000',
              interestRate: '7% p.a.',
              tenure: '48 months',
              features: [
                'Disbursal in 2 hours',
                'Proc. Fee: ₹1,499',
              ],
              icon: Icons.account_balance_rounded,
              iconBgColor: const Color(0xFFF5F5F5),
              iconColor: const Color(0xFF424242),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCongratsBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded, color: Color(0xFF10B981), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations!',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your excellent credit score of 780, you have unlocked exclusive offers.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              index: 0,
              label: 'Lowest Interest',
              icon: Icons.percent_rounded,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              index: 1,
              label: 'Highest Amount',
              icon: Icons.currency_rupee_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({required int index, required String label, required IconData icon}) {
    bool isSelected = _selectedToggleIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedToggleIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A2E4E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanOfferCard({
    required String providerName,
    required String providerSub,
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String amount,
    required String interestRate,
    required String tenure,
    required List<String> features,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider Info Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor.withOpacity(0.2)),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      providerSub,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tagColor.withOpacity(0.2)),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    color: tagTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sanctioned Amount
          Text(
            'SANCTIONED AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Rate and Tenure Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTEREST RATE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.trending_down_rounded, color: Color(0xFF10B981), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          interestRate,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TENURE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.grey, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          tenure,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Features
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  feature.startsWith('Proc. Fee') ? Icons.info_outline_rounded : Icons.check_circle_rounded,
                  size: 18,
                  color: feature.startsWith('Proc. Fee') ? Colors.grey[500] : const Color(0xFF10B981),
                ),
                const SizedBox(width: 10),
                Text(
                  feature,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

