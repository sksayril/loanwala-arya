
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isEnglish = true;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  bool _isLoadingAd = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  VoidCallback? _onAdLoadedCallback;

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
              _navigateToHome();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('Interstitial ad failed to show: $error');
              ad.dispose();
              _navigateToHome();
            },
          );

          // If we were waiting for the ad, show it now
          if (_onAdLoadedCallback != null) {
            _onAdLoadedCallback!();
            _onAdLoadedCallback = null;
          }
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
            print('Retrying ad load (attempt $_retryCount/$_maxRetries)...');
            Future.delayed(Duration(seconds: _retryCount * 2), () {
              if (mounted) {
                _loadInterstitialAd();
              }
            });
          } else {
            // If we were waiting and ad failed after all retries, navigate to home
            if (_isLoading) {
              setState(() {
                _isLoading = false;
              });
              _navigateToHome();
            }
          }
        },
      ),
    );
  }

  void _navigateToHome() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showAd() {
    if (_interstitialAd != null && _isAdLoaded) {
      _interstitialAd!.show();
    } else {
      // If ad is still not available, navigate to home
      _navigateToHome();
    }
  }

  void _handleGetStarted() {
    if (_isLoading || _isLoadingAd) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
      _isLoadingAd = true;
    });

    if (_isAdLoaded && _interstitialAd != null) {
      // Ad is ready, show it immediately
      setState(() {
        _isLoadingAd = false;
      });
      _showAd();
    } else {
      // Ad is not loaded yet, wait for it
      _onAdLoadedCallback = () {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          _showAd();
        }
      };
      
      // If ad is not loading, start loading it
      if (!_isAdLoaded && _retryCount < _maxRetries) {
        _loadInterstitialAd();
      }
      
      // Set a timeout in case ad takes too long (15 seconds)
      Future.delayed(const Duration(seconds: 15), () {
        if (_isLoading && mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingAd = false;
          });
          _navigateToHome();
        }
      });
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Light background
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top Illustration
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Image.asset(
                        'assets/PhotoRoom-20260130_140325.png',
                        height: MediaQuery.of(context).size.height * 0.45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Welcome Text
                    Text(
                      'Welcome To Loan Wala',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Instant loans for your family\'s needs.\nTrusted by millions of Indians.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Language Toggle
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE8F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isEnglish = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isEnglish ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isEnglish ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'English',
                                    style: GoogleFonts.inter(
                                      fontWeight: isEnglish ? FontWeight.bold : FontWeight.normal,
                                      color: isEnglish ? const Color(0xFF6C3EE8) : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isEnglish = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isEnglish ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: !isEnglish ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'हिंदी',
                                    style: GoogleFonts.inter(
                                      fontWeight: !isEnglish ? FontWeight.bold : FontWeight.normal,
                                      color: !isEnglish ? const Color(0xFF6C3EE8) : Colors.black54,
                                    ),
                                  ),
                                ),
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
            
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C3EE8), // Purple color from image
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 8,
                        shadowColor: const Color(0xFF6C3EE8).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: const Color(0xFF6C3EE8).withOpacity(0.6),
                      ),
                      child: _isLoading
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Started',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms and Privacy
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our\n',
                      children: [
                        TextSpan(
                          text: 'Terms of Service & Privacy Policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.4),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C3EE8)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
