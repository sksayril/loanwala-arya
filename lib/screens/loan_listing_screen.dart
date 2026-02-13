import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/loan_api_service.dart';
import '../services/ad_helper.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/skeleton_loader.dart';
import 'loan_details_screen.dart';

class LoanListingScreen extends StatefulWidget {
  final String loanType;
  final String amountRange;
  final Color primaryColor;
  final String? initialCategoryId;

  const LoanListingScreen({
    super.key,
    required this.loanType,
    required this.amountRange,
    required this.primaryColor,
    this.initialCategoryId,
  });

  @override
  State<LoanListingScreen> createState() => _LoanListingScreenState();
}

class _LoanListingScreenState extends State<LoanListingScreen> {
  List<LoanApiData> _loans = [];
  List<LoanCategory> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;
  int _totalCount = 0;
  
  // Apply Now button visibility
  bool _isApplyNowActive = false;
  bool _isCheckingApplyNow = true;

  @override
  void initState() {
    super.initState();
    // Set initial category ID if provided
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
    }
    _fetchLoans();
    _loadCategories();
    // Check Apply Now status
    _checkApplyNowStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await LoanApiService.fetchCategoriesFromApi();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Silently fail - categories are optional
      // Try fallback method
      try {
        final categories = await LoanApiService.fetchCategories();
        if (mounted) {
          setState(() {
            _categories = categories;
          });
        }
      } catch (e2) {
        // Categories are optional, continue without them
      }
    }
  }

  Future<void> _fetchLoans() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      LoanApiResponse apiResponse;
      
      // Use category-specific endpoint if categoryId is provided
      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        apiResponse = await LoanApiService.fetchLoansByCategoryId(_selectedCategoryId!);
      } else {
        apiResponse = await LoanApiService.fetchActiveLoans();
      }
      
      // Filter only active loans
      final loans = apiResponse.loans
          .where((loan) => loan.isActive ?? true) // Only show active loans
          .toList();

      if (mounted) {
        setState(() {
          _loans = loans;
          _totalCount = apiResponse.count;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  // Check Apply Now status from API
  Future<void> _checkApplyNowStatus() async {
    try {
      final status = await LoanApiService.checkApplyNowStatus();
      if (mounted) {
        setState(() {
          _isApplyNowActive = status.isActive;
          _isCheckingApplyNow = false;
        });
      }
    } catch (e) {
      print('Error checking Apply Now status: $e');
      // Default to showing button if API fails
      if (mounted) {
        setState(() {
          _isApplyNowActive = true;
          _isCheckingApplyNow = false;
        });
      }
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _fetchLoans();
  }

  Future<void> _refreshLoans() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchLoans();
  }

  Future<void> _launchURL(String url) async {
    try {
      // Ensure URL has a scheme (http:// or https://)
      String formattedUrl = url.trim();
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      
      final Uri uri = Uri.parse(formattedUrl);
      
      // Try to launch the URL directly
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRewardedAdAndNavigate(BuildContext context, LoanApiData loan) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Load the rewarded ad
      final rewardedAd = await AdHelper.loadRewardedAd();
      
      if (!mounted) return;
      
      // Dismiss loading indicator
      Navigator.of(context).pop();

      if (rewardedAd != null) {
        // Show the rewarded ad
        rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            // Navigate to LoanDetailsScreen after ad is dismissed
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoanDetailsScreen(loan: loan),
                ),
              );
            }
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('Failed to show rewarded ad: $error');
            ad.dispose();
            // Navigate even if ad fails to show
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoanDetailsScreen(loan: loan),
                ),
              );
            }
          },
        );

        // Show the ad
        await rewardedAd.show(
          onUserEarnedReward: (ad, reward) {
            print('User earned reward: ${reward.amount} ${reward.type}');
          },
        );
      } else {
        // If ad failed to load, navigate directly
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoanDetailsScreen(loan: loan),
            ),
          );
        }
      }
    } catch (e) {
      print('Error showing rewarded ad: $e');
      // Dismiss loading indicator if still showing
      if (mounted) {
        Navigator.of(context).pop();
        // Navigate even if there's an error
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanDetailsScreen(loan: loan),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Black-based background matching home screen
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A), // Dark background matching home screen
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Approved Offers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _loans.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshLoans,
                      color: widget.primaryColor,
                      child: ListView(
                        children: [
                          // Congratulations Section
                          _buildCongratulationsSection(themeProvider),
                          const SizedBox(height: 16),
                          // Filter Buttons
                          _buildFilterButtons(themeProvider),
                          const SizedBox(height: 16),
                          // Loan Cards List
                          ...List.generate(_loans.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: index == 0 ? 0 : 16,
                                bottom: index == _loans.length - 1 ? 16 : 0,
                              ),
                              child: _buildApprovedOfferCard(_loans[index], index),
                            );
                          }),
                          // Footer with Security Info
                          _buildFooter(themeProvider),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildApprovedOfferCard(LoanApiData loan, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Determine badge for each card
    String? badge;
    Color? badgeColor;
    Color? badgeTextColor;
    if (index == 0) {
      badge = 'BEST VALUE';
      badgeColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
    } else if (index == 1) {
      badge = 'INSTANT DISBURSAL';
      badgeColor = const Color(0xFFFFF3E0);
      badgeTextColor = const Color(0xFFE65100);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E26), // Dark card background matching home screen
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank info and badge
          Row(
            children: [
              // Bank logo - Circular
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: _buildBankLogo(loan.bankLogo, size: 50),
                ),
              ),
              const SizedBox(width: 12),
              // Bank name and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.companyName ?? 'Financial Institution',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loan.title ?? 'Loan',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              // Badge
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // SANCTIONED AMOUNT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SANCTIONED AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${_getSanctionedAmount(index)}',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // INTEREST RATE and TENURE in Row
          Row(
            children: [
              // Interest Rate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTEREST RATE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_down_rounded,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${loan.interestRate ?? '10.5'}% p.a.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tenure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TENURE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_getTenure(index)} months',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Additional Features
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 18),
              const SizedBox(width: 10),
              Text(
                _getFeatureText(index),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.grey[400], size: 18),
              const SizedBox(width: 10),
              Text(
                'Proc. Fee: ${_getProcessingFee(index)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Proceed button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showRewardedAdAndNavigate(context, loan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2E4E),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed', 
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoanCard(LoanApiData loan) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accent = widget.primaryColor;
    final accentSoft = _getCardAccentColor(accent);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate directly to loan details (ads disabled)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoanDetailsScreen(loan: loan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentSoft.withOpacity(0.55),
                themeProvider.cardBackground,
              ],
            ),
            border: Border.all(
              color: accentSoft.withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ensure logo has enough space and is not constrained
                    SizedBox(
                      height: 72,
                      child: Center(
                        child: _buildBankLogo(loan.bankLogo, size: 68),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        (loan.companyName ?? 'Financial Institution').toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        loan.title ?? 'Loan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (loan.category?.name != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        loan.category!.name!,
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Apply Now Button (only show if isActive is true)
              if (!_isCheckingApplyNow && _isApplyNowActive)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20), // Pill shape
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getGradientColors(widget.primaryColor),
                        ),
                        boxShadow: [
                          // Neumorphic shadows - light highlight on top-left
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(-2, -2),
                            spreadRadius: 0,
                          ),
                          // Dark shadow on bottom-right - based on category color
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                            spreadRadius: 0,
                          ),
                          // Soft diffused shadow - based on category color
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate directly to loan details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoanDetailsScreen(loan: loan),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                          minimumSize: const Size(double.infinity, 34),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Pill shape
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        child: const Text(
                          'APPLY NOW',
                          style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardAccentColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + 0.25).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Generate gradient colors based on primary color
  List<Color> _getGradientColors(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    
    // Lighter version (top-left)
    final lighter = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    
    // Original color (middle)
    final medium = primaryColor;
    
    // Darker version (bottom-right)
    final darker = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    
    return [lighter, medium, darker];
  }

  // Build Congratulations Section
  Widget _buildCongratulationsSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E26), // Dark card background matching home screen
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Confetti Icon
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Color(0xFF4CAF50),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations!',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your excellent credit score of 780, you have unlocked exclusive offers.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Filter Buttons
  Widget _buildFilterButtons(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              icon: Icons.percent_rounded,
              label: 'Lowest Interest',
              isSelected: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterButton(
              icon: Icons.currency_rupee_rounded,
              label: 'Highest Amount',
              isSelected: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1A2E4E)
            : const Color(0xFF1C1E26).withOpacity(0.8), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Colors.white.withOpacity(0.1)) : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // Build Footer
  Widget _buildFooter(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A), // Black background matching home screen
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                '100% Secure',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 24),
              Icon(
                Icons.account_balance,
                size: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'RBI Regulated',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Interest rates and loan amounts are subject to final verification and documentation by the respective lending partners.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for static content
  String _getSanctionedAmount(int index) {
    switch (index) {
      case 0:
        return '5,00,000';
      case 1:
        return '3,50,000';
      case 2:
        return '2,00,000';
      default:
        return '1,00,000';
    }
  }

  int _getTenure(int index) {
    switch (index) {
      case 0:
        return 60;
      case 1:
        return 48;
      case 2:
        return 36;
      default:
        return 24;
    }
  }

  String _getFeatureText(int index) {
    switch (index) {
      case 0:
        return 'Zero Pre-closure charges';
      case 1:
        return 'Disbursal in 2 hours';
      default:
        return 'Flexible repayment options';
    }
  }

  String _getProcessingFee(int index) {
    switch (index) {
      case 0:
        return '₹999 + GST';
      case 1:
        return '₹1,499';
      case 2:
        return '₹499';
      default:
        return '₹999';
    }
  }

  Widget _buildFeatureRow(IconData icon, String text, Color iconColor, ThemeProvider themeProvider) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Provider.of<ThemeProvider>(context, listen: false).textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return const SkeletonLoanCard();
      },
    );
  }

  Widget _buildErrorState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Loans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchLoans,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: themeProvider.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Loans Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no active loans available at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshLoans,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onCategorySelected(selected ? categoryId : null);
      },
      selectedColor: widget.primaryColor.withOpacity(0.2),
      checkmarkColor: widget.primaryColor,
      backgroundColor: themeProvider.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? widget.primaryColor : themeProvider.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? widget.primaryColor : themeProvider.borderColor,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }

  Widget _buildBankLogo(String? bankLogoUrl, {double size = 64}) {
    final iconSize = size * 0.5;
    return bankLogoUrl != null && bankLogoUrl.isNotEmpty
        ? SizedBox(
            width: size,
            height: size,
            child: Image.network(
              bankLogoUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Show default icon if image fails to load
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: widget.primaryColor,
                    size: iconSize,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: iconSize * 0.75,
                    height: iconSize * 0.75,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          )
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.account_balance,
              color: widget.primaryColor,
              size: iconSize,
            ),
          );
  }
}
