import 'package:flutter/material.dart';

import '../../../config/theme.dart';

class AppLoadingState extends StatelessWidget {
  final String message;
  final bool fullScreen;

  const AppLoadingState({
    super.key,
    this.message = 'Loading...',
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );

    if (!fullScreen) return Center(child: content);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Center(child: content),
      ),
    );
  }
}