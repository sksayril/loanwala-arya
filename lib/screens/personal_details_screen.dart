import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'kyc_verification_screen.dart';

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
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  String? _selectedEmploymentType;

  final List<String> _employmentTypes = [
    'Salaried',
    'Self-Employed Business',
    'Self-Employed Professional',
    'Student',
    'Retired',
    'Homemaker',
  ];

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isLoadingAd = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    // Wait a bit for MobileAds to be fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadRewardedAd();
      }
    });
  }

  void _loadRewardedAd() {
    if (!mounted) return;
    
    // Dispose previous ad if exists
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdLoaded = false;

    RewardedAd.load(
      adUnitId: 'ca-app-pub-3422720384917984/3571741310',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            _retryCount = 0; // Reset retry count on success
          });
          
          // Set up ad event callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              _navigateToKycScreen();
              // Load next ad after a delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _loadRewardedAd();
                }
              });
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              print('Rewarded ad failed to show: $error');
              ad.dispose();
              _navigateToKycScreen();
              // Load next ad after a delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _loadRewardedAd();
                }
              });
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Rewarded ad failed to load: $error');
          if (!mounted) return;
          
          setState(() {
            _isRewardedAdLoaded = false;
            _rewardedAd = null;
          });
          
          // Retry loading if we haven't exceeded max retries
          if (_retryCount < _maxRetries) {
            _retryCount++;
            print('Retrying rewarded ad load (attempt $_retryCount/$_maxRetries)...');
            Future.delayed(Duration(seconds: _retryCount * 2), () {
              if (mounted) {
                _loadRewardedAd();
              }
            });
          }
        },
      ),
    );
  }

  void _navigateToKycScreen() {
    if (mounted) {
      setState(() {
        _isLoadingAd = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycVerificationScreen(),
        ),
      );
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate() || _selectedEmploymentType == null) {
      if (_selectedEmploymentType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select employment type', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_isLoadingAd) return; // Prevent multiple clicks

    setState(() {
      _isLoadingAd = true;
    });

    if (_isRewardedAdLoaded && _rewardedAd != null) {
      // Ad is ready, show it
      try {
        _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            // User earned reward
            print('User earned reward: ${reward.amount} ${reward.type}');
          },
        );
        // Reset loading state as ad is showing
        setState(() {
          _isLoadingAd = false;
        });
      } catch (e) {
        print('Error showing rewarded ad: $e');
        // If showing fails, navigate directly
        _navigateToKycScreen();
        // Try to load ad for next time
        _loadRewardedAd();
      }
    } else {
      // Ad is not loaded, try loading once more, then navigate
      if (_retryCount < _maxRetries) {
        _loadRewardedAd();
        // Wait a bit for ad to load
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isRewardedAdLoaded && _rewardedAd != null) {
            try {
              _rewardedAd!.show(
                onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                  print('User earned reward: ${reward.amount} ${reward.type}');
                },
              );
              setState(() {
                _isLoadingAd = false;
              });
            } catch (e) {
              _navigateToKycScreen();
            }
          } else {
            // Still not loaded, navigate directly
            _navigateToKycScreen();
          }
        });
      } else {
        // Already tried, navigate directly
        _navigateToKycScreen();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _panController.dispose();
    _rewardedAd?.dispose();
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
                  onPressed: (_isLoadingAd) ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFF7C3AED).withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
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
                      : Text(
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
