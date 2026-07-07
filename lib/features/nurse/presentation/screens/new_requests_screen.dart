import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../patient/data/models/request_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class NewRequestsScreen extends StatefulWidget {
  const NewRequestsScreen({super.key});

  @override
  State<NewRequestsScreen> createState() => _NewRequestsScreenState();
}

class _NewRequestsScreenState extends State<NewRequestsScreen> {
  late List<RequestModel> _requests;

  final ValueNotifier<String> _filterNotifier = ValueNotifier<String>('All');

  @override
  void initState() {
    super.initState();
    _requests = List<RequestModel>.of(NurseMockData.activeRequests);
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  List<RequestModel> _filteredRequests(String filter) {
    if (filter == 'All') return _requests;

    if (filter == 'Active') {
      return _requests
          .where((request) => request.status == RequestStatus.active)
          .toList(growable: false);
    }

    if (filter == 'Scheduled') {
      return _requests
          .where((request) => request.status == RequestStatus.scheduled)
          .toList(growable: false);
    }

    return _requests;
  }

  Color _statusColor(RequestStatus status) {
    return switch (status) {
      RequestStatus.active => AppColors.successGreen,
      RequestStatus.scheduled => AppColors.warningOrange,
      RequestStatus.completed => AppColors.primaryBlue,
      RequestStatus.cancelled => AppColors.errorRed,
      RequestStatus.unknown => AppColors.textLight,
    };
  }

  void _accept(RequestModel request) {
    setState(() {
      _requests.removeWhere((item) => item.id == request.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted ${request.patientName} request'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.push(AppRoutes.nurseRequestDetails, extra: request);
  }

  void _decline(RequestModel request) {
    setState(() {
      _requests.removeWhere((item) => item.id == request.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined ${request.patientName} request'),
      ),
    );
  }

  void _openDetails(RequestModel request) {
    context.push(AppRoutes.nurseRequestDetails, extra: request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('New Requests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    _SummaryCard(requestCount: _requests.length),
                    const SizedBox(height: AppSpacing.xl),
                    _FilterChips(filterNotifier: _filterNotifier),
                    const SizedBox(height: AppSpacing.lg),
                    ValueListenableBuilder<String>(
                      valueListenable: _filterNotifier,
                      builder: (context, filter, _) {
                        final items = _filteredRequests(filter);

                        if (items.isEmpty) {
                          return const _EmptyRequests();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.lg),
                          itemBuilder: (context, index) {
                            final request = items[index];

                            return _RequestTile(
                              request: request,
                              statusColor: _statusColor(request.status),
                              onTap: () => _openDetails(request),
                              onAccept: () => _accept(request),
                              onDecline: () => _decline(request),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int requestCount;

  const _SummaryCard({
    required this.requestCount,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$requestCount new requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Review, accept, or decline patient requests.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ValueNotifier<String> filterNotifier;

  const _FilterChips({
    required this.filterNotifier,
  });

  static const filters = ['All', 'Active', 'Scheduled'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: filterNotifier,
      builder: (context, selected, _) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = selected == filter;

              return GestureDetector(
                onTap: () => filterNotifier.value = filter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
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
                  ),
                  child: Text(
                    filter,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textDark,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  final RequestModel request;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestTile({
    required this.request,
    required this.statusColor,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: _Decorations.card(),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.lightBlue,
                        child: ClipOval(
                          child: Image.network(
                            request.patientImage,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              request.serviceType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: request.status.label,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.location_on_outlined,
                          text: '${request.distance} km',
                        ),
                      ),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.access_time_rounded,
                          text: '${request.duration} hrs',
                        ),
                      ),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.payments_outlined,
                          text: 'EGP ${request.calculatedPay.toStringAsFixed(0)}',
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDecline,
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: onAccept,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _Decorations.card(),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textLight.withValues(alpha: 0.75),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No requests available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryBlue;

    return Row(
      children: [
        Icon(icon, size: 16, color: chipColor),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color ?? AppColors.textDark,
                ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}