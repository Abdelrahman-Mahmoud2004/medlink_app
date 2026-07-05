import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _category = 'Booking';
  String _priority = 'Normal';
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'Booking',
    'Payment',
    'Refund',
    'Nurse',
    'Technical Issue',
    'Other',
  ];

  static const List<String> _priorities = [
    'Low',
    'Normal',
    'High',
    'Urgent',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSubmitting) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.helpSupport);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  Future<void> _submitTicket() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final ticketId =
        'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ticket Submitted'),
          content: Text(
            'Your support ticket has been submitted successfully.\n\nTicket ID: $ticketId',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                dialogContext.pop();

                if (!mounted) return;

                context.go(AppRoutes.helpSupport);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.errorRed;
      case 'high':
        return AppColors.warningOrange;
      case 'normal':
        return AppColors.primaryBlue;
      case 'low':
      default:
        return AppColors.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(_priority);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Open Support Ticket'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
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
                                'Describe your issue clearly so the support team can help you faster.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.primaryBlue,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _category = value);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      DropdownButtonFormField<String>(
                        initialValue: _priority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(
                            Icons.flag_outlined,
                            color: priorityColor,
                          ),
                        ),
                        items: _priorities.map((priority) {
                          return DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _priority = value);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _subjectController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          hintText: 'Short summary of your issue',
                          prefixIcon: Icon(Icons.subject_rounded),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _messageController,
                        minLines: 6,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          hintText: 'Write details about your issue...',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.message_outlined),
                        ),
                        validator: _requiredValidator,
                      ),
                    ],
                  ),
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
                label: 'Submit Ticket',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitTicket,
              ),
            ),
          ],
        ),
      ),
    );
  }
}