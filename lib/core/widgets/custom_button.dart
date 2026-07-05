import 'package:flutter/material.dart';

import '../../config/theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool isOutlined;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
  });

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? _buildOutlinedButton(context)
        : _buildFilledButton(context);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: button,
    );
  }

  Widget _buildFilledButton(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryBlue;
    final effectiveTextColor = textColor ?? AppColors.white;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveTextColor,
        disabledBackgroundColor: AppColors.borderGray,
        disabledForegroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
        ),
      ),
      child: _buildChild(
        context: context,
        contentColor: _isDisabled ? AppColors.textLight : effectiveTextColor,
        loaderColor: effectiveTextColor,
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.primaryBlue;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveTextColor,
        disabledForegroundColor: AppColors.textLight,
        side: BorderSide(
          color: _isDisabled ? AppColors.borderGray : effectiveTextColor,
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
        ),
      ),
      child: _buildChild(
        context: context,
        contentColor: _isDisabled ? AppColors.textLight : effectiveTextColor,
        loaderColor: effectiveTextColor,
      ),
    );
  }

  Widget _buildChild({
    required BuildContext context,
    required Color contentColor,
    required Color loaderColor,
  }) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: contentColor,
              size: 20,
            ),
            child: icon!,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}