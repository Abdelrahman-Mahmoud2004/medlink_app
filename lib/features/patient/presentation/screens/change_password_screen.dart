import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSaving) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientSettings);
  }

  String? _passwordValidator(String? value) {
    final clean = value ?? '';

    if (clean.isEmpty) {
      return 'Required';
    }

    if (clean.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final validation = _passwordValidator(value);

    if (validation != null) return validation;

    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _savePassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving) return;

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSaving = false);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Password Updated'),
          content: const Text(
            'Your password has been changed successfully.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                dialogContext.pop();

                if (!mounted) return;

                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.patientSettings);
                }
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  double get _passwordStrength {
    final password = _newPasswordController.text;

    double score = 0;

    if (password.length >= 8) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.25;

    return score.clamp(0.0, 1.0);
  }

  Color _strengthColor(double strength) {
    if (strength < 0.5) return AppColors.errorRed;
    if (strength < 0.75) return AppColors.warningOrange;
    return AppColors.successGreen;
  }

  String _strengthLabel(double strength) {
    if (strength == 0) return 'Enter a new password';
    if (strength < 0.5) return 'Weak password';
    if (strength < 0.75) return 'Medium password';
    return 'Strong password';
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;
    final strengthColor = _strengthColor(strength);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSaving ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryBlue.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: AppColors.primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                'Choose a strong password and do not share it with anyone.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.primaryBlue,
                                      height: 1.45,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscureCurrent = !_obscureCurrent);
                            },
                          ),
                        ),
                        validator: _passwordValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscureNew = !_obscureNew);
                            },
                          ),
                        ),
                        validator: _passwordValidator,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.bgGray,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: strength,
                              minHeight: 6,
                              color: strengthColor,
                              backgroundColor: AppColors.borderGray,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _strengthLabel(strength),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: strengthColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirm = !_obscureConfirm);
                            },
                          ),
                        ),
                        validator: _confirmPasswordValidator,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderGray),
                ),
              ),
              child: CustomButton(
                label: 'Update Password',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _savePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}