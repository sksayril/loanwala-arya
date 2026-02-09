import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bank_verification_loader_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bank Details',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Text(
                                '100% SECURE & ENCRYPTED',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'We deposit your approved loan amount directly into this account. Please verify details carefully.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Bank Name Input
                      _buildLabel('Bank Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bankNameController,
                        decoration: _inputDecoration(
                          hintText: 'Enter your bank name',
                          suffixIcon: const Icon(Icons.account_balance_rounded, color: Color(0xFF7C3AED)),
                        ),
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter bank name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Account Number
                      _buildLabel('Account Number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: _inputDecoration(
                          hintText: '1234XXXXXXXX',
                          suffixIcon: const Icon(Icons.credit_card_rounded, color: Colors.grey),
                        ),
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter account number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Confirm Account Number
                      _buildLabel('Confirm Account Number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmAccountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          hintText: 'Re-enter account number',
                        ),
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                        validator: (value) {
                          if (value != _accountController.text) {
                            return 'Account numbers do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // IFSC Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('IFSC Code'),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Find IFSC?',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF7C3AED),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ifscController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _inputDecoration(
                          hintText: 'HDFC0001234',
                        ),
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Example: SBIN0001234 for SBI Delhi',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Confirmation Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isConfirmed,
                              onChanged: (value) {
                                setState(() {
                                  _isConfirmed = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF7C3AED),
                              side: BorderSide(color: Colors.grey[600]!, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I confirm that the bank details provided above are correct and the bank account belongs to me.',
                              style: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Verify Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0E1A),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _isConfirmed) {
                      // Process bank details
                      // Navigate to loader
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BankVerificationLoaderScreen(),
                        ),
                      );
                    } else if (!_isConfirmed) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please confirm the details', style: GoogleFonts.inter()),
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
                    'Verify Bank Account',
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
        color: Colors.grey[400],
        fontSize: 14,
        fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[800]!),
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
