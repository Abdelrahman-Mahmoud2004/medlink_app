import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({
    super.key,
    this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordReset = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_handlePasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_handlePasswordChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handlePasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleReset() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace this with real reset password API/Firebase call.
      // widget.token can be used here when backend integration is added.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _passwordReset = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _goBack() {
    if (_passwordReset || _isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.login);
  }

  void _goToLogin() {
    context.go(AppRoutes.login);
  }

  int get _passwordStrength {
    final password = _passwordController.text;

    if (password.isEmpty) return 0;

    int score = 0;

    if (password.length >= AppConstants.minPasswordLength) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    return score;
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return AppColors.errorRed;
      case 2:
        return AppColors.warningOrange;
      case 3:
        return const Color(0xFF84CC16);
      case 4:
        return AppColors.successGreen;
      default:
        return AppColors.borderGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _passwordReset || _isLoading ? null : _goBack,
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
            duration: AppConstants.animationDuration,
            child: _passwordReset
                ? _buildSuccessView(context)
                : _buildFormView(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('reset_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.createNewPassword,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            AppStrings.resetPasswordSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          const Center(
            child: _ResetPasswordIcon(),
          ),

          const SizedBox(height: AppSpacing.xxl),

          CustomTextField(
            label: AppStrings.newPassword,
            controller: _passwordController,
            validator: AppValidators.strongPassword,
            obscureText: true,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
          ),

          const SizedBox(height: AppSpacing.lg),

          _buildStrengthIndicator(context),

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
            onSubmitted: (_) => _handleReset(),
          ),

          const SizedBox(height: AppSpacing.xxl),

          CustomButton(
            label: AppStrings.resetPassword,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleReset,
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(BuildContext context) {
    final strength = _passwordStrength;
    final label = _strengthLabel;
    final color = _strengthColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.passwordStrength,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: strength / 4,
              minHeight: 7,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      key: const ValueKey('reset_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 70),

        const _SuccessIcon(),

        const SizedBox(height: AppSpacing.xl),

        Text(
          AppStrings.passwordResetSuccessfully,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          AppStrings.passwordResetSuccessBody,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxl),

        CustomButton(
          label: AppStrings.goToLogin,
          onPressed: _goToLogin,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _ResetPasswordIcon extends StatelessWidget {
  const _ResetPasswordIcon();

  @override
  Widget build(BuildContext context) {
    return const _SecurityIcon(
      icon: Icons.lock_reset_rounded,
      color: AppColors.primaryBlue,
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: AppColors.successGreen,
        size: 72,
      ),
    );
  }
}

class _SecurityIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SecurityIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
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
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
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