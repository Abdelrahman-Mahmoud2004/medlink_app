import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _accountNameController =
      TextEditingController(text: 'Fatima Al-Sayed');
  final TextEditingController _bankNameController =
      TextEditingController(text: 'National Bank of Egypt');
  final TextEditingController _accountNumberController =
      TextEditingController(text: '12345678901234');
  final TextEditingController _walletNumberController =
      TextEditingController(text: '01012345678');

  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _accountNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _walletNumberController.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSavingNotifier.value) return;

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

  Future<void> _save() async {
    if (_isSavingNotifier.value) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _isSavingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 750));

    if (!mounted) return;

    _isSavingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bank account saved successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Bank Account'),
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
                    Form(
                      key: _formKey,
                      child: _FormCard(
                        accountNameController: _accountNameController,
                        bankNameController: _bankNameController,
                        accountNumberController: _accountNumberController,
                        walletNumberController: _walletNumberController,
                        validator: _required,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSavingNotifier,
                      builder: (context, isSaving, _) {
                        return FilledButton(
                          onPressed: isSaving ? null : _save,
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
                              : const Text('Save Payout Account'),
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
            Icons.account_balance_rounded,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Manage bank and wallet details used for withdrawals.',
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

class _FormCard extends StatelessWidget {
  final TextEditingController accountNameController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController walletNumberController;
  final String? Function(String?) validator;

  const _FormCard({
    required this.accountNameController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.walletNumberController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _Decorations.card(),
      child: Column(
        children: [
          _Field(
            controller: accountNameController,
            label: 'Account Holder Name',
            icon: Icons.person_outline_rounded,
            validator: validator,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            controller: bankNameController,
            label: 'Bank Name',
            icon: Icons.account_balance_outlined,
            validator: validator,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            controller: accountNumberController,
            label: 'Account Number / IBAN',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: validator,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            controller: walletNumberController,
            label: 'Mobile Wallet Number',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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