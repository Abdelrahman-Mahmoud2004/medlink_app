import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final TextEditingController _notesController = TextEditingController();

  final ValueNotifier<String> _reasonNotifier =
      ValueNotifier<String>('Schedule changed');
  final ValueNotifier<bool> _isCancellingNotifier = ValueNotifier<bool>(false);

  static const reasons = [
    'Schedule changed',
    'Found another provider',
    'Service no longer needed',
    'Payment issue',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _reasonNotifier.dispose();
    _isCancellingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isCancellingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientBookings);
  }

  Future<void> _cancelBooking() async {
    if (_isCancellingNotifier.value) return;

    _isCancellingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    _isCancellingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking cancelled successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.go(AppRoutes.patientBookings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Cancel Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    const _CancelWarningCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _ReasonSelector(
                      reasonNotifier: _reasonNotifier,
                      reasons: reasons,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _NotesCard(controller: _notesController),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isCancellingNotifier,
                      builder: (context, isCancelling, _) {
                        return FilledButton(
                          onPressed:
                              isCancelling ? null : _cancelBooking,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: isCancelling
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text('Confirm Cancellation'),
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

class _CancelWarningCard extends StatelessWidget {
  const _CancelWarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel_outlined,
            color: AppColors.errorRed,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Please tell us why you want to cancel this booking.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonSelector extends StatelessWidget {
  final ValueNotifier<String> reasonNotifier;
  final List<String> reasons;

  const _ReasonSelector({
    required this.reasonNotifier,
    required this.reasons,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: reasonNotifier,
      builder: (context, selected, _) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: _Decorations.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancellation Reason',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...reasons.map(
                (reason) {
                  final isSelected = selected == reason;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () => reasonNotifier.value = reason,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.lightBlue
                              : AppColors.bgGray,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.borderGray,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                reason,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryBlue,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotesCard extends StatelessWidget {
  final TextEditingController controller;

  const _NotesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _Decorations.card(),
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 7,
        decoration: InputDecoration(
          hintText: 'Additional notes...',
          filled: true,
          fillColor: AppColors.bgGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
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
    );
  }
}