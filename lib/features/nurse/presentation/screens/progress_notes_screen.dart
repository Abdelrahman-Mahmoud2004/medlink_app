import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class ProgressNotesScreen extends StatefulWidget {
  final String? initialNotes;

  const ProgressNotesScreen({
    super.key,
    this.initialNotes,
  });

  @override
  State<ProgressNotesScreen> createState() => _ProgressNotesScreenState();
}

class _ProgressNotesScreenState extends State<ProgressNotesScreen> {
  late final TextEditingController _notesController;
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  final List<String> _templates = const [
    'Patient is stable and responsive.',
    'Medication administered as prescribed.',
    'Vital signs recorded and within acceptable range.',
    'Patient reported mild discomfort.',
    'Follow-up recommended with attending physician.',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSavingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  void _insertTemplate(String template) {
    final current = _notesController.text.trim();

    if (current.isEmpty) {
      _notesController.text = template;
    } else {
      _notesController.text = '$current\n$template';
    }

    _notesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _notesController.text.length),
    );
  }

  Future<void> _saveNotes() async {
    if (_isSavingNotifier.value) return;

    final notes = _notesController.text.trim();

    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write progress notes before saving'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    _isSavingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    _isSavingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress notes saved'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.pop(notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Progress Notes'),
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
                    const _HeaderCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _TemplatesCard(
                      templates: _templates,
                      onTemplateTap: _insertTemplate,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _NotesEditor(controller: _notesController),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSavingNotifier,
                      builder: (context, isSaving, _) {
                        return FilledButton(
                          onPressed: isSaving ? null : _saveNotes,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text('Save Notes'),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

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
                Icons.edit_note_rounded,
                color: AppColors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical Progress Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Record visit observations and care updates.',
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

class _TemplatesCard extends StatelessWidget {
  final List<String> templates;
  final ValueChanged<String> onTemplateTap;

  const _TemplatesCard({
    required this.templates,
    required this.onTemplateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _Decorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Templates',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: templates.map((template) {
              return ActionChip(
                label: Text(template),
                avatar: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                onPressed: () => onTemplateTap(template),
                backgroundColor: AppColors.lightBlue,
                labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NotesEditor extends StatelessWidget {
  final TextEditingController controller;

  const _NotesEditor({
    required this.controller,
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
              'Notes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              minLines: 8,
              maxLines: 14,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText:
                    'Write patient condition, care provided, response to treatment, and any recommendations...',
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
          ],
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