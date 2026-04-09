import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cibil_score_guide_screen.dart';
import '../services/ad_helper.dart';
import '../services/loan_data_service.dart';
import '../widgets/quiz_native_ad_slot.dart';

/// Dark-navy quiz flow (matches home credit score card) — 7 questions, one per step.
class FinancialQuizScreen extends StatefulWidget {
  const FinancialQuizScreen({super.key});

  @override
  State<FinancialQuizScreen> createState() => _FinancialQuizScreenState();
}

class _QuizStep {
  const _QuizStep({
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

class _FinancialQuizScreenState extends State<FinancialQuizScreen> {
  /// 0-based: rewarded when leaving quiz 2 and 4 (indices 1 and 3).
  static const Set<int> _rewardedStepIndices = {1, 3};

  static const List<_QuizStep> _steps = [
    _QuizStep(
      category: 'Employment Stability',
      question: 'How long have you been in your current job / business?',
      options: [
        'Less than 6 months',
        '6 months – 2 years',
        '2 – 5 years',
        '5+ years',
      ],
      icon: Icons.work_outline_rounded,
    ),
    _QuizStep(
      category: 'Income Stability',
      question: 'How stable is your income every month?',
      options: [
        'Fixed salary every month',
        'Mostly stable',
        'Sometimes fluctuates',
        'Highly irregular',
      ],
      icon: Icons.account_balance_wallet_outlined,
    ),
    _QuizStep(
      category: 'Emergency Fund',
      question:
          'If an emergency occurs, how many months of expenses can you cover?',
      options: [
        'Less than 1 month',
        '1–3 months',
        '3–6 months',
        '6+ months',
      ],
      icon: Icons.shield_outlined,
    ),
    _QuizStep(
      category: 'Monthly Budget Habit',
      question: 'Do you create a monthly budget plan?',
      options: [
        'Yes, always',
        'Sometimes',
        'Rarely',
        'Never',
      ],
      icon: Icons.pie_chart_outline_rounded,
    ),
    _QuizStep(
      category: 'Digital Payments Habit',
      question: 'How do you usually make payments?',
      options: [
        'UPI / digital payments',
        'Debit card',
        'Cash',
        'Mix of all',
      ],
      icon: Icons.smartphone_rounded,
    ),
    _QuizStep(
      category: 'Saving Discipline',
      question:
          'Do you save money automatically every month or manually?',
      options: [
        'Automatic saving system',
        'Manual saving',
        'Occasionally save',
        'No saving',
      ],
      icon: Icons.savings_outlined,
    ),
    _QuizStep(
      category: 'Financial Goals',
      question: 'Have you set any financial goals?',
      options: [
        'Yes, long-term goals',
        'Yes, short-term goals',
        'Thinking about it',
        'No goals',
      ],
      icon: Icons.flag_outlined,
    ),
  ];

  int _index = 0;
  final List<int?> _selectedOption = List<int?>.filled(_steps.length, null);

  static const Color _navyDeep = Color(0xFF1A2744);
  static const Color _navyMid = Color(0xFF243B5C);
  static const Color _accentGreen = Color(0xFF10B981);

  void _select(int optionIndex) {
    setState(() => _selectedOption[_index] = optionIndex);
  }

  Future<void> _goNext() async {
    final sel = _selectedOption[_index];
    if (sel == null) return;

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
      return;
    }

    final loan = LoanDataService();
    for (var i = 0; i < _steps.length; i++) {
      final opt = _selectedOption[i];
      if (opt != null) {
        loan.addAdditionalData(
          'quiz_${_steps[i].category.replaceAll(' ', '_').toLowerCase()}',
          _steps[i].options[opt],
        );
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
            builder: (context) => const CibilScoreGuideScreen(),
          ),
        );
      },
    );
  }

  void _goBack() {
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
    final hasSelection = _selectedOption[_index] != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _navyDeep,
              _navyMid,
              Color(0xFF1E3250),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Financial check-in',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(_accentGreen),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Question ${_index + 1} of ${_steps.length}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _accentGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        step.icon,
                        color: _accentGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          step.category,
                          style: GoogleFonts.inter(
                            color: _accentGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  step.question,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: step.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final selected = _selectedOption[_index] == i;
                      return _OptionTile(
                        label: step.options[i],
                        selected: selected,
                        onTap: () => _select(i),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _PrimaryButton(
                  label: _index == _steps.length - 1
                      ? 'Continue to credit check'
                      : 'Next',
                  onPressed: hasSelection ? _goNext : null,
                ),
                QuizNativeAdSlot(
                  reloadKey: _index,
                  variant: QuizNativeAdVariant.dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _accentGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? _accentGreen.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.22),
              width: selected ? 1.8 : 1.2,
            ),
            color: selected
                ? _accentGreen.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.06),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _accentGreen.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: selected ? 1 : 0.92),
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.35,
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
                    color: selected
                        ? _accentGreen
                        : Colors.white.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  color: selected ? _accentGreen : Colors.transparent,
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: enabled
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.15),
            ),
            color: enabled
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: enabled ? 1 : 0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (enabled) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
