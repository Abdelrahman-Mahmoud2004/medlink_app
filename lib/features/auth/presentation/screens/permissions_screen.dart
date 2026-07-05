import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late final List<_PermissionItem> _permissions;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _permissions = [
      _PermissionItem(
        id: 'location',
        icon: Icons.location_on_rounded,
        iconColor: AppColors.primaryBlue,
        title: 'Location',
        description: 'Allow access to your location for nurse booking.',
      ),
      _PermissionItem(
        id: 'notifications',
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFFF59E0B),
        title: 'Notifications',
        description: 'Get updates about your bookings and appointments.',
      ),
      _PermissionItem(
        id: 'camera',
        icon: Icons.videocam_rounded,
        iconColor: const Color(0xFF8B5CF6),
        title: 'Camera',
        description: 'For video consultations with healthcare providers.',
      ),
      _PermissionItem(
        id: 'microphone',
        icon: Icons.mic_rounded,
        iconColor: AppColors.successGreen,
        title: 'Microphone',
        description: 'For calls and video consultations.',
      ),
    ];
  }

  bool get _allGranted {
    return _permissions.every((permission) => permission.isGranted);
  }

  int get _grantedCount {
    return _permissions.where((permission) => permission.isGranted).length;
  }

  double get _progress {
    if (_permissions.isEmpty) {
      return 0;
    }

    return _grantedCount / _permissions.length;
  }

  void _togglePermission(String id) {
    if (_isProcessing) return;

    setState(() {
      final item = _permissions.firstWhere(
        (permission) => permission.id == id,
      );

      item.isGranted = !item.isGranted;
    });
  }

  void _setPermission(String id, bool value) {
    if (_isProcessing) return;

    setState(() {
      final item = _permissions.firstWhere(
        (permission) => permission.id == id,
      );

      item.isGranted = value;
    });
  }

  Future<void> _grantAllPermissions() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // TODO: Replace this simulated delay with real permission_handler requests.
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      for (final permission in _permissions) {
        permission.isGranted = true;
      }

      _isProcessing = false;
    });

    _showSnackBar(
      AppStrings.allGranted,
      isSuccess: true,
    );
  }

  void _continueToHome() {
    context.go(AppRoutes.patientHome);
  }

  Future<void> _handlePrimaryAction() async {
    if (_allGranted) {
      _continueToHome();
      return;
    }

    await _grantAllPermissions();
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
    final primaryLabel =
        _allGranted ? AppStrings.continueText : AppStrings.grantPermissions;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.permissions),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(
                grantedCount: _grantedCount,
                totalCount: _permissions.length,
                progress: _progress,
              ),

              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: ListView.separated(
                  itemCount: _permissions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final permission = _permissions[index];

                    return _PermissionCard(
                      permission: permission,
                      enabled: !_isProcessing,
                      onTap: () => _togglePermission(permission.id),
                      onChanged: (value) =>
                          _setPermission(permission.id, value),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              CustomButton(
                label: primaryLabel,
                isLoading: _isProcessing,
                backgroundColor: _allGranted
                    ? AppColors.successGreen
                    : AppColors.primaryBlue,
                onPressed: _isProcessing ? null : _handlePrimaryAction,
              ),

              const SizedBox(height: AppSpacing.lg),

              CustomButton(
                label: AppStrings.skipForNow,
                isOutlined: true,
                onPressed: _isProcessing ? null : _continueToHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  final int grantedCount;
  final int totalCount;
  final double progress;

  const _HeaderSection({
    required this.grantedCount,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: const Icon(
            Icons.privacy_tip_rounded,
            color: AppColors.primaryBlue,
            size: 34,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          AppStrings.requiredPermissions,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          AppStrings.permissionsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgGray,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$grantedCount of $totalCount granted',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: AppColors.borderGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final _PermissionItem permission;
  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<bool> onChanged;

  const _PermissionCard({
    required this.permission,
    required this.enabled,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            color: permission.isGranted ? AppColors.lightBlue : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: permission.isGranted
                  ? AppColors.primaryBlue
                  : AppColors.borderGray,
              width: permission.isGranted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: permission.isGranted
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: permission.isGranted ? 24 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppConstants.animationDuration,
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: permission.iconColor.withValues(
                    alpha: permission.isGranted ? 0.16 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  permission.icon,
                  color: permission.iconColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      permission.description,
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

              Switch(
                value: permission.isGranted,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private model
// -----------------------------------------------------------------------------

class _PermissionItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  bool isGranted;

  _PermissionItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.isGranted = false,
  });
}