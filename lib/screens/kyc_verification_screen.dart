import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'bank_details_screen.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _addressController = TextEditingController();

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
              _navigateToBankDetails();
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
              _navigateToBankDetails();
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

  void _navigateToBankDetails() {
    if (mounted) {
      setState(() {
        _isLoadingAd = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BankDetailsScreen(),
        ),
      );
    }
  }

  void _handleContinue() {
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
        _navigateToBankDetails();
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
              _navigateToBankDetails();
            }
          } else {
            // Still not loaded, navigate directly
            _navigateToBankDetails();
          }
        });
      } else {
        // Already tried, navigate directly
        _navigateToBankDetails();
      }
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KYC Verification',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Progress/Step Indicator (Optional, based on flow)
                    
                    Text(
                      'Identity Verification',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please provide your official government documents to process your loan application securely.',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Aadhaar Number Field
                    _buildLabel('Aadhaar Number'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _aadhaarController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hintText: '1234 5678 9012',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2E7BFA)),
                          onPressed: () {
                            // TODO: Implement scanner
                          },
                        ),
                      ),
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // PAN Card Number Field
                    _buildLabel('PAN Card Number'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _panController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(
                        hintText: 'ABCDE1234F',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2E7BFA)),
                          onPressed: () {
                            // TODO: Implement camera
                          },
                        ),
                      ),
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Address Section
                    _buildLabel('Full Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        hintText: 'Enter your full residential address',
                        suffixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF2E7BFA)),
                      ),
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // Security Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF), // Light blue bg
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD6E4FF)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded, color: Color(0xFF2E7BFA), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data is 100% safe & encrypted with 256-bit SSL.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1E3A8A), // Dark blue text
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Continue Button
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
                  onPressed: _isLoadingAd ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7BFA), // Blue button
                    disabledBackgroundColor: const Color(0xFF2E7BFA).withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                          'Continue',
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
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: Color(0xFF2E7BFA), width: 2),
      ),
    );
  }
}
