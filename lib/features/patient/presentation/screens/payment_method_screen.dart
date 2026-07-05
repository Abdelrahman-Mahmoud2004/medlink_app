import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> bookingData;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    this.bookingData = const {},
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _mobileWalletController = TextEditingController();

  PaymentMethodType _selectedType = PaymentMethodType.card;

  int? _selectedCardIndex = 0;
  bool _showAddCardForm = false;
  bool _isLoading = false;

  static const double _walletBalance = 150.0;

  final List<SavedCard> _savedCards = const [
    SavedCard(
      id: '1',
      brand: 'VISA',
      last4: '4242',
      expiry: '12/28',
      isDefault: true,
    ),
    SavedCard(
      id: '2',
      brand: 'MC',
      last4: '5588',
      expiry: '09/27',
    ),
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _mobileWalletController.dispose();
    super.dispose();
  }

  bool get _canPay {
    switch (_selectedType) {
      case PaymentMethodType.card:
        if (_showAddCardForm) return true;
        return _selectedCardIndex != null;

      case PaymentMethodType.mobileWallet:
        return _mobileWalletController.text.trim().length == 11;

      case PaymentMethodType.wallet:
        return _walletBalance >= widget.amount;

      case PaymentMethodType.cash:
        return true;
    }
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
  }

  Future<void> _handlePay() async {
    if (_isLoading) return;

    if (_selectedType == PaymentMethodType.card && _showAddCardForm) {
      final isValid = _formKey.currentState?.validate() ?? false;

      if (!isValid) {
        return;
      }
    }

    if (!_canPay) {
      final message = _selectedType == PaymentMethodType.wallet
          ? 'Insufficient wallet balance'
          : 'Please complete the payment details';

      _showSnackBar(message, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isLoading = false);

      context.go(
        AppRoutes.paymentSuccess,
        extra: {
          ...widget.bookingData,
          'total': widget.amount,
          'paymentMethod': _selectedType.name,
          'paidAt': DateTime.now(),
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showSnackBar(
        error.toString(),
        isError: true,
      );
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.errorRed
            : isSuccess
                ? AppColors.successGreen
                : null,
      ),
    );
  }

  void _goBack() {
    if (_isLoading) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.bookingSummary);
  }

  Color _paymentMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return AppColors.primaryBlue;
      case PaymentMethodType.wallet:
        return AppColors.successGreen;
      case PaymentMethodType.mobileWallet:
        return const Color(0xFF8B5CF6);
      case PaymentMethodType.cash:
        return AppColors.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payLabel = _selectedType == PaymentMethodType.cash
        ? 'Confirm Cash Payment'
        : 'Pay ${_money(widget.amount)}';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Payment Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isLoading ? null : _goBack,
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
                    _AmountSummary(amount: widget.amount),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Select Payment Method',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    ...PaymentMethodType.values.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _MethodTile(
                          type: type,
                          isSelected: _selectedType == type,
                          color: _paymentMethodColor(type),
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _selectedType = type;
                                  });
                                },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _buildMethodDetails(),

                    const SizedBox(height: AppSpacing.xl),

                    const _SecurityNotice(),
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
                label: payLabel,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handlePay,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDetails() {
    switch (_selectedType) {
      case PaymentMethodType.card:
        return _buildCardSection();

      case PaymentMethodType.mobileWallet:
        return _buildMobileWalletSection();

      case PaymentMethodType.wallet:
        return _buildWalletSection();

      case PaymentMethodType.cash:
        return _buildCashSection();
    }
  }

  Widget _buildCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._savedCards.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SavedCardTile(
                  card: entry.value,
                  isSelected:
                      _selectedCardIndex == entry.key && !_showAddCardForm,
                  onTap: () {
                    setState(() {
                      _selectedCardIndex = entry.key;
                      _showAddCardForm = false;
                    });
                  },
                ),
              ),
            ),
        TextButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _showAddCardForm = !_showAddCardForm;

                    if (_showAddCardForm) {
                      _selectedCardIndex = null;
                    } else if (_savedCards.isNotEmpty) {
                      _selectedCardIndex = 0;
                    }
                  });
                },
          icon: Icon(
            _showAddCardForm
                ? Icons.close_rounded
                : Icons.add_circle_outline_rounded,
          ),
          label: Text(_showAddCardForm ? 'Cancel' : 'Add New Card'),
        ),
        if (_showAddCardForm) ...[
          const SizedBox(height: AppSpacing.md),
          _NewCardForm(
            formKey: _formKey,
            numberController: _cardNumberController,
            nameController: _cardNameController,
            expiryController: _expiryController,
            cvvController: _cvvController,
          ),
        ],
      ],
    );
  }

  Widget _buildMobileWalletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet Phone Number',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _mobileWalletController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '01xxxxxxxxx',
            prefixIcon: const Icon(Icons.phone_android_outlined),
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
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'You will receive a payment request notification on this number.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  Widget _buildWalletSection() {
    final sufficient = _walletBalance >= widget.amount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _money(_walletBalance),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
              ],
            ),
          ),
          if (!sufficient)
            Text(
              'Insufficient',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w800,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildCashSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.textLight,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Pay the nurse directly in cash when the visit is complete.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _AmountSummary extends StatelessWidget {
  final double amount;

  const _AmountSummary({
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'EGP ${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primaryBlue,
            size: 40,
          ),
        ],
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

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
            Icons.lock_outlined,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Your payment information is encrypted and secure.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethodType type;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _MethodTile({
    required this.type,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) :  AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? color : AppColors.borderGray,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  type.icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? color : AppColors.borderGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  final SavedCard card;
  final bool isSelected;
  final VoidCallback onTap;

  const _SavedCardTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = card.brand.trim().isEmpty ? 'CARD' : card.brand;
    final last4 = card.last4.trim().isEmpty ? '0000' : card.last4;
    final expiry = card.expiry.trim().isEmpty ? '--/--' : card.expiry;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue : AppColors.bgGray,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                brand.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•••• •••• •••• $last4',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Expires $expiry',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ],
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
    );
  }
}

class _NewCardForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController numberController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  const _NewCardForm({
    required this.formKey,
    required this.numberController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: numberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
              LengthLimitingTextInputFormatter(19),
            ],
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(Icons.credit_card_rounded),
            ),
            validator: (value) {
              final digits = (value ?? '').replaceAll(' ', '');

              if (digits.length != 16) {
                return 'Enter a valid 16-digit card number';
              }

              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Card Holder Name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }

              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryFormatter(),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Expiry',
                    hintText: 'MM/YY',
                  ),
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return 'Invalid';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: TextFormField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                  ),
                  validator: (value) {
                    if (value == null || value.length < 3) {
                      return 'Invalid';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Formatters
// -----------------------------------------------------------------------------

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');

    if (digits.length > 16) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      if (index > 0 && index % 4 == 0) {
        buffer.write(' ');
      }

      buffer.write(digits[index]);
    }

    final formatted = buffer.toString();

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');

    if (digits.length > 4) {
      return oldValue;
    }

    String formatted = digits;

    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}