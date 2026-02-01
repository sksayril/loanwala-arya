
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoanDetailModal extends StatelessWidget {
  const LoanDetailModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 100), // Bottom padding for button
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00ACC1), // Cyan/Teal color from image
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: NetworkImage('https://cdn-icons-png.flaticon.com/512/2534/2534204.png'), // Placeholder or use Icon
                                // Using a stylized Rupee icon if available, or just a container
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ram Fincorp',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get ₹10,000 Loan',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Features Section
                      _buildSectionHeader('Features', Icons.thumb_up_rounded, Colors.amber),
                      const SizedBox(height: 16),
                      _buildCheckItem('100% Digital & Paperless Process'),
                      _buildCheckItem('No Collateral Required'),
                      _buildCheckItem('Flexible Tenure: 12 to 60 Months'),
                      _buildCheckItem('Loan Amount: ₹1,000 to ₹10,00,000 (Based on Eligibility)'),
                      _buildCheckItem('Minimal Documentation'),
                      _buildCheckItem('Quick & Easy Disbursal'),
                      
                      const SizedBox(height: 30),

                      // Eligibility Criteria
                      _buildSectionHeader('Eligibility Criteria', Icons.thumb_up_rounded, Colors.amber),
                      const SizedBox(height: 16),
                      _buildCheckItem('Age: 18 to 58 Year', isCheck: false),
                      _buildCheckItem('Citizen: Indian', isCheck: false),
                      _buildCheckItem('Employment Type: Salaried/Self-employed', isCheck: false),
                      
                      const SizedBox(height: 16),
                      Text(
                        'Income:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '→ Salaried: 18000 per month',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Bottom Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Apply Now
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6), // Light Blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'APPLY NOW',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text, {bool isCheck = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: isCheck 
              ? const Icon(Icons.check_box, color: Color(0xFF7CB342), size: 22) // Light Green
              : const Icon(Icons.check, color: Color(0xFF546E7A), size: 22), // Blue Grey
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
