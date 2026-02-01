import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/loan_api_service.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class LoanDetailsScreen extends StatelessWidget {
  final LoanApiData loan;

  const LoanDetailsScreen({
    super.key,
    required this.loan,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Loan Details',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank Logo and Info
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: loan.bankLogo != null && loan.bankLogo!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            loan.bankLogo!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_balance,
                                color: Colors.grey.shade600,
                                size: 40,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.account_balance,
                          color: Colors.grey.shade600,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.companyName ?? 'Financial Institution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loan.title ?? 'Loan',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Description
            if (loan.description != null && loan.description!.isNotEmpty) ...[
              Text(
                loan.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
            ],
            
            // Key Details
            _buildDetailCard(
              context,
              themeProvider,
              'Interest Rate',
              loan.interestRate ?? 'N/A',
              Icons.percent,
              Colors.green,
            ),
            const SizedBox(height: 12),
            if (loan.category != null)
              _buildDetailCard(
                context,
                themeProvider,
                'Category',
                loan.category!.name ?? 'N/A',
                Icons.category,
                Colors.purple,
              ),
            const SizedBox(height: 30),
            
            // Apply Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (loan.url != null && loan.url!.isNotEmpty) {
                    _launchURL(loan.url!, context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application URL not available'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_browser, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'APPLY NOW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    ThemeProvider themeProvider,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
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
      
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
