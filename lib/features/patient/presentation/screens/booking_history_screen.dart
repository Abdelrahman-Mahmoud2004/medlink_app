import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/booking_model.dart';
import '../../providers/patient_provider.dart';
import '../widgets/booking_card.dart';

enum _BookingFilter {
  all,
  upcoming,
  completed,
  cancelled,
}

enum _BookingBucket {
  active,
  completed,
  cancelled,
  other,
}

extension _BookingFilterX on _BookingFilter {
  String get label {
    switch (this) {
      case _BookingFilter.all:
        return 'All';
      case _BookingFilter.upcoming:
        return 'Upcoming';
      case _BookingFilter.completed:
        return 'Completed';
      case _BookingFilter.cancelled:
        return 'Cancelled';
    }
  }

  String get emptyTitle {
    switch (this) {
      case _BookingFilter.all:
        return 'No bookings found';
      case _BookingFilter.upcoming:
        return 'No upcoming bookings';
      case _BookingFilter.completed:
        return 'No completed bookings';
      case _BookingFilter.cancelled:
        return 'No cancelled bookings';
    }
  }

  String get emptySubtitle {
    switch (this) {
      case _BookingFilter.all:
        return 'Your bookings will appear here.';
      case _BookingFilter.upcoming:
        return 'Your upcoming appointments will appear here.';
      case _BookingFilter.completed:
        return 'Completed visits will appear here.';
      case _BookingFilter.cancelled:
        return 'Cancelled bookings will appear here.';
    }
  }

  IconData get emptyIcon {
    switch (this) {
      case _BookingFilter.all:
        return Icons.event_busy_rounded;
      case _BookingFilter.upcoming:
        return Icons.event_available_rounded;
      case _BookingFilter.completed:
        return Icons.task_alt_rounded;
      case _BookingFilter.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final _bookingFilterProvider = StateProvider.autoDispose<_BookingFilter>(
  (ref) => _BookingFilter.all,
);

final _bookingHistoryDataProvider =
    Provider.autoDispose<_BookingHistoryData>((ref) {
  final bookings = ref.watch(allBookingsProvider);

  return _BookingHistoryData.fromBookings(bookings);
});

final _visibleBookingsProvider =
    Provider.autoDispose<List<BookingModel>>((ref) {
  final selectedFilter = ref.watch(_bookingFilterProvider);
  final data = ref.watch(_bookingHistoryDataProvider);

  return data.listFor(selectedFilter);
});

// -----------------------------------------------------------------------------
// Optimized computed data
// -----------------------------------------------------------------------------

class _BookingHistoryData {
  final List<BookingModel> all;
  final List<BookingModel> upcoming;
  final List<BookingModel> completed;
  final List<BookingModel> cancelled;

  const _BookingHistoryData({
    required this.all,
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });

  factory _BookingHistoryData.fromBookings(List<BookingModel> bookings) {
    final activeBookings = <BookingModel>[];
    final completedBookings = <BookingModel>[];
    final cancelledBookings = <BookingModel>[];
    final otherBookings = <BookingModel>[];

    for (final booking in bookings) {
      switch (_bucketOf(booking)) {
        case _BookingBucket.active:
          activeBookings.add(booking);
          break;
        case _BookingBucket.completed:
          completedBookings.add(booking);
          break;
        case _BookingBucket.cancelled:
          cancelledBookings.add(booking);
          break;
        case _BookingBucket.other:
          otherBookings.add(booking);
          break;
      }
    }

    activeBookings.sort(_compareDateAscending);
    completedBookings.sort(_compareDateDescending);
    cancelledBookings.sort(_compareDateDescending);
    otherBookings.sort(_compareDateDescending);

    final allBookings = <BookingModel>[
      ...activeBookings,
      ...completedBookings,
      ...cancelledBookings,
      ...otherBookings,
    ];

    return _BookingHistoryData(
      all: List.unmodifiable(allBookings),
      upcoming: List.unmodifiable(activeBookings),
      completed: List.unmodifiable(completedBookings),
      cancelled: List.unmodifiable(cancelledBookings),
    );
  }

  List<BookingModel> listFor(_BookingFilter filter) {
    switch (filter) {
      case _BookingFilter.all:
        return all;
      case _BookingFilter.upcoming:
        return upcoming;
      case _BookingFilter.completed:
        return completed;
      case _BookingFilter.cancelled:
        return cancelled;
    }
  }
}

_BookingBucket _bucketOf(BookingModel booking) {
  if (booking.isActive) {
    return _BookingBucket.active;
  }

  if (booking.isCompleted) {
    return _BookingBucket.completed;
  }

  if (booking.isCancelled) {
    return _BookingBucket.cancelled;
  }

  return _BookingBucket.other;
}

int _compareDateAscending(BookingModel a, BookingModel b) {
  final dateCompare = a.dateTime.compareTo(b.dateTime);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return a.id.compareTo(b.id);
}

int _compareDateDescending(BookingModel a, BookingModel b) {
  final dateCompare = b.dateTime.compareTo(a.dateTime);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return a.id.compareTo(b.id);
}

// -----------------------------------------------------------------------------
// Screen
// -----------------------------------------------------------------------------

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('My Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      body: const SafeArea(
        child: _BookingHistoryContent(),
      ),
    );
  }
}

class _BookingHistoryContent extends ConsumerWidget {
  const _BookingHistoryContent();

  void _openDetails(BuildContext context, BookingModel booking) {
    context.push(
      AppRoutes.bookingDetails,
      extra: booking,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(_bookingFilterProvider);
    final visibleBookings = ref.watch(_visibleBookingsProvider);

    return Column(
      children: [
        _FilterChips(
          selectedFilter: selectedFilter,
          onChanged: (filter) {
            ref.read(_bookingFilterProvider.notifier).state = filter;
          },
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: visibleBookings.isEmpty
                ? _EmptyBookings(
                    key: ValueKey<String>('empty-${selectedFilter.name}'),
                    filter: selectedFilter,
                  )
                : _BookingsList(
                    key: ValueKey<String>(
                      'list-${selectedFilter.name}-${visibleBookings.length}',
                    ),
                    bookings: visibleBookings,
                    onBookingTap: (booking) => _openDetails(context, booking),
                  ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Bookings list
// -----------------------------------------------------------------------------

class _BookingsList extends StatelessWidget {
  final List<BookingModel> bookings;
  final ValueChanged<BookingModel> onBookingTap;

  const _BookingsList({
    super.key,
    required this.bookings,
    required this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return BookingCard(
          key: ValueKey<String>(
            booking.id.isNotEmpty
                ? booking.id
                : '${booking.dateTime.millisecondsSinceEpoch}-$index',
          ),
          booking: booking,
          onTap: () => onBookingTap(booking),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Filter chips
// -----------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  final _BookingFilter selectedFilter;
  final ValueChanged<_BookingFilter> onChanged;

  const _FilterChips({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = _BookingFilter.values;

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: isSelected ? null : () => onChanged(filter),
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
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderGray,
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
                  filter.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            isSelected ? AppColors.white : AppColors.textDark,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _EmptyBookings extends StatelessWidget {
  final _BookingFilter filter;

  const _EmptyBookings({
    super.key,
    required this.filter,
  });

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
              child: Icon(
                filter.emptyIcon,
                size: 46,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              filter.emptyTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              filter.emptySubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}