import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
              _navigateToVerificationLoader();
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
              _navigateToVerificationLoader();
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

  void _navigateToVerificationLoader() {
    if (mounted) {
      setState(() {
        _isLoadingAd = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BankVerificationLoaderScreen(),
        ),
      );
    }
  }

  void _handleVerify() {
    if (!_formKey.currentState!.validate() || !_isConfirmed) {
      if (!_isConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please confirm the details', style: GoogleFonts.inter()),
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
        _navigateToVerificationLoader();
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
              _navigateToVerificationLoader();
            }
          } else {
            // Still not loaded, navigate directly
            _navigateToVerificationLoader();
          }
        });
      } else {
        // Already tried, navigate directly
        _navigateToVerificationLoader();
      }
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
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
          'Bank Details',
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
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1), // Light green
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFB2DFDB)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF00897B)),
                              const SizedBox(width: 8),
                              Text(
                                '100% SECURE & ENCRYPTED',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF00695C),
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
                          color: Colors.grey[600],
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
                        style: GoogleFonts.inter(fontSize: 16),
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
                        style: GoogleFonts.inter(fontSize: 16),
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
                        style: GoogleFonts.inter(fontSize: 16),
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
                        style: GoogleFonts.inter(fontSize: 16),
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
                                color: Colors.grey[700],
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
                  onPressed: _isLoadingAd ? null : _handleVerify,
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
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
