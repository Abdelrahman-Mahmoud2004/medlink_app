import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/nurse_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/recommended_nurse_card.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late final List<BookingModel> upcomingBookings;
  late final List<NurseModel> recommendedNurses;

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
  }

  void _initializeDummyData() {
    upcomingBookings = [
      BookingModel(
        id: '1',
        nurseName: 'Sara Ahmed',
        nurseImage: 'https://via.placeholder.com/150',
        serviceType: 'Post-Surgery Care',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        address: 'Cairo, Egypt',
        status: 'Confirmed',
        amount: 250.0,
        specialty: 'ICU Specialist',
      ),
      BookingModel(
        id: '2',
        nurseName: 'Layla Mahmoud',
        nurseImage: 'https://via.placeholder.com/150',
        serviceType: 'Home Care',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        address: 'Giza, Egypt',
        status: 'Pending',
        amount: 180.0,
        specialty: 'Pediatric Nurse',
      ),
    ];

    recommendedNurses = [
      const NurseModel(
        id: '1',
        name: 'Fatima Al-Sayed',
        specialty: 'ICU Specialist',
        imageUrl: 'https://via.placeholder.com/150',
        rating: 4.9,
        reviewCount: 124,
        hourlyRate: 'EGP 650',
        experience: '7 Years Exp.',
        isAvailable: true,
        availabilityStatus: 'Available today',
        patientsServed: 500,
        isCertified: true,
        isOnline: true,
      ),
      const NurseModel(
        id: '2',
        name: 'Ahmed Hassan',
        specialty: 'Geriatric Care',
        imageUrl: 'https://via.placeholder.com/150',
        rating: 4.8,
        reviewCount: 98,
        hourlyRate: 'EGP 550',
        experience: '5 Years Exp.',
        isAvailable: false,
        availabilityStatus: 'Next slot: 2pm',
        patientsServed: 320,
        isCertified: true,
        isOnline: false,
      ),
      const NurseModel(
        id: '3',
        name: 'Layla Mahmoud',
        specialty: 'Pediatric Nurse',
        imageUrl: 'https://via.placeholder.com/150',
        rating: 5.0,
        reviewCount: 156,
        hourlyRate: 'EGP 700',
        experience: '8 Years Exp.',
        isAvailable: true,
        availabilityStatus: 'Available now',
        patientsServed: 450,
        isCertified: true,
        isOnline: true,
      ),
    ];
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
      ),
    );
  }

  void _openNurseProfile(NurseModel nurse) {
    context.push(
      AppRoutes.nurseProfile,
      extra: nurse,
    );
  }

  void _startBooking(NurseModel nurse) {
    context.push(
      AppRoutes.selectDateTime,
      extra: nurse,
    );
  }

  void _openBookingDetails(BookingModel booking) {
    context.push(
      AppRoutes.bookingDetails,
      extra: booking,
    );
  }

  void _openBookings() {
    context.push(AppRoutes.patientBookings);
  }

  void _openWallet() {
    context.push(AppRoutes.patientWallet);
  }

  void _openProfile() {
    context.push(AppRoutes.patientProfile);
  }

  void _openMessages() {
    context.push(AppRoutes.patientMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.bgGray,
              elevation: 0,
              floating: false,
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Fatima',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  Text(
                    'Zagazig, Egypt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showComingSoon('Notifications'),
                      child: Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_rounded,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: AppColors.errorRed,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildUpcomingSection(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildRecommendedSection(context),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.patientDiscovery),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.textLight,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppStrings.searchBySpecializationOrName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
            ),
            const Icon(
              Icons.tune_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _QuickActionButton(
          icon: Icons.calendar_month_rounded,
          label: 'My Bookings',
          color: AppColors.primaryBlue,
          onTap: _openBookings,
        ),
        _QuickActionButton(
          icon: Icons.medication_rounded,
          label: 'Medications',
          color: AppColors.successGreen,
          onTap: () => _showComingSoon('Medications'),
        ),
        _QuickActionButton(
          icon: Icons.monitor_heart_rounded,
          label: 'Health Records',
          color: const Color(0xFF8B5CF6),
          onTap: () => _showComingSoon('Health Records'),
        ),
        _QuickActionButton(
          icon: Icons.sos_rounded,
          label: 'Emergency SOS',
          color: AppColors.errorRed,
          onTap: () => _showComingSoon('Emergency SOS'),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: AppStrings.upcomingBookings,
          actionLabel: AppStrings.seeAll,
          onActionTap: _openBookings,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (upcomingBookings.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingBookings.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              final booking = upcomingBookings[index];

              return BookingCard(
                booking: booking,
                onTap: () => _openBookingDetails(booking),
              );
            },
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    color: AppColors.textLight.withValues(alpha: 0.6),
                    size: 56,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.noUpcomingBookings,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.patientDiscovery),
                    child: const Text(AppStrings.bookNurse),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: AppStrings.recommendedNurses,
          actionLabel: AppStrings.seeAll,
          onActionTap: () => context.push(AppRoutes.patientDiscovery),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendedNurses.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) {
            final nurse = recommendedNurses[index];

            return RecommendedNurseCard(
              nurse: nurse,
              onTap: () => _openNurseProfile(nurse),
              onBookTap: () => _startBooking(nurse),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              return;
            case 1:
              _openBookings();
              break;
            case 2:
              _openWallet();
              break;
            case 3:
              _openMessages();
              break;
            case 4:
              _openProfile();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            activeIcon: Icon(Icons.home_filled),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Bookings',
            activeIcon: Icon(Icons.event_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Messages',
            activeIcon: Icon(Icons.chat_bubble_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
            activeIcon: Icon(Icons.person_rounded),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(
            actionLabel,
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  size: 25,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 10.5,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}