import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  
  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoadingAd = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    // Wait a bit for MobileAds to be fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadInterstitialAd();
      }
    });
  }

  void _loadInterstitialAd() {
    if (!mounted) return;
    
    // Dispose previous ad if exists
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3422720384917984/4884822987',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          
          setState(() {
            _interstitialAd = ad;
            _isAdLoaded = true;
            _retryCount = 0; // Reset retry count on success
          });
          
          // Set up ad event callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _navigateToLoadingScreen();
              // Load next ad after a delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _loadInterstitialAd();
                }
              });
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('Interstitial ad failed to show: $error');
              ad.dispose();
              _navigateToLoadingScreen();
              // Load next ad after a delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _loadInterstitialAd();
                }
              });
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
          if (!mounted) return;
          
          setState(() {
            _isAdLoaded = false;
            _interstitialAd = null;
          });
          
          // Retry loading if we haven't exceeded max retries
          if (_retryCount < _maxRetries) {
            _retryCount++;
            print('Retrying interstitial ad load (attempt $_retryCount/$_maxRetries)...');
            Future.delayed(Duration(seconds: _retryCount * 2), () {
              if (mounted) {
                _loadInterstitialAd();
              }
            });
          }
        },
      ),
    );
  }

  void _navigateToLoadingScreen() {
    if (mounted) {
      setState(() {
        _isLoadingAd = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CibilLoadingScreen()),
      );
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the Terms & Conditions')),
        );
      }
      return;
    }

    if (_isLoadingAd) return; // Prevent multiple clicks

    setState(() {
      _isLoadingAd = true;
    });

    if (_isAdLoaded && _interstitialAd != null) {
      // Ad is ready, show it
      try {
        _interstitialAd!.show();
        setState(() {
          _isLoadingAd = false;
        });
      } catch (e) {
        print('Error showing interstitial ad: $e');
        // If showing fails, navigate directly
        _navigateToLoadingScreen();
        // Try to load ad for next time
        _loadInterstitialAd();
      }
    } else {
      // Ad is not loaded, try loading once more, then navigate
      if (_retryCount < _maxRetries) {
        _loadInterstitialAd();
        // Wait a bit for ad to load
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isAdLoaded && _interstitialAd != null) {
            try {
              _interstitialAd!.show();
              setState(() {
                _isLoadingAd = false;
              });
            } catch (e) {
              _navigateToLoadingScreen();
            }
          } else {
            // Still not loaded, navigate directly
            _navigateToLoadingScreen();
          }
        });
      } else {
        // Already tried, navigate directly
        _navigateToLoadingScreen();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _dobController.dispose();
    _interstitialAd?.dispose();
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check CIBIL Score',
          style: GoogleFonts.inter(
            color: Colors.black,
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
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _buildFormFields(),
              const SizedBox(height: 16),
              _buildTermsCheckbox(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              _buildSecureBadge(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF2E7BFA)),
                      const SizedBox(width: 4),
                      Text(
                        '100% Secure',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2E7BFA),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Free Credit Report',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get detailed insights with no impact on your score.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular gauge icon placeholder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.speed_rounded, 
              size: 40,
              color: Color(0xFF2E7BFA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name (as per PAN)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('e.g. Rahul Sharma'),
            style: GoogleFonts.inter(),
          ),
          
          const SizedBox(height: 20),
          _buildLabel('Mobile Number'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('98765 43210', prefix: '+91'),
             style: GoogleFonts.inter(),
          ),

          const SizedBox(height: 20),
          _buildLabel('PAN Number'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            decoration: _inputDecoration('ABCDE1234F', suffixIcon: Icons.badge_outlined),
             style: GoogleFonts.inter(),
          ),

          const SizedBox(height: 20),
          _buildLabel('Date of Birth'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: _inputDecoration('dd/mm/yyyy', suffixIcon: Icons.calendar_today_rounded),
             style: GoogleFonts.inter(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7BFA)),
      ),
      prefixIcon: prefix != null ? Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix,
              style: GoogleFonts.inter(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[400]) : null,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: const Color(0xFF2E7BFA),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], height: 1.5),
              children: [
                const TextSpan(text: 'I hereby appoint LoanSahay as my authorized representative to receive my credit information from CIBIL. I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2E7BFA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2E7BFA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoadingAd ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7BFA),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFF2E7BFA).withOpacity(0.6),
        ),
        child: _isLoadingAd
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading...',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Check CIBIL Score',
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
        const Icon(Icons.lock_rounded, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '256-BIT SECURE ENCRYPTION',
          style: GoogleFonts.inter(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
