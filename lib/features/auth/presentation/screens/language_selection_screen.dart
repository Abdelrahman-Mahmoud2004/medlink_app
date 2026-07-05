import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final void Function(String languageCode) onLanguageChanged;
  final String? initialLanguageCode;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageChanged,
    this.initialLanguageCode,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguage;
  bool _isSaving = false;

  static const List<_LanguageOption> _languages = [
    _LanguageOption(
      code: 'en',
      shortCode: 'EN',
      name: 'English',
      nativeName: 'English',
      icon: Icons.language_rounded,
    ),
    _LanguageOption(
      code: 'ar',
      shortCode: 'AR',
      name: 'Arabic',
      nativeName: 'العربية',
      icon: Icons.translate_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguageCode ?? 'en';
  }

  void _goBack() {
    if (_isSaving) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.welcome);
  }

  void _selectLanguage(String code) {
    if (_isSaving) return;

    setState(() {
      _selectedLanguage = code;
    });
  }

  Future<void> _continue() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      widget.onLanguageChanged(_selectedLanguage);

      if (!mounted) return;

      if (context.canPop()) {
        context.pop();
        return;
      }

      context.go(AppRoutes.welcome);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.selectLanguage),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSaving ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            children: [
              const _HeaderSection(),

              const SizedBox(height: AppSpacing.xxl),

              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    final isSelected = _selectedLanguage == language.code;

                    return _LanguageCard(
                      language: language,
                      isSelected: isSelected,
                      isEnabled: !_isSaving,
                      onTap: () => _selectLanguage(language.code),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              CustomButton(
                label: AppStrings.continueText,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private Widgets
// -----------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: const Icon(
            Icons.public_rounded,
            color: AppColors.primaryBlue,
            size: 38,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          AppStrings.chooseLanguage,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          AppStrings.languageSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final _LanguageOption language;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightBlue : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isSelected ? 24 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(
                    alpha: isSelected ? 0.16 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      language.icon,
                      color: AppColors.primaryBlue,
                      size: 30,
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          language.shortCode,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 9,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      language.nativeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderGray,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 19,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private Model
// -----------------------------------------------------------------------------

class _LanguageOption {
  final String code;
  final String shortCode;
  final String name;
  final String nativeName;
  final IconData icon;

  const _LanguageOption({
    required this.code,
    required this.shortCode,
    required this.name,
    required this.nativeName,
    required this.icon,
  });
}