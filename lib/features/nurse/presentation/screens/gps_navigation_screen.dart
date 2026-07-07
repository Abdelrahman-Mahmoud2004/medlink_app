import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../patient/data/models/request_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class GpsNavigationScreen extends StatelessWidget {
  final RequestModel? request;

  const GpsNavigationScreen({
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

  void _startVisit(BuildContext context, RequestModel request) {
    context.push(AppRoutes.nurseActiveVisit, extra: VisitNavigationPayload.fromRequest(request));
  }

  @override
  Widget build(BuildContext context) {
    final item = _safeRequest;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('GPS Navigation'),
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
                    _MapPreview(request: item),
                    const SizedBox(height: AppSpacing.xl),
                    _TripSummary(request: item),
                    const SizedBox(height: AppSpacing.xl),
                    _PatientDestinationCard(request: item),
                    const SizedBox(height: AppSpacing.xl),
                    _NavigationActions(
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

class VisitNavigationPayload {
  final String id;
  final String patientName;
  final String serviceType;
  final String location;
  final double durationInHours;
  final String notes;

  const VisitNavigationPayload({
    required this.id,
    required this.patientName,
    required this.serviceType,
    required this.location,
    required this.durationInHours,
    required this.notes,
  });

  factory VisitNavigationPayload.fromRequest(RequestModel request) {
    return VisitNavigationPayload(
      id: request.id,
      patientName: request.patientName,
      serviceType: request.serviceType,
      location: request.location,
      durationInHours: request.duration,
      notes: request.notes,
    );
  }
}

class _MapPreview extends StatelessWidget {
  final RequestModel request;

  const _MapPreview({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 330,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CustomPaint(
              painter: _MapGridPainter(),
              size: Size.infinite,
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _RoutePainter(),
              ),
            ),
            const Positioned(
              left: 42,
              bottom: 58,
              child: _MapMarker(
                icon: Icons.local_hospital_rounded,
                label: 'You',
                color: AppColors.primaryBlue,
              ),
            ),
            Positioned(
              right: 42,
              top: 58,
              child: _MapMarker(
                icon: Icons.home_rounded,
                label: request.patientName,
                color: AppColors.errorRed,
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.navigation_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '${request.distance} km · Estimated ${math.max(5, (request.distance * 6).round())} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
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

class _TripSummary extends StatelessWidget {
  final RequestModel request;

  const _TripSummary({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final estimatedMinutes = math.max(5, (request.distance * 6).round());

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.route_rounded,
            label: 'Distance',
            value: '${request.distance} km',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            label: 'ETA',
            value: '$estimatedMinutes min',
            color: AppColors.warningOrange,
          ),
        ),
      ],
    );
  }
}

class _PatientDestinationCard extends StatelessWidget {
  final RequestModel request;

  const _PatientDestinationCard({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _Decorations.card(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.errorRed,
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
                  request.patientName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationActions extends StatelessWidget {
  final VoidCallback onStartVisit;

  const _NavigationActions({
    required this.onStartVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: onStartVisit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            minimumSize: const Size(double.infinity, 52),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Arrived - Start Visit'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('External maps integration coming soon'),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.map_outlined),
          label: const Text('Open in Maps'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
            Icon(icon, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 9,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.lightBlue.withValues(alpha: 0.45);
    canvas.drawRect(Offset.zero & size, background);

    final gridPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const gap = 32.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(65, size.height - 70)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.60,
        size.width * 0.62,
        size.height * 0.68,
        size.width - 70,
        90,
      );

    canvas.drawPath(path, routePaint);

    final dashPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => false;
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