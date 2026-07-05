import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserType? _selectedRole;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  void _selectRole(UserType role) {
    setState(() => _selectedRole = role);
  }

  void _goNext() {
    final selectedRole = _selectedRole;

    if (selectedRole == null) {
      return;
    }

    context.push(
      AppRoutes.login,
      extra: selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.selectRole),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: const Icon(
                        Icons.account_circle_rounded,
                        color: AppColors.primaryBlue,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      AppStrings.roleQuestion,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppStrings.roleSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _RoleCard(
                      icon: Icons.person_rounded,
                      iconColor: AppColors.primaryBlue,
                      title: AppStrings.iAmPatient,
                      description: AppStrings.patientRoleDescription,
                      isSelected: _selectedRole == UserType.patient,
                      onTap: () => _selectRole(UserType.patient),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _RoleCard(
                      icon: Icons.health_and_safety_rounded,
                      iconColor: AppColors.successGreen,
                      title: AppStrings.iAmNurse,
                      description: AppStrings.nurseRoleDescription,
                      isSelected: _selectedRole == UserType.nurse,
                      onTap: () => _selectRole(UserType.nurse),
                    ),
                  ],
                ),
              ),
              CustomButton(
                label: AppStrings.next,
                onPressed: _selectedRole != null ? _goNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AnimatedContainer(
          duration: AppConstants.animationDuration,
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
              AnimatedContainer(
                duration: AppConstants.animationDuration,
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isSelected ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 34,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AnimatedContainer(
                duration: AppConstants.animationDuration,
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