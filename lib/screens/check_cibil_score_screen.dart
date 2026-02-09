import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cibil_loading_screen.dart';

class CheckCibilScreen extends StatefulWidget {
  const CheckCibilScreen({super.key});

  @override
  State<CheckCibilScreen> createState() => _CheckCibilScreenState();
}

class _CheckCibilScreenState extends State<CheckCibilScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7BFA),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7BFA),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
         // Format: DD/MM/YYYY
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Black-based background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check Credit Score',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading section
              Text(
                'Get your report',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your details as per PAN card to fetch your latest credit score securely.',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildFormFields(),
              const SizedBox(height: 24),
              _buildInfoPoints(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              _buildSecureBadge(),
              const SizedBox(height: 16),
              _buildTermsText(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoints() {
    return Column(
      children: [
        _buildInfoPoint(
          '100% Free & Secure Check',
          'We protect your data with bank-grade security.',
        ),
        const SizedBox(height: 16),
        _buildInfoPoint(
          'No impact on credit score',
          'Checking your own score is a soft inquiry.',
        ),
      ],
    );
  }

  Widget _buildInfoPoint(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981), // Green
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildCustomTextField(
          controller: _nameController,
          label: 'FULL NAME (AS PER PAN)',
          hint: 'e.g. Rahul Sharma',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        _buildPhoneField(),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _panController,
          label: 'PAN NUMBER',
          hint: 'ABCDE1234F',
          icon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _dobController,
          label: 'DATE OF BIRTH',
          hint: 'DD/MM/YYYY',
          icon: Icons.calendar_today_rounded,
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E), // Dark card background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 15),
              suffixIcon: readOnly
                  ? Icon(icon, color: Colors.grey[600], size: 20)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1F2E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOBILE NUMBER',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixText: '+91 ',
              prefixStyle: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              hintText: '98765 43210',
              hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1F2E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          children: [
            const TextSpan(text: 'By clicking, you agree to our '),
            TextSpan(
              text: 'Terms & Privacy Policy',
              style: GoogleFonts.inter(
                color: const Color(0xFF3B82F6), // Blue
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF3B82F6), // Blue button
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const CibilLoadingScreen()),
             );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get My CIBIL Score',
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
    );
  }

  Widget _buildSecureBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          '256-BIT SECURE ENCRYPTION',
          style: GoogleFonts.inter(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
