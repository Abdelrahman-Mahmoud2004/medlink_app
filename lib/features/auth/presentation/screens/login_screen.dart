import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  /// Received from RoleSelectionScreen via GoRouter extra.
  final UserType? userType;

  const LoginScreen({
    super.key,
    this.userType,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _rememberMe = false;

  UserType get _effectiveUserType {
    return widget.userType ?? UserType.patient;
  }

  bool get _isNurse {
    return _effectiveUserType == UserType.nurse;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace this block with real AuthRepository/AuthProvider login.
      await Future.delayed(const Duration(seconds: 2));

      final storage = StorageService.instance;

      final currentKycStatus = storage.kycStatus;

      await storage.setAuthSession(
        authToken: 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        userType: _effectiveUserType,
        userId: 'mock_user_id',
        kycStatus: _isNurse ? currentKycStatus : KycStatus.none,
      );

      if (!mounted) return;

      if (_isNurse) {
        if (storage.isKycApproved) {
          context.go(AppRoutes.nurseHome);
          return;
        }

        context.go(AppRoutes.nurseVerification);
        return;
      }

      context.go(AppRoutes.patientHome);
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

  void _goBack() {
    if (_isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.roleSelection);
  }

  void _goToForgotPassword() {
    if (_isLoading) return;

    context.push(AppRoutes.forgotPassword);
  }

  void _goToSignUp() {
    if (_isLoading) return;

    context.push(
      AppRoutes.signup,
      extra: widget.userType,
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.errorRed
            : isSuccess
                ? AppColors.successGreen
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.userType != null
        ? 'Login as ${widget.userType!.displayName}'
        : AppStrings.loginSubtitle;

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
                  _LoginHeader(
                    userType: widget.userType,
                    subtitle: subtitle,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

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
                    validator: AppValidators.password,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    onSubmitted: (_) => _handleLogin(),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _LoginOptionsRow(
                    rememberMe: _rememberMe,
                    enabled: !_isLoading,
                    onRememberChanged: (value) {
                      setState(() => _rememberMe = value);
                    },
                    onForgotPassword: _goToForgotPassword,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  CustomButton(
                    label: AppStrings.login,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleLogin,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _SignUpRedirect(
                    enabled: !_isLoading,
                    onTap: _goToSignUp,
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

class _LoginHeader extends StatelessWidget {
  final UserType? userType;
  final String subtitle;

  const _LoginHeader({
    required this.userType,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isNurse = userType == UserType.nurse;
    final icon = isNurse
        ? Icons.health_and_safety_rounded
        : Icons.person_rounded;

    final badgeColor = isNurse ? AppColors.successGreen : AppColors.primaryBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Icon(
            icon,
            color: badgeColor,
            size: 36,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          AppStrings.welcomeBack,
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
          _RoleBadge(
            userType: userType!,
            color: badgeColor,
          ),
        ],
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserType userType;
  final Color color;

  const _RoleBadge({
    required this.userType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isNurse = userType == UserType.nurse;

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

class _LoginOptionsRow extends StatelessWidget {
  final bool rememberMe;
  final bool enabled;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgotPassword;

  const _LoginOptionsRow({
    required this.rememberMe,
    required this.enabled,
    required this.onRememberChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: InkWell(
            onTap: enabled ? () => onRememberChanged(!rememberMe) : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: enabled
                      ? (value) => onRememberChanged(value ?? false)
                      : null,
                  activeColor: AppColors.primaryBlue,
                  side: const BorderSide(
                    color: AppColors.borderGray,
                    width: 1.5,
                  ),
                ),
                Flexible(
                  child: Text(
                    AppStrings.rememberMe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),

        TextButton(
          onPressed: enabled ? onForgotPassword : null,
          child: Text(
            AppStrings.forgotPassword,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _SignUpRedirect extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _SignUpRedirect({
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
            AppStrings.dontHaveAccount,
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
            AppStrings.signup,
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