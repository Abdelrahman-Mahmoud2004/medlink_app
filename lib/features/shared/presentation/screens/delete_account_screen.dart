import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final ValueNotifier<bool> _confirmedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isDeletingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _reasonController.dispose();
    _confirmedNotifier.dispose();
    _isDeletingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isDeletingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.welcome);
  }

  Future<void> _deleteAccount() async {
    if (!_confirmedNotifier.value || _isDeletingNotifier.value) return;

    _isDeletingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    _isDeletingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deletion request submitted'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Delete Account'),
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
                    const _WarningCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _ReasonCard(controller: _reasonController),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _confirmedNotifier,
                      builder: (context, confirmed, _) {
                        return CheckboxListTile(
                          value: confirmed,
                          activeColor: AppColors.errorRed,
                          onChanged: (value) {
                            _confirmedNotifier.value = value ?? false;
                          },
                          title: Text(
                            'I understand this action cannot be undone.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _confirmedNotifier,
                      builder: (context, confirmed, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isDeletingNotifier,
                          builder: (context, isDeleting, __) {
                            return FilledButton(
                              onPressed: confirmed && !isDeleting
                                  ? _deleteAccount
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                                minimumSize: const Size(double.infinity, 52),
                              ),
                              child: isDeleting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text('Delete Account'),
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

class _WarningCard extends StatelessWidget {
  const _WarningCard();

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
            Icons.warning_amber_rounded,
            color: AppColors.errorRed,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Deleting your account will remove access to your bookings, visits, wallet data and account history.',
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

class _ReasonCard extends StatelessWidget {
  final TextEditingController controller;

  const _ReasonCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: TextField(
        controller: controller,
        minLines: 5,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: 'Tell us why you want to delete your account...',
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