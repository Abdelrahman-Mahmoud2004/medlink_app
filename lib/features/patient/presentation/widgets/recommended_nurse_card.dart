import 'package:flutter/material.dart';

import '../../../../config/theme.dart';
import '../../data/models/nurse_model.dart';

class RecommendedNurseCard extends StatelessWidget {
  final NurseModel nurse;
  final VoidCallback onTap;
  final VoidCallback onBookTap;

  const RecommendedNurseCard({
    super.key,
    required this.nurse,
    required this.onTap,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.borderGray),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NurseAvatar(nurse: nurse),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _NurseMainInfo(nurse: nurse),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _RateBadge(rate: nurse.hourlyRate),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  _RatingInfo(
                    rating: nurse.safeRating,
                    reviewCount: nurse.reviewCount,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _AvailabilityChip(nurse: nurse),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderGray),
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: onBookTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
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

class _NurseMainInfo extends StatelessWidget {
  final NurseModel nurse;

  const _NurseMainInfo({
    required this.nurse,
  });

  @override
  Widget build(BuildContext context) {
    final name = nurse.name.trim().isEmpty ? 'Healthcare Provider' : nurse.name;
    final specialty =
        nurse.specialty.trim().isEmpty ? 'Home Healthcare' : nurse.specialty;
    final experience =
        nurse.experience.trim().isEmpty ? 'Experience not specified' : nurse.experience;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          specialty,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.work_history_rounded,
              color: AppColors.textLight,
              size: 15,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                experience,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NurseAvatar extends StatelessWidget {
  final NurseModel nurse;

  const _NurseAvatar({
    required this.nurse,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = nurse.imageUrl.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: imageUrl.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: AppColors.primaryBlue,
                  )
                : Image.network(
                    imageUrl,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: AppColors.primaryBlue,
                    ),
                  ),
          ),
        ),
        if (nurse.isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: AppColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RateBadge extends StatelessWidget {
  final String rate;

  const _RateBadge({
    required this.rate,
  });

  String _normalizedRate() {
    final cleanRate = rate.trim();

    if (cleanRate.isEmpty) {
      return 'EGP 0/hr';
    }

    if (cleanRate.toLowerCase().contains('/hr')) {
      return cleanRate;
    }

    return '$cleanRate/hr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 96),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        _normalizedRate(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _RatingInfo extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingInfo({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 17,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($reviewCount)',
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

class _AvailabilityChip extends StatelessWidget {
  final NurseModel nurse;

  const _AvailabilityChip({
    required this.nurse,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        nurse.isAvailable ? AppColors.successGreen : AppColors.textLight;

    final status = nurse.availabilityStatus.trim().isEmpty
        ? (nurse.isAvailable ? 'Available' : 'Unavailable')
        : nurse.availabilityStatus;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            nurse.isAvailable
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}