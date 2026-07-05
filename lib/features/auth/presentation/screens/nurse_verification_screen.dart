import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/services/storage_service.dart';

class NurseVerificationScreen extends StatefulWidget {
  const NurseVerificationScreen({super.key});

  @override
  State<NurseVerificationScreen> createState() =>
      _NurseVerificationScreenState();
}

class _NurseVerificationScreenState extends State<NurseVerificationScreen> {
  String? _idCardFileName;
  String? _licenseFileName;

  bool _isLoading = false;
  bool _submitted = false;

  bool get _canSubmit {
    return _idCardFileName != null &&
        _licenseFileName != null &&
        !_isLoading;
  }

  void _pickFile(bool isIdCard) {
    if (_isLoading || _submitted) return;

    // TODO: Replace this mocked picker with file_picker/image_picker.
    setState(() {
      if (isIdCard) {
        _idCardFileName = 'id_card.jpg';
      } else {
        _licenseFileName = 'nursing_license.pdf';
      }
    });

    _showSnackBar(
      isIdCard ? 'ID card selected' : 'License selected',
      isSuccess: true,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Replace this with real document upload API/Firebase Storage call.
      await Future.delayed(const Duration(seconds: 2));

      await StorageService.instance.setKycStatus(KycStatus.pending);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _submitted = true;
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

  void _goBackToWelcome() {
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.nurseVerification),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppConstants.animationDuration,
          child: _submitted
              ? _buildSuccessView(context)
              : _buildUploadView(context),
        ),
      ),
    );
  }

  Widget _buildUploadView(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('upload_view'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VerificationHeader(),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            AppStrings.nurseVerification,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            AppStrings.nurseVerificationSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          _UploadCard(
            title: AppStrings.uploadIdCard,
            subtitle: AppStrings.uploadIdCardSubtitle,
            icon: Icons.badge_rounded,
            fileName: _idCardFileName,
            enabled: !_isLoading,
            onTap: () => _pickFile(true),
          ),

          const SizedBox(height: AppSpacing.lg),

          _UploadCard(
            title: AppStrings.uploadLicense,
            subtitle: AppStrings.uploadLicenseSubtitle,
            icon: Icons.medical_information_rounded,
            fileName: _licenseFileName,
            enabled: !_isLoading,
            onTap: () => _pickFile(false),
          ),

          const SizedBox(height: AppSpacing.xxl),

          const _InfoNote(),

          const SizedBox(height: AppSpacing.xxl),

          CustomButton(
            label: AppStrings.submitDocuments,
            isLoading: _isLoading,
            onPressed: _canSubmit ? _handleSubmit : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('success_view'),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          const _PendingReviewIcon(),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            AppStrings.verificationPendingTitle,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            AppStrings.verificationPendingBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          const Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _TimeChip(
                label: 'Within 48 hours',
                icon: Icons.access_time_rounded,
              ),
              _TimeChip(
                label: 'Max 1 week',
                icon: Icons.calendar_today_rounded,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          const _NextStepsCard(),

          const SizedBox(height: AppSpacing.xxl),

          CustomButton(
            label: AppStrings.backToWelcomeScreen,
            isOutlined: true,
            onPressed: _goBackToWelcome,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 178,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 22,
            right: 26,
            child: _SoftCircle(
              size: 34,
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 28,
            child: _SoftCircle(
              size: 46,
              color: AppColors.successGreen.withValues(alpha: 0.10),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 46,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.verifyCredentials,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final bool enabled;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fileName,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = fileName != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AnimatedContainer(
          duration: AppConstants.animationDuration,
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.successGreen.withValues(alpha: 0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isUploaded ? AppColors.successGreen : AppColors.borderGray,
              width: isUploaded ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isUploaded
                    ? AppColors.successGreen.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.035),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppConstants.animationDuration,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : icon,
                  color: isUploaded
                      ? AppColors.successGreen
                      : AppColors.primaryBlue,
                  size: 28,
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUploaded ? fileName! : subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUploaded
                                ? AppColors.successGreen
                                : AppColors.textLight,
                            height: 1.35,
                            fontWeight: isUploaded
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Icon(
                isUploaded ? Icons.edit_rounded : Icons.upload_rounded,
                color:
                    isUploaded ? AppColors.successGreen : AppColors.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.warningOrange.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warningOrange,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.verificationInfoNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warningOrange,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingReviewIcon extends StatelessWidget {
  const _PendingReviewIcon();

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
        size: 74,
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TimeChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
          ),
        ],
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.whatHappensNext,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _NextStep(
            number: '1',
            text: AppStrings.verificationStep1,
          ),
          const _NextStep(
            number: '2',
            text: AppStrings.verificationStep2,
          ),
          const _NextStep(
            number: '3',
            text: AppStrings.verificationStep3,
          ),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String text;

  const _NextStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDark,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
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