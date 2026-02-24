import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kyc_verification_screen.dart';
import '../services/loan_data_service.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final double loanAmount;
  final int tenure;
  final String loanType;

  const PersonalDetailsScreen({
    super.key,
    required this.loanAmount,
    required this.tenure,
    required this.loanType,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  String? _selectedEmploymentType;
  final LoanDataService _loanDataService = LoanDataService();

  final List<String> _employmentTypes = [
    'Salaried',
    'Self-Employed Business',
    'Self-Employed Professional',
    'Student',
    'Retired',
    'Homemaker',
  ];

  @override
  void initState() {
    super.initState();
    // Save loan details from widget parameters
    _loanDataService.updateLoanDetails(
      loanAmount: widget.loanAmount,
      tenure: widget.tenure,
      loanType: widget.loanType,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personal Details',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Bar or Step Indicator could go here

                      Text(
                        "Let's get to know you",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please enter your details exactly as they appear on your PAN card for quick verification.',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name Field
                      _buildLabel('FULL NAME (AS PER PAN)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(hintText: 'e.g. Rahul Sharma'),
                        style: GoogleFonts.inter(fontSize: 16),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      _buildLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(hintText: 'e.g. john.doe@example.com'),
                        style: GoogleFonts.inter(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Mobile Number Field
                      _buildLabel('MOBILE NUMBER'),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Image.network(
                                  'https://flagcdn.com/w40/in.png',
                                  width: 24,
                                  height: 16,
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.flag, size: 20, color: Colors.orange),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+91',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: _inputDecoration(
                                hintText: '98765 43210',
                              ).copyWith(counterText: ""),
                              style: GoogleFonts.inter(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.length != 10) {
                                  return 'Enter a valid 10-digit number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // PAN Field
                      _buildLabel('PERMANENT ACCOUNT NUMBER (PAN)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _panController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 10,
                        decoration: _inputDecoration(
                          hintText: 'ABCDE1234F',
                        ).copyWith(counterText: ""),
                        style: GoogleFonts.inter(fontSize: 16, letterSpacing: 1.0),
                        validator: (value) {
                          if (value == null || value.length != 10) {
                            return 'Enter a valid PAN number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'We verify this with NSDL securely',
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Employment Type Dropdown
                      _buildLabel('EMPLOYMENT TYPE'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedEmploymentType,
                            hint: Text(
                              'Select your employment type',
                              style: GoogleFonts.inter(color: Colors.grey[400]),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                            items: _employmentTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: GoogleFonts.inter(color: Colors.black87),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedEmploymentType = newValue;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Security Note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF1E8E3E)),
                          const SizedBox(width: 8),
                          Text(
                            'Your data is 256-bit encrypted & secure',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Next Button
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _selectedEmploymentType != null) {
                      // Save personal details to service
                      _loanDataService.updatePersonalDetails(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phoneNumber: _mobileController.text.trim(),
                        panNumber: _panController.text.trim(),
                        employmentType: _selectedEmploymentType,
                      );
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KycVerificationScreen(),
                        ),
                      );
                    } else if (_selectedEmploymentType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text('Please select employment type', style: GoogleFonts.inter()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
        color: Colors.grey[700],
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
