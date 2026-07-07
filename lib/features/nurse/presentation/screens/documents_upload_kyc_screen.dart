import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class DocumentsUploadKycScreen extends StatefulWidget {
  const DocumentsUploadKycScreen({super.key});

  @override
  State<DocumentsUploadKycScreen> createState() =>
      _DocumentsUploadKycScreenState();
}

class _DocumentsUploadKycScreenState extends State<DocumentsUploadKycScreen> {
  final ValueNotifier<List<_KycDocument>> _documentsNotifier =
      ValueNotifier<List<_KycDocument>>(
    const [
      _KycDocument(
        title: 'National ID / Passport',
        subtitle: 'Upload a clear image of your identity document',
        icon: Icons.badge_outlined,
        isRequired: true,
      ),
      _KycDocument(
        title: 'Nursing License',
        subtitle: 'Professional nursing license or syndicate card',
        icon: Icons.verified_user_outlined,
        isRequired: true,
      ),
      _KycDocument(
        title: 'Experience Certificate',
        subtitle: 'Hospital, clinic, or training certificate',
        icon: Icons.workspace_premium_outlined,
        isRequired: true,
      ),
      _KycDocument(
        title: 'Profile Photo',
        subtitle: 'Clear professional photo for your provider profile',
        icon: Icons.person_outline_rounded,
        isRequired: false,
      ),
    ],
  );

  final ValueNotifier<bool> _isSubmittingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _documentsNotifier.dispose();
    _isSubmittingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSubmittingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseProfileSettings);
  }

  void _mockUpload(int index) {
    final docs = List<_KycDocument>.of(_documentsNotifier.value);
    final current = docs[index];

    docs[index] = current.copyWith(
      uploaded: true,
      fileName: '${current.title.toLowerCase().replaceAll(' ', '_')}.pdf',
    );

    _documentsNotifier.value = docs;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${current.title} uploaded'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _removeDocument(int index) {
    final docs = List<_KycDocument>.of(_documentsNotifier.value);
    final current = docs[index];

    docs[index] = current.copyWith(
      uploaded: false,
      fileName: '',
    );

    _documentsNotifier.value = docs;
  }

  Future<void> _submitForReview() async {
    if (_isSubmittingNotifier.value) return;

    final docs = _documentsNotifier.value;
    final missingRequired = docs.any(
      (document) => document.isRequired && !document.uploaded,
    );

    if (missingRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    _isSubmittingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    _isSubmittingNotifier.value = false;

    context.go(AppRoutes.nurseUnderReview);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Documents Upload / KYC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<_KycDocument>>(
          valueListenable: _documentsNotifier,
          builder: (context, documents, _) {
            final uploadedCount =
                documents.where((document) => document.uploaded).length;
            final totalCount = documents.length;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(
                      [
                        _KycHeaderCard(
                          uploadedCount: uploadedCount,
                          totalCount: totalCount,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: documents.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final document = documents[index];

                            return _DocumentTile(
                              document: document,
                              onUpload: () => _mockUpload(index),
                              onRemove: () => _removeDocument(index),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const _KycNoteCard(),
                        const SizedBox(height: AppSpacing.xl),
                        ValueListenableBuilder<bool>(
                          valueListenable: _isSubmittingNotifier,
                          builder: (context, isSubmitting, _) {
                            return FilledButton(
                              onPressed:
                                  isSubmitting ? null : _submitForReview,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                minimumSize: const Size(double.infinity, 52),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text('Submit for Review'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KycDocument {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;
  final bool uploaded;
  final String fileName;

  const _KycDocument({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isRequired,
    this.uploaded = false,
    this.fileName = '',
  });

  _KycDocument copyWith({
    String? title,
    String? subtitle,
    IconData? icon,
    bool? isRequired,
    bool? uploaded,
    String? fileName,
  }) {
    return _KycDocument(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      isRequired: isRequired ?? this.isRequired,
      uploaded: uploaded ?? this.uploaded,
      fileName: fileName ?? this.fileName,
    );
  }
}

class _KycHeaderCard extends StatelessWidget {
  final int uploadedCount;
  final int totalCount;

  const _KycHeaderCard({
    required this.uploadedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : uploadedCount / totalCount;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: AppColors.white,
              size: 42,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Provider Verification',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$uploadedCount of $totalCount documents uploaded',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final _KycDocument document;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _DocumentTile({
    required this.document,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        document.uploaded ? AppColors.successGreen : AppColors.warningOrange;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(document.icon, color: statusColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      if (document.isRequired)
                        Text(
                          'Required',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.errorRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    document.uploaded ? document.fileName : document.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            document.uploaded
                ? IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.errorRed,
                    ),
                  )
                : IconButton(
                    onPressed: onUpload,
                    icon: const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _KycNoteCard extends StatelessWidget {
  const _KycNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'After submission, MedLink reviews your documents. Your dashboard may be limited until approval.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
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