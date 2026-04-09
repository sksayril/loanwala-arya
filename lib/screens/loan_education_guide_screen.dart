import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// General loan education — shown after the loan application quiz (from Apply for Loan cards).
class LoanEducationGuideScreen extends StatelessWidget {
  const LoanEducationGuideScreen({
    super.key,
    required this.loanType,
    required this.loanIcon,
    required this.accentColor,
    required this.iconBgColor,
    required this.cardBgColor,
  });

  final String loanType;
  final IconData loanIcon;
  final Color accentColor;
  final Color iconBgColor;
  final Color cardBgColor;

  static const Color _navy = Color(0xFF1A2744);
  static const Color _text = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Understanding Loans',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A2744),
                      Color(0xFF243B5C),
                      Color(0xFF1E3250),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _LoanGuideHeader(
                loanType: loanType,
                loanIcon: loanIcon,
                accent: accentColor,
                iconBg: iconBgColor,
                cardTint: cardBgColor,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _emojiTitle('📌', 'What is a Loan?'),
                _p(
                  'A loan is money that you borrow from a bank, financial institution, or lender and promise to repay later with interest.',
                ),
                _p(
                  'The borrower must repay the loan in EMIs (Equated Monthly Installments) over a fixed time period.',
                ),
                _subheading('Example:'),
                _exampleBox(
                  'If you take a loan of ₹1,00,000 with 10% interest for 2 years, you will repay it in monthly installments including interest.',
                ),
                _p(
                  'Loans are usually provided by banks like State Bank of India, HDFC Bank, and ICICI Bank.',
                ),
                const SizedBox(height: 20),
                _emojiTitle('🏦', 'Types of Loans in India'),
                _p(
                  'There are many types of loans available depending on your needs.',
                ),
                _loanTypeBlock(
                  emoji: '🏠',
                  title: 'Home Loan',
                  intro:
                      'A home loan is taken to buy or build a house.',
                  features: const [
                    'Large loan amount',
                    'Long repayment period (10–30 years)',
                    'Lower interest rates compared to other loans',
                  ],
                ),
                _loanTypeBlock(
                  emoji: '🚗',
                  title: 'Car Loan',
                  intro:
                      'A car loan helps you purchase a new or used vehicle.',
                  features: const [
                    'Medium loan amount',
                    'Repayment period usually 3–7 years',
                  ],
                ),
                _loanTypeBlock(
                  emoji: '💳',
                  title: 'Personal Loan',
                  intro:
                      'A personal loan is used for any personal expense like travel, wedding, or medical emergencies.',
                  features: const [
                    'No collateral required',
                    'Higher interest rates',
                  ],
                ),
                _loanTypeBlock(
                  emoji: '🎓',
                  title: 'Education Loan',
                  intro:
                      'Education loans help students pay for college or higher studies.',
                  extra:
                      'These loans are often used for studying in India or abroad.',
                  features: const [],
                ),
                _loanTypeBlock(
                  emoji: '🏢',
                  title: 'Business Loan',
                  intro:
                      'Business loans help entrepreneurs start or expand a business.',
                  introLine2: 'They can be used for:',
                  features: const [
                    'Buying equipment',
                    'Expanding operations',
                    'Working capital',
                  ],
                ),
                const SizedBox(height: 20),
                _emojiTitle('📜', 'Legal Process to Get a Loan in India'),
                _p(
                  'Banks follow a legal verification process before approving any loan.',
                ),
                _numberedStep(
                  '1️⃣',
                  'Application Submission',
                  'You must submit a loan application with basic information.',
                ),
                _numberedStep(
                  '2️⃣',
                  'Document Verification',
                  'Banks verify documents like:\n\n📄 PAN card\n📄 Aadhaar card\n📄 Salary slips or income proof\n📄 Bank statements',
                ),
                _numberedStep(
                  '3️⃣',
                  'Credit Score Check',
                  'Banks check your credit report from TransUnion CIBIL to see your repayment history.\n\nGenerally, a score above 700–750 increases approval chances.',
                ),
                _numberedStep(
                  '4️⃣',
                  'Loan Approval',
                  'If everything looks good, the bank approves the loan and provides the terms.',
                ),
                _numberedStep(
                  '5️⃣',
                  'Loan Disbursement',
                  'After signing the agreement, the loan amount is transferred to your bank account.',
                ),
                const SizedBox(height: 20),
                _emojiTitle('👤', 'Who Can Get a Loan in India?'),
                _p(
                  'Loans are usually available for people who meet these criteria:',
                ),
                _checkList(const [
                  'Age between 21–60 years',
                  'Stable income source',
                  'Good credit score',
                  'Valid identity documents',
                  'Active bank account',
                ]),
                _p(
                  'Both salaried employees and self-employed individuals can apply for loans.',
                ),
                const SizedBox(height: 20),
                _emojiTitle('💸', 'How Much Loan Can a Person Get?'),
                _p('The loan amount depends on several factors.'),
                _bulletSection(
                  title: 'Income',
                  body:
                      'Higher income allows you to borrow a larger amount.',
                ),
                _subheading('Example:'),
                _exampleBox(
                  'Salary ₹25,000 → smaller loan eligibility\nSalary ₹1,00,000 → higher loan eligibility',
                ),
                _bulletSection(
                  title: 'Credit Score',
                  body:
                      'People with a high CIBIL score can get larger loans with lower interest rates.',
                ),
                _bulletSection(
                  title: 'Existing Loans',
                  body:
                      'If you already have many loans, banks may reduce the loan amount.',
                ),
                _bulletSection(
                  title: 'Job Stability',
                  body:
                      'People working for many years in the same job are considered lower risk.',
                ),
                const SizedBox(height: 20),
                _emojiTitle('⚠️', 'Things to Check Before Taking a Loan'),
                _p('Before taking any loan, always check these factors.'),
                _bulletSection(
                  title: 'Interest Rate',
                  body: 'Compare interest rates from multiple banks.',
                ),
                _bulletSection(
                  title: 'Processing Fees',
                  body:
                      'Banks may charge processing fees during loan approval.',
                ),
                _bulletSection(
                  title: 'EMI Amount',
                  body:
                      'Make sure your EMI fits comfortably within your monthly income.\n\nExperts suggest EMIs should not exceed 30–40% of your income.',
                ),
                const SizedBox(height: 20),
                _emojiTitle('🧠', 'Smart Tips Before Taking a Loan'),
                _p(
                  'These tips can help you make better financial decisions.',
                ),
                _bulletSection(
                  title: 'Borrow Only What You Need',
                  body: 'Avoid taking larger loans than necessary.',
                ),
                _bulletSection(
                  title: 'Maintain a Good Credit Score',
                  body:
                      'A strong credit score helps you get lower interest rates.',
                ),
                _bulletSection(
                  title: 'Avoid Too Many Loans',
                  body:
                      'Having too many loans can create financial stress.',
                ),
                _bulletSection(
                  title: 'Choose the Right Loan Tenure',
                  body:
                      'Longer tenure → lower EMI\nShorter tenure → less interest overall',
                ),
                const SizedBox(height: 20),
                _emojiTitle('🚨', 'Risks of Taking Too Many Loans'),
                _p(
                  'Taking excessive loans can create serious financial problems.',
                ),
                _p('Possible risks include:'),
                _checkList(const [
                  'Debt burden',
                  'Late payment penalties',
                  'Reduced credit score',
                  'Legal recovery actions by banks',
                ], bullet: '❌'),
                _p('Always borrow responsibly.'),
                const SizedBox(height: 20),
                _emojiTitle('📌', 'Final Thoughts'),
                _p(
                  'Loans can be a powerful financial tool when used wisely. They help people achieve important goals such as buying homes, studying, or starting businesses.',
                ),
                _p(
                  'However, loans also come with responsibilities.',
                ),
                _p(
                  'If you manage your loans properly by paying EMIs on time and borrowing responsibly, you can maintain a strong financial profile and a healthy credit score.',
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: _PillHomeButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  Widget _emojiTitle(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _text,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _p(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15,
          height: 1.55,
          color: _text,
        ),
      ),
    );
  }

  Widget _subheading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _text,
        ),
      ),
    );
  }

  Widget _exampleBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: const Color(0xFF1E40AF),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _bulletSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.55,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanTypeBlock({
    required String emoji,
    required String title,
    required String intro,
    String? introLine2,
    String? extra,
    required List<String> features,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            intro,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: _muted,
            ),
          ),
          if (introLine2 != null) ...[
            const SizedBox(height: 8),
            Text(
              introLine2,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _text,
              ),
            ),
          ],
          if (extra != null) ...[
            const SizedBox(height: 8),
            Text(
              extra,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: _muted,
              ),
            ),
          ],
          if (features.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Features:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.45,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberedStep(String numEmoji, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numEmoji $title',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.55,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkList(List<String> items, {String bullet = '✔'}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bullet, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.45,
                    color: _text,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LoanGuideHeader extends StatelessWidget {
  const _LoanGuideHeader({
    required this.loanType,
    required this.loanIcon,
    required this.accent,
    required this.iconBg,
    required this.cardTint,
  });

  final String loanType;
  final IconData loanIcon;
  final Color accent;
  final Color iconBg;
  final Color cardTint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconBg,
                  iconBg.withValues(alpha: 0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(loanIcon, color: accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan guide',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loanType,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cardTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Read',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillHomeButton extends StatelessWidget {
  const _PillHomeButton({required this.onPressed});

  final VoidCallback onPressed;

  static const Color _navy = Color(0xFF1A2744);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _navy,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.white.withValues(alpha: 0.12),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Home',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
