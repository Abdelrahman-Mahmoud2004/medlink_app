import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with real forgot password API/Firebase call.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showSnackBar(
        error.toString(),
        isError: true,
      );
    }
  }

  void _goBack() {
    if (_isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.login);
  }

  void _goToLogin() {
    context.go(AppRoutes.login);
  }

  void _goToResetPasswordDemo() {
    context.push(
      AppRoutes.resetPassword,
      extra: null,
    );
  }

  void _tryAgain() {
    if (_isLoading) return;

    setState(() => _emailSent = false);
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

  @override
  Widget build(BuildContext context) {
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _emailSent
                ? _SuccessView(
                    email: _emailController.text.trim(),
                    onBackToLogin: _goToLogin,
                    onTryAgain: _tryAgain,
                    onResetNowDemo: _goToResetPasswordDemo,
                  )
                : _ForgotPasswordForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    isLoading: _isLoading,
                    onSubmit: _sendResetLink,
                    onBackToLogin: _goBack,
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

class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const _ForgotPasswordForm({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey('forgot_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: _ForgotPasswordIcon(),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            AppStrings.forgotPasswordTitle,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            AppStrings.forgotPasswordSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          CustomTextField(
            label: AppStrings.email,
            hint: 'example@email.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: AppValidators.email,
            enabled: !isLoading,
            onSubmitted: (_) => onSubmit(),
          ),

          const SizedBox(height: AppSpacing.xxl),

          CustomButton(
            label: AppStrings.sendResetLink,
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),

          const SizedBox(height: AppSpacing.xl),

          Center(
            child: TextButton(
              onPressed: isLoading ? null : onBackToLogin,
              child: Text(
                AppStrings.backToLogin,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;
  final VoidCallback onTryAgain;
  final VoidCallback onResetNowDemo;

  const _SuccessView({
    required this.email,
    required this.onBackToLogin,
    required this.onTryAgain,
    required this.onResetNowDemo,
  });

  @override
  Widget build(BuildContext context) {
    final displayEmail = email.isEmpty ? AppStrings.email : email;

    return Column(
      key: const ValueKey('forgot_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        const _EmailSentIcon(),

        const SizedBox(height: AppSpacing.xxl),

        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          'We sent a password reset link to\n$displayEmail',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxl),

        CustomButton(
          label: 'Continue Demo Reset',
          onPressed: onResetNowDemo,
        ),

        const SizedBox(height: AppSpacing.lg),

        CustomButton(
          label: AppStrings.backToLogin,
          isOutlined: true,
          onPressed: onBackToLogin,
        ),

        const SizedBox(height: AppSpacing.xl),

        TextButton(
          onPressed: onTryAgain,
          child: Text(
            AppStrings.tryAgain,
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

class _ForgotPasswordIcon extends StatelessWidget {
  const _ForgotPasswordIcon();

  @override
  Widget build(BuildContext context) {
    return const _IconContainer(
      icon: Icons.lock_reset_rounded,
      color: AppColors.primaryBlue,
    );
  }
}

class _EmailSentIcon extends StatelessWidget {
  const _EmailSentIcon();

  @override
  Widget build(BuildContext context) {
    return _IconContainer(
      icon: Icons.mark_email_read_rounded,
      color: AppColors.successGreen,
      backgroundColor: AppColors.successGreen.withValues(alpha: 0.10),
    );
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;

  const _IconContainer({
    required this.icon,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            right: 22,
            child: _SoftCircle(
              size: 28,
              color: color.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 24,
            child: _SoftCircle(
              size: 38,
              color: color.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 52,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}