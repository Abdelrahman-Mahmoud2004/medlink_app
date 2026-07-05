import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../auth/presentation/providers/patient_provider.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              onPressed: () => dialogContext.pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(patientProfileProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _ProfileHeader(profile: profile),

            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: _ProfileStatCard(
                    label: 'Total Bookings',
                    value: '${profile.totalBookings}',
                    icon: Icons.event_available_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ProfileStatCard(
                    label: 'Upcoming',
                    value: '${profile.upcomingBookings}',
                    icon: Icons.schedule_rounded,
                    color: AppColors.warningOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            _SectionTitle(title: 'Account'),

            const SizedBox(height: AppSpacing.md),

            _ProfileTile(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              subtitle: 'Name, email and phone number',
              onTap: () => _showComingSoon(context, 'Personal Information'),
            ),
            _ProfileTile(
              icon: Icons.location_on_outlined,
              title: 'Address Manager',
              subtitle: 'Manage home and work addresses',
              onTap: () => _showComingSoon(context, 'Address Manager'),
            ),
            _ProfileTile(
              icon: Icons.family_restroom_rounded,
              title: 'Family Members',
              subtitle: 'Dependents and relatives profiles',
              onTap: () => _showComingSoon(context, 'Family Members'),
            ),
            _ProfileTile(
              icon: Icons.medical_information_outlined,
              title: 'Medical Records',
              subtitle: 'History, allergies and conditions',
              onTap: () => _showComingSoon(context, 'Medical Records'),
            ),
            _ProfileTile(
              icon: Icons.medication_outlined,
              title: 'Medication Schedule',
              subtitle: 'Track medicines and reminders',
              onTap: () => _showComingSoon(context, 'Medication Schedule'),
            ),

            const SizedBox(height: AppSpacing.xl),

            _SectionTitle(title: 'App'),

            const SizedBox(height: AppSpacing.md),

            _ProfileTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: unreadCount > 0
                  ? '$unreadCount unread notifications'
                  : 'You are all caught up',
              trailingBadge: unreadCount > 0 ? '$unreadCount' : null,
              onTap: () => context.push(AppRoutes.notificationsCenter),
            ),
            _ProfileTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
              subtitle: 'Refunds, cashback and balance',
              onTap: () => context.push(AppRoutes.patientWallet),
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Preferences and account options',
              onTap: () => _showComingSoon(context, 'Settings'),
            ),
            _ProfileTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'Change app language',
              onTap: () => context.push(AppRoutes.language),
            ),

            const SizedBox(height: AppSpacing.xl),

            _SectionTitle(title: 'Support'),

            const SizedBox(height: AppSpacing.md),

            _ProfileTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Get help or open a support ticket',
              onTap: () => _showComingSoon(context, 'Help & Support'),
            ),
            _ProfileTile(
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
              subtitle: 'Read app policies and terms',
              onTap: () => _showComingSoon(context, 'Terms & Privacy'),
            ),
            _ProfileTile(
              icon: Icons.info_outline_rounded,
              title: 'About App',
              subtitle: 'Version and app information',
              onTap: () => _showComingSoon(context, 'About App'),
            ),

            const SizedBox(height: AppSpacing.xl),

            _ProfileTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              color: AppColors.errorRed,
              onTap: () => _confirmLogout(context),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final PatientProfile profile;

  const _ProfileHeader({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.imageUrl.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.lightBlue,
            child: ClipOval(
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryBlue,
                      size: 52,
                    )
                  : Image.network(
                      imageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryBlue,
                        size: 52,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            profile.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.phone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingBadge;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingBadge,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tileColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    icon,
                    color: tileColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color ?? AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                if (trailingBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      trailingBadge!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}