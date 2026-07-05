import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/services/storage_service.dart';

class OTPScreen extends StatefulWidget {
  /// Receives {'email': String, 'userType': UserType?} from SignUpScreen.
  final Map<String, dynamic> data;

  const OTPScreen({
    super.key,
    required this.data,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _resendTimer;

  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isLoading = false;

  String get email => widget.data['email'] as String? ?? '';

  UserType? get userType {
    final value = widget.data['userType'];

    if (value is UserType) {
      return value;
    }

    if (value is String) {
      return UserType.fromJson(value);
    }

    return null;
  }

  UserType get _effectiveUserType => userType ?? UserType.patient;

  String get _currentOTP {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isOtpComplete => _currentOTP.length == AppConstants.otpLength;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      AppConstants.otpLength,
      (_) => TextEditingController(),
    );

    _focusNodes = List.generate(
      AppConstants.otpLength,
      (_) => FocusNode(),
    );

    for (final focusNode in _focusNodes) {
      focusNode.addListener(_handleFocusChanged);
    }

    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();

    for (final focusNode in _focusNodes) {
      focusNode.removeListener(_handleFocusChanged);
      focusNode.dispose();
    }

    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });

        timer.cancel();
        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  void _handleChange(int index, String value) {
    if (value.isEmpty) {
      setState(() {});
      return;
    }

    final digit = value[value.length - 1];

    if (_controllers[index].text != digit) {
      _controllers[index].text = digit;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (index < AppConstants.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    setState(() {});
  }

  KeyEventResult _handleBackspace(int index, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    if (_controllers[index].text.isNotEmpty) {
      return KeyEventResult.ignored;
    }

    if (index <= 0) {
      return KeyEventResult.ignored;
    }

    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();

    setState(() {});

    return KeyEventResult.handled;
  }

  Future<void> _handleVerify() async {
    if (_isLoading) return;

    if (!_isOtpComplete) {
      _showSnackBar(
        AppStrings.enterAllOtpDigits,
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with real OTP verification API/Firebase call.
      await Future.delayed(const Duration(seconds: 2));

      await StorageService.instance.setAuthSession(
        authToken: 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        userType: _effectiveUserType,
        userId: 'mock_user_id',
        kycStatus:
            _effectiveUserType.isNurse ? KycStatus.none : KycStatus.none,
      );

      if (!mounted) return;

      if (_effectiveUserType.isNurse) {
        context.go(AppRoutes.nurseVerification);
        return;
      }

      context.go(AppRoutes.permissions);
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

  void _handleResend() {
    if (!_canResend || _isLoading) return;

    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes.first.requestFocus();
    _startResendTimer();

    _showSnackBar(
      AppStrings.otpResent,
      isSuccess: true,
    );
  }

  void _goBack() {
    if (_isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.welcome);
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
    final displayEmail = email.trim().isEmpty ? AppStrings.email : email.trim();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: _OtpHeaderIcon(),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                AppStrings.verifyYourEmail,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'We sent a ${AppConstants.otpLength}-digit code to $displayEmail',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _buildOTPRow(),

              const SizedBox(height: AppSpacing.xxl),

              CustomButton(
                label: AppStrings.verifyOtp,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleVerify,
              ),

              const SizedBox(height: AppSpacing.xxl),

              Center(
                child: Column(
                  children: [
                    Text(
                      AppStrings.didntReceiveCode,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_canResend)
                      TextButton(
                        onPressed: _isLoading ? null : _handleResend,
                        child: Text(
                          AppStrings.resendOtp,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgGray,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Resend in $_secondsRemaining seconds',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        AppConstants.otpLength,
        _buildOTPField,
      ),
    );
  }

  Widget _buildOTPField(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;

    return Focus(
      onKeyEvent: (_, event) => _handleBackspace(index, event),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 62,
        decoration: BoxDecoration(
          color: hasValue || isFocused ? AppColors.lightBlue : AppColors.bgGray,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: hasValue || isFocused
                ? AppColors.primaryBlue
                : AppColors.borderGray,
            width: hasValue || isFocused ? 2 : 1,
          ),
          boxShadow: hasValue || isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) => _handleChange(index, value),
          decoration: const InputDecoration(
            counter: SizedBox.shrink(),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _OtpHeaderIcon extends StatelessWidget {
  const _OtpHeaderIcon();

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
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
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
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 24,
            child: _SoftCircle(
              size: 38,
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.primaryBlue,
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