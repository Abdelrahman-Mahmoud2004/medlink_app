import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../patient/data/models/request_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RequestModel? request;

  const RequestDetailsScreen({
    super.key,
    this.request,
  });

  RequestModel get _safeRequest {
    return request ?? NurseMockData.activeRequests.first;
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
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

  VisitModelPayload _toVisitPayload(RequestModel request) {
    return VisitModelPayload.fromRequest(request);
  }

  void _startNavigation(BuildContext context, RequestModel request) {
    context.push(AppRoutes.nurseGpsNavigation, extra: request);
  }

  void _startVisit(BuildContext context, RequestModel request) {
    context.push(AppRoutes.nurseActiveVisit, extra: _toVisitPayload(request));
  }

  void _accept(BuildContext context, RequestModel request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted ${request.patientName} request'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    _startNavigation(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final item = _safeRequest;
    final statusColor = _statusColor(item.status);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Request Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
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
                    _PatientHeader(
                      request: item,
                      statusColor: statusColor,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _RequestInfoCard(request: item),
                    const SizedBox(height: AppSpacing.xl),
                    _LocationCard(
                      request: item,
                      onNavigate: () => _startNavigation(context, item),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _NotesCard(notes: item.notes),
                    const SizedBox(height: AppSpacing.xl),
                    _ActionPanel(
                      request: item,
                      onAccept: () => _accept(context, item),
                      onStartVisit: () => _startVisit(context, item),
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

class VisitModelPayload {
  final String id;
  final String patientName;
  final String serviceType;
  final String location;
  final double durationInHours;
  final String notes;

  const VisitModelPayload({
    required this.id,
    required this.patientName,
    required this.serviceType,
    required this.location,
    required this.durationInHours,
    required this.notes,
  });

  factory VisitModelPayload.fromRequest(RequestModel request) {
    return VisitModelPayload(
      id: request.id,
      patientName: request.patientName,
      serviceType: request.serviceType,
      location: request.location,
      durationInHours: request.duration,
      notes: request.notes,
    );
  }
}

class _PatientHeader extends StatelessWidget {
  final RequestModel request;
  final Color statusColor;

  const _PatientHeader({
    required this.request,
    required this.statusColor,
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
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.white,
              child: ClipOval(
                child: Image.network(
                  request.patientImage,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryBlue,
                    size: 36,
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    request.serviceType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StatusPill(
                    label: request.status.label,
                    color: statusColor,
                    onDark: true,
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

class _RequestInfoCard extends StatelessWidget {
  final RequestModel request;

  const _RequestInfoCard({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Request Information',
      child: Column(
        children: [
          _DetailRow(
            label: 'Specialty',
            value: request.specialty,
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Requested Time',
            value:
                '${AppDateFormatters.mediumDate(request.requestedTime)} · ${AppDateFormatters.time24(request.requestedTime)}',
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Duration',
            value: '${request.duration} hours',
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Estimated Pay',
            value: 'EGP ${request.calculatedPay.toStringAsFixed(0)}',
            valueColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onNavigate;

  const _LocationCard({
    required this.request,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Location',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${request.distance} km away',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onNavigate,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.primaryBlue,
            ),
            icon: const Icon(Icons.navigation_rounded),
            label: const Text('Open Navigation'),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Patient Notes',
      child: Text(
        notes.trim().isEmpty ? 'No additional notes.' : notes,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textDark,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onStartVisit;

  const _ActionPanel({
    required this.request,
    required this.onAccept,
    required this.onStartVisit,
  });

  @override
  Widget build(BuildContext context) {
    final canAccept = request.status == RequestStatus.active;
    final canStartVisit = request.status == RequestStatus.scheduled;

    return Column(
      children: [
        if (canAccept)
          FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.successGreen,
            ),
            child: const Text('Accept Request'),
          ),
        if (canStartVisit)
          FilledButton(
            onPressed: onStartVisit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Start Visit'),
          ),
        if (!canAccept && !canStartVisit)
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Back'),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor ?? AppColors.textDark,
                  fontWeight: FontWeight.w800,
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
  final bool onDark;

  const _StatusPill({
    required this.label,
    required this.color,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: onDark ? AppColors.white.withValues(alpha: 0.15) : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: onDark ? AppColors.white : color,
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