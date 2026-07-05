import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/booking_model.dart';
import '../../../auth/presentation/providers/patient_provider.dart';
import '../widgets/booking_card.dart';

enum _BookingFilter {
  all,
  upcoming,
  completed,
  cancelled,
}

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  _BookingFilter _filter = _BookingFilter.all;

  List<BookingModel> _applyFilter(List<BookingModel> bookings) {
    switch (_filter) {
      case _BookingFilter.all:
        return bookings;
      case _BookingFilter.upcoming:
        return bookings.where((booking) => booking.isActive).toList();
      case _BookingFilter.completed:
        return bookings.where((booking) => booking.isCompleted).toList();
      case _BookingFilter.cancelled:
        return bookings.where((booking) => booking.isCancelled).toList();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _openDetails(BookingModel booking) {
    context.push(
      AppRoutes.bookingDetails,
      extra: booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(allBookingsProvider);
    final filteredBookings = _applyFilter(allBookings);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('My Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterChips(
              selectedFilter: _filter,
              onChanged: (filter) {
                setState(() => _filter = filter);
              },
            ),
            Expanded(
              child: filteredBookings.isEmpty
                  ? const _EmptyBookings()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: filteredBookings.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];

                        return BookingCard(
                          booking: booking,
                          onTap: () => _openDetails(booking),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final _BookingFilter selectedFilter;
  final ValueChanged<_BookingFilter> onChanged;

  const _FilterChips({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = {
      _BookingFilter.all: 'All',
      _BookingFilter.upcoming: 'Upcoming',
      _BookingFilter.completed: 'Completed',
      _BookingFilter.cancelled: 'Cancelled',
    };

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final entry = options.entries.elementAt(index);
          final isSelected = selectedFilter == entry.key;

          return GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.borderGray,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.025),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                entry.value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textDark,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 46,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your bookings will appear here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}