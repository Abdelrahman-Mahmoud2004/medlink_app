import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/nurse_model.dart';

class RatingReviewScreen extends StatefulWidget {
  final BookingModel? booking;
  final NurseModel? nurse;

  const RatingReviewScreen({
    super.key,
    this.booking,
    this.nurse,
  });

  @override
  State<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();

  double _rating = 5.0;
  bool _isSubmitting = false;

  final Set<String> _selectedTags = {};

  static const List<String> _reviewTags = [
    'Professional',
    'On time',
    'Kind',
    'Helpful',
    'Clean',
    'Good communication',
    'Highly recommended',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String get _providerName {
    final nurseName = widget.nurse?.name.trim();

    if (nurseName != null && nurseName.isNotEmpty) {
      return nurseName;
    }

    final bookingName = widget.booking?.nurseName.trim();

    if (bookingName != null && bookingName.isNotEmpty) {
      return bookingName;
    }

    return 'Healthcare Provider';
  }

  String get _providerImage {
    final nurseImage = widget.nurse?.imageUrl.trim();

    if (nurseImage != null && nurseImage.isNotEmpty) {
      return nurseImage;
    }

    final bookingImage = widget.booking?.nurseImage.trim();

    if (bookingImage != null && bookingImage.isNotEmpty) {
      return bookingImage;
    }

    return '';
  }

  String get _specialty {
    final nurseSpecialty = widget.nurse?.specialty.trim();

    if (nurseSpecialty != null && nurseSpecialty.isNotEmpty) {
      return nurseSpecialty;
    }

    final bookingSpecialty = widget.booking?.specialty.trim();

    if (bookingSpecialty != null && bookingSpecialty.isNotEmpty) {
      return bookingSpecialty;
    }

    return 'Home Healthcare';
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.bookingHistory);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    final reviewText = _reviewController.text.trim();

    if (_rating <= 0) {
      _showSnackBar('Please select a rating', isError: true);
      return;
    }

    if (reviewText.isEmpty && _selectedTags.isEmpty) {
      _showSnackBar(
        'Please write a review or select at least one tag',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    _showSuccessDialog();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : null,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Review Submitted'),
          content: const Text(
            'Thank you for sharing your feedback. Your review helps other patients choose trusted care providers.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                dialogContext.pop();

                if (!mounted) return;

                context.go(AppRoutes.bookingHistory);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  String _ratingLabel() {
    if (_rating >= 4.5) return 'Excellent';
    if (_rating >= 4.0) return 'Very Good';
    if (_rating >= 3.0) return 'Good';
    if (_rating >= 2.0) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Rate Your Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSubmitting ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProviderHeader(
                      name: _providerName,
                      specialty: _specialty,
                      imageUrl: _providerImage,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            'How was your visit?',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _ratingLabel(),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _StarRating(
                            rating: _rating,
                            onChanged: (value) {
                              setState(() => _rating = value);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'What stood out?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: _reviewTags.map((tag) {
                        final selected = _selectedTags.contains(tag);

                        return GestureDetector(
                          onTap: () => _toggleTag(tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryBlue
                                  : AppColors.bgGray,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.borderGray,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected) ...[
                                  const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Text(
                                  tag,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: selected
                                            ? AppColors.white
                                            : AppColors.textDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Write a Review',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    TextField(
                      controller: _reviewController,
                      minLines: 5,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText:
                            'Share your experience with the visit and the provider...',
                        filled: true,
                        fillColor: AppColors.bgGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide:
                              const BorderSide(color: AppColors.borderGray),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide:
                              const BorderSide(color: AppColors.borderGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderGray),
                ),
              ),
              child: CustomButton(
                label: 'Submit Review',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitReview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderHeader extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;

  const _ProviderHeader({
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.lightBlue,
            child: ClipOval(
              child: cleanUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryBlue,
                      size: 38,
                    )
                  : Image.network(
                      cleanUrl,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryBlue,
                        size: 38,
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
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
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

class _StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _StarRating({
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1.0;
        final selected = rating >= value;

        return GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: selected ? 1.12 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                selected ? Icons.star_rounded : Icons.star_border_rounded,
                color: selected ? Colors.amber : AppColors.borderGray,
                size: 42,
              ),
            ),
          ),
        );
      }),
    );
  }
}