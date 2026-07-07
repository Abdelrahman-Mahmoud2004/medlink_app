import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class NurseHelpSupportScreen extends StatefulWidget {
  const NurseHelpSupportScreen({super.key});

  @override
  State<NurseHelpSupportScreen> createState() => _NurseHelpSupportScreenState();
}

class _NurseHelpSupportScreenState extends State<NurseHelpSupportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final ValueNotifier<bool> _isSubmittingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  Future<void> _submitTicket() async {
    if (_isSubmittingNotifier.value) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _isSubmittingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    _isSubmittingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support ticket submitted successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    _subjectController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Help & Support'),
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
                    const _SupportHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    const _FaqSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _TicketForm(
                      formKey: _formKey,
                      subjectController: _subjectController,
                      messageController: _messageController,
                      validator: _required,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSubmittingNotifier,
                      builder: (context, isSubmitting, _) {
                        return FilledButton.icon(
                          onPressed: isSubmitting ? null : _submitTicket,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            isSubmitting ? 'Submitting...' : 'Submit Ticket',
                          ),
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

class _SupportHeader extends StatelessWidget {
  const _SupportHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Need help? Send a support ticket or check quick answers.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
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

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  static const faqs = [
    _FaqItem(
      question: 'When do I receive payouts?',
      answer: 'Completed visit earnings become available after review.',
    ),
    _FaqItem(
      question: 'How do I update my service pricing?',
      answer: 'Go to Expertise & Pricing from Profile & Settings.',
    ),
    _FaqItem(
      question: 'Why is my account under review?',
      answer: 'MedLink reviews KYC documents to keep patients safe.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'FAQs',
      child: Column(
        children: faqs.map((faq) {
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              faq.question,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.4,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TicketForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final String? Function(String?) validator;

  const _TicketForm({
    required this.formKey,
    required this.subjectController,
    required this.messageController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Open Support Ticket',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: subjectController,
              validator: validator,
              decoration: _fieldDecoration('Subject'),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: messageController,
              validator: validator,
              maxLines: 5,
              decoration: _fieldDecoration('Describe your issue'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    return Container(
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
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
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