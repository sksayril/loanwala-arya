import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loan_education_guide_screen.dart';
import '../services/ad_helper.dart';
import '../services/loan_data_service.dart';
import '../widgets/quiz_native_ad_slot.dart';

/// Light pastel quiz when tapping an "Apply for Loan" card — 8 steps, then loan education guide.
class LoanApplicationQuizScreen extends StatefulWidget {
  const LoanApplicationQuizScreen({
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

  @override
  State<LoanApplicationQuizScreen> createState() =>
      _LoanApplicationQuizScreenState();
}

class _LoanQuizStep {
  const _LoanQuizStep({
    required this.category,
    required this.question,
    required this.options,
    required this.icon,
  });

  final String category;
  final String question;
  final List<String> options;
  final IconData icon;
}

class _LoanApplicationQuizScreenState extends State<LoanApplicationQuizScreen> {
  /// 0-based step index: show rewarded when leaving quiz 2, 4, 6 (steps 1, 3, 5).
  static const Set<int> _rewardedStepIndices = {1, 3, 5};

  static const List<String> _storageKeys = [
    'apply_loan_reason',
    'apply_loan_amount_range',
    'apply_loan_prior_experience',
    'apply_loan_repayment_duration',
    'apply_loan_cibil_awareness',
    'apply_loan_income_source',
    'apply_loan_monthly_income',
    'apply_loan_monthly_expenses',
  ];

  static const List<_LoanQuizStep> _steps = [
    _LoanQuizStep(
      category: 'Reason for Loan',
      question: 'Why do you need the loan?',
      options: [
        'To start a business',
        'Personal expenses',
        'Education',
        'Emergency',
        'Other',
      ],
      icon: Icons.help_outline_rounded,
    ),
    _LoanQuizStep(
      category: 'Loan Amount',
      question: 'How much loan do you want to take?',
      options: [
        '₹10,000 – ₹50,000',
        '₹50,000 – ₹1 Lakh',
        '₹1 Lakh – ₹5 Lakh',
        '₹5 Lakh+',
      ],
      icon: Icons.currency_rupee_rounded,
    ),
    _LoanQuizStep(
      category: 'Previous Loan Experience',
      question: 'Have you ever taken a loan before?',
      options: [
        'Yes, multiple times',
        'Yes, once',
        'No, this is my first time',
      ],
      icon: Icons.history_rounded,
    ),
    _LoanQuizStep(
      category: 'Repayment Duration',
      question: 'In how much time would you like to repay the loan?',
      options: [
        '3 months',
        '6 months',
        '12 months',
        '24 months+',
      ],
      icon: Icons.schedule_rounded,
    ),
    _LoanQuizStep(
      category: 'CIBIL Score Awareness',
      question: 'What is your approximate CIBIL score?',
      options: [
        '750+',
        '650 – 750',
        '550 – 650',
        'I don’t know',
      ],
      icon: Icons.insights_outlined,
    ),
    _LoanQuizStep(
      category: 'Income Source',
      question: 'What is your main source of income?',
      options: [
        'Private job',
        'Government job',
        'Business',
        'Freelance / Self-employed',
      ],
      icon: Icons.badge_outlined,
    ),
    _LoanQuizStep(
      category: 'Monthly Income',
      question: 'What is your monthly income?',
      options: [
        '₹10k – ₹25k',
        '₹25k – ₹50k',
        '₹50k – ₹1L',
        '₹1L+',
      ],
      icon: Icons.payments_outlined,
    ),
    _LoanQuizStep(
      category: 'Monthly Expenses',
      question: 'What are your monthly expenses?',
      options: [
        '30% of income',
        '50% of income',
        '70% of income',
        'Almost all income',
      ],
      icon: Icons.receipt_long_outlined,
    ),
  ];

  int _index = 0;
  final List<int?> _selected = List<int?>.filled(_steps.length, null);

  void _pick(int optionIndex) {
    setState(() => _selected[_index] = optionIndex);
  }

  Future<void> _persistAndContinue() async {
    final loan = LoanDataService();
    loan.updateLoanDetails(loanType: widget.loanType);
    loan.addAdditionalData('apply_loan_product', widget.loanType);

    for (var i = 0; i < _steps.length; i++) {
      final sel = _selected[i];
      if (sel != null) {
        loan.addAdditionalData(_storageKeys[i], _steps[i].options[sel]);
      }
    }

    if (!mounted) return;
    await AdHelper.showInterstitialThen(
      context,
      onComplete: () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => LoanEducationGuideScreen(
              loanType: widget.loanType,
              loanIcon: widget.loanIcon,
              accentColor: widget.accentColor,
              iconBgColor: widget.iconBgColor,
              cardBgColor: widget.cardBgColor,
            ),
          ),
        );
      },
    );
  }

  Future<void> _next() async {
    if (_selected[_index] == null) return;
    if (_index < _steps.length - 1) {
      if (_rewardedStepIndices.contains(_index)) {
        await AdHelper.showRewardedThen(
          context,
          onComplete: () {
            if (!mounted) return;
            setState(() => _index++);
          },
        );
      } else {
        setState(() => _index++);
      }
    } else {
      await _persistAndContinue();
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final progress = (_index + 1) / _steps.length;
    final accent = widget.accentColor;
    final hasPick = _selected[_index] != null;
    final isLast = _index == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _HeaderBand(
            loanType: widget.loanType,
            loanIcon: widget.loanIcon,
            accent: accent,
            iconBg: widget.iconBgColor,
            cardTint: widget.cardBgColor,
            onBack: _back,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: accent.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Step ${_index + 1} of ${_steps.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(step.icon, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            step.category,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    step.question,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(step.options.length, (i) {
                    final selected = _selected[_index] == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OptionCard(
                        label: step.options[i],
                        selected: selected,
                        accent: accent,
                        onTap: () => _pick(i),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: hasPick ? _next : null,
                      style: ElevatedButton.styleFrom(
                        elevation: hasPick ? 2 : 0,
                        shadowColor: accent.withValues(alpha: 0.35),
                        backgroundColor: accent,
                        disabledBackgroundColor: Colors.grey[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Continue to customize loan' : 'Next',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Icons.arrow_forward_rounded
                                : Icons.chevron_right_rounded,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  QuizNativeAdSlot(
                    reloadKey: _index,
                    variant: QuizNativeAdVariant.light,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBand extends StatelessWidget {
  const _HeaderBand({
    required this.loanType,
    required this.loanIcon,
    required this.accent,
    required this.iconBg,
    required this.cardTint,
    required this.onBack,
  });

  final String loanType;
  final IconData loanIcon;
  final Color accent;
  final Color iconBg;
  final Color cardTint;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, top + 4, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: const Color(0xFF1A1A1A),
          ),
          Container(
            width: 48,
            height: 48,
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
            child: Icon(loanIcon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan application',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.2,
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
                  maxLines: 1,
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
              'Quiz',
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accent.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? accent
                  : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? accent.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: selected ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.35,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? accent : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: selected ? accent : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
