import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/review_model.dart';

enum _ReviewFilter {
  all,
  five,
  four,
  threeOrLess,
  withPhotos,
}

class ReviewsFullListScreen extends StatefulWidget {
  final String title;
  final List<ReviewModel> reviews;

  const ReviewsFullListScreen({
    super.key,
    this.title = 'Reviews',
    this.reviews = const [],
  });

  @override
  State<ReviewsFullListScreen> createState() => _ReviewsFullListScreenState();
}

class _ReviewsFullListScreenState extends State<ReviewsFullListScreen> {
  _ReviewFilter _filter = _ReviewFilter.all;

  late final List<ReviewModel> _reviews;

  @override
  void initState() {
    super.initState();

    _reviews = widget.reviews.isNotEmpty ? widget.reviews : _mockReviews;
  }

  List<ReviewModel> get _filteredReviews {
    switch (_filter) {
      case _ReviewFilter.all:
        return _reviews;
      case _ReviewFilter.five:
        return _reviews.where((review) => review.safeRating >= 5).toList();
      case _ReviewFilter.four:
        return _reviews.where((review) {
          return review.safeRating >= 4 && review.safeRating < 5;
        }).toList();
      case _ReviewFilter.threeOrLess:
        return _reviews.where((review) => review.safeRating <= 3).toList();
      case _ReviewFilter.withPhotos:
        return _reviews.where((review) => review.hasPhotos).toList();
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;

    final total = _reviews.fold<double>(
      0.0,
      (sum, review) => sum + review.safeRating,
    );

    return total / _reviews.length;
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientDiscovery);
  }

  @override
  Widget build(BuildContext context) {
    final filteredReviews = _filteredReviews;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _RatingSummary(
              averageRating: _averageRating,
              reviewCount: _reviews.length,
            ),
            _FilterChips(
              selectedFilter: _filter,
              onChanged: (filter) {
                setState(() => _filter = filter);
              },
            ),
            Expanded(
              child: filteredReviews.isEmpty
                  ? const _EmptyReviewsState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: filteredReviews.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final review = filteredReviews[index];

                        return _ReviewCard(review: review);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<ReviewModel> _mockReviews = [
  ReviewModel(
    id: '1',
    patientName: 'Mona A.',
    patientImage: 'https://i.pravatar.cc/150?img=41',
    rating: 5,
    text:
        'Excellent care and very professional service. The visit was well organized and helpful.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ReviewModel(
    id: '2',
    patientName: 'Ali S.',
    patientImage: 'https://i.pravatar.cc/150?img=12',
    rating: 4,
    text:
        'Good communication and clear instructions. I would book again for another home visit.',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  ReviewModel(
    id: '3',
    patientName: 'Nour H.',
    patientImage: 'https://i.pravatar.cc/150?img=35',
    rating: 5,
    text:
        'Very good experience. The provider arrived on time and explained everything clearly.',
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    photos: const ['visit_photo.jpg'],
  ),
];

class _RatingSummary extends StatelessWidget {
  final double averageRating;
  final int reviewCount;

  const _RatingSummary({
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 46,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$reviewCount reviews',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
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

class _FilterChips extends StatelessWidget {
  final _ReviewFilter selectedFilter;
  final ValueChanged<_ReviewFilter> onChanged;

  const _FilterChips({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = {
      _ReviewFilter.all: 'All',
      _ReviewFilter.five: '5 Stars',
      _ReviewFilter.four: '4 Stars',
      _ReviewFilter.threeOrLess: '≤ 3 Stars',
      _ReviewFilter.withPhotos: 'Photos',
    };

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final entry = options.entries.elementAt(index);
          final isSelected = selectedFilter == entry.key;

          return GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.borderGray,
                ),
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

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({
    required this.review,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = review.patientImage.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.lightBlue,
                child: ClipOval(
                  child: imageUrl.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryBlue,
                        )
                      : Image.network(
                          imageUrl,
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
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.displayPatientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                          ),
                    ),
                  ],
                ),
              ),
              _Stars(rating: review.safeRating),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            review.text.trim().isEmpty ? 'No review text provided.' : review.text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark,
                  height: 1.5,
                ),
          ),
          if (review.hasPhotos) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: review.photos.map((photo) {
                return Chip(
                  label: Text(photo),
                  avatar: const Icon(
                    Icons.image_rounded,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                  backgroundColor: AppColors.lightBlue,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;

  const _Stars({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final selected = rating >= index + 1;

        return Icon(
          selected ? Icons.star_rounded : Icons.star_border_rounded,
          color: selected ? Colors.amber : AppColors.borderGray,
          size: 18,
        );
      }),
    );
  }
}

class _EmptyReviewsState extends StatelessWidget {
  const _EmptyReviewsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              color: AppColors.textLight,
              size: 68,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No reviews found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try selecting another review filter.',
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