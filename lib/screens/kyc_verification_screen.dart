import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bank_details_screen.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  String _residenceType = 'Owned'; // 'Owned' or 'Rented'
  String? _selectedState;

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi'
  ];

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

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
          'Address Details',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepDot(false),
                      const SizedBox(width: 8),
                      _buildStepLine(true),
                      const SizedBox(width: 8),
                      _buildStepDot(false),
                      const SizedBox(width: 8),
                      _buildStepDot(false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 2 of 4',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where do you live?',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Residence Type
                    _buildLabel('Residence Type'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResidenceTypeButton(
                            icon: Icons.home_rounded,
                            label: 'Owned',
                            isSelected: _residenceType == 'Owned',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildResidenceTypeButton(
                            icon: Icons.business_center_rounded,
                            label: 'Rented',
                            isSelected: _residenceType == 'Rented',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // House No Field
                    _buildLabel('House No. / Building Name'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _houseController,
                      decoration: _inputDecoration(
                        hintText: 'e.g. Flat 402, Sunshine Apts',
                      ),
                      style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Street Field
                    _buildLabel('Street / Colony'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _streetController,
                      decoration: _inputDecoration(
                        hintText: 'e.g. MG Road, Indiranagar',
                      ),
                      style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // City and Pincode Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('City'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _cityController,
                                decoration: _inputDecoration(
                                  hintText: 'New York',
                                ),
                                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Pincode'),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  hintText: '10001',
                                ),
                                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // State Dropdown
                    _buildLabel('State'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedState,
                          dropdownColor: const Color(0xFF1A1F2E),
                          hint: Text(
                            'Select State',
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                          items: _states.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(
                                state,
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedState = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Security Note
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Your address details are encrypted and securely stored.',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => const BankDetailsScreen(),
                       ),
                     );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6), // Blue button
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
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 24,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildResidenceTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _residenceType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.grey[400],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1A1F2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }
}
