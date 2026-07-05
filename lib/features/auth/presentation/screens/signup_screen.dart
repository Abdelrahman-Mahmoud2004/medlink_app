import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  /// Received from LoginScreen which got it from RoleSelectionScreen.
  final UserType? userType;

  const SignUpScreen({
    super.key,
    this.userType,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  UserType get _effectiveUserType {
    return widget.userType ?? UserType.patient;
  }

  bool get _isNurse {
    return _effectiveUserType == UserType.nurse;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar(
        'Please agree to terms and conditions',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with real AuthRepository/AuthProvider signup.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      context.push(
        AppRoutes.otp,
        extra: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': _effectiveUserType,
        },
      );
    } catch (error) {
      if (!mounted) return;

      _showSnackBar(
        error.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? AppColors.successGreen
            : isError
                ? AppColors.errorRed
                : null,
      ),
    );
  }

  void _goBack() {
    if (_isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.roleSelection);
  }

  void _goToLogin() {
    if (_isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(
      AppRoutes.login,
      extra: widget.userType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.userType != null
        ? 'Create ${widget.userType!.displayName} Account'
        : AppStrings.createAccount;

    final subtitle = _isNurse
        ? 'Join MedLink and start providing trusted healthcare services.'
        : 'Join MedLink and book trusted healthcare services from home.';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isLoading ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SignUpHeader(
                    userType: widget.userType,
                    title: title,
                    subtitle: subtitle,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  CustomTextField(
                    label: AppStrings.fullName,
                    hint: 'Enter your full name',
                    controller: _nameController,
                    validator: AppValidators.name,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'example@email.com',
                    controller: _emailController,
                    validator: AppValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomTextField(
                    label: AppStrings.password,
                    controller: _passwordController,
                    validator: AppValidators.strongPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomTextField(
                    label: AppStrings.confirmPassword,
                    controller: _confirmPasswordController,
                    validator: AppValidators.confirmPassword(
                      () => _passwordController.text,
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    onSubmitted: (_) => _handleSignUp(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _TermsAgreementTile(
                    value: _agreeToTerms,
                    enabled: !_isLoading,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value);
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  CustomButton(
                    label: AppStrings.signup,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSignUp,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _LoginRedirect(
                    enabled: !_isLoading,
                    onTap: _goToLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _SignUpHeader extends StatelessWidget {
  final UserType? userType;
  final String title;
  final String subtitle;

  const _SignUpHeader({
    required this.userType,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isNurse = userType == UserType.nurse;
    final color = isNurse ? AppColors.successGreen : AppColors.primaryBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Icon(
            isNurse
                ? Icons.health_and_safety_rounded
                : Icons.person_rounded,
            color: color,
            size: 34,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
        ),

        if (userType != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _RoleBadge(userType: userType!),
        ],
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserType userType;

  const _RoleBadge({
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final isNurse = userType == UserType.nurse;
    final color = isNurse ? AppColors.successGreen : AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNurse
                ? Icons.medical_services_rounded
                : Icons.person_outline_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            userType.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _TermsAgreementTile extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _TermsAgreementTile({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryBlue.withValues(alpha: 0.06)
            : AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: value ? AppColors.primaryBlue : AppColors.borderGray,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: value,
            onChanged: enabled ? (checked) => onChanged(checked ?? false) : null,
            activeColor: AppColors.primaryBlue,
            side: const BorderSide(
              color: AppColors.borderGray,
              width: 1.5,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onChanged(!value) : null,
              child: Text(
                AppStrings.termsAgreement,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? AppColors.textDark
                          : AppColors.textLight,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRedirect extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _LoginRedirect({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            AppStrings.alreadyHaveAccount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDark,
                ),
          ),
        ),
        TextButton(
          onPressed: enabled ? onTap : null,
          child: Text(
            AppStrings.login,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}