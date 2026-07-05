import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/address_model.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  late final List<AddressModel> _addresses;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();

    _addresses = _buildDummyAddresses();

    final defaultAddresses = _addresses.where((address) => address.isDefault);

    _selectedAddressId = defaultAddresses.isNotEmpty
        ? defaultAddresses.first.id
        : _addresses.isNotEmpty
            ? _addresses.first.id
            : null;
  }

  List<AddressModel> _buildDummyAddresses() => const [
        AddressModel(
          id: '1',
          title: 'Home',
          address: 'Giza, Al Haram, Building 42',
          city: 'Giza',
          postalCode: '12211',
          latitude: 30.0131,
          longitude: 31.2089,
          isDefault: true,
        ),
        AddressModel(
          id: '2',
          title: 'Work',
          address: 'Cairo, Downtown, Street 10',
          city: 'Cairo',
          postalCode: '11511',
          latitude: 30.0444,
          longitude: 31.2357,
          isDefault: false,
        ),
      ];

  Map<String, dynamic> _getIncomingBookingData() {
    final extra = GoRouterState.of(context).extra;

    if (extra is Map<String, dynamic>) {
      return Map<String, dynamic>.from(extra);
    }

    if (extra is Map) {
      return Map<String, dynamic>.from(extra);
    }

    return <String, dynamic>{};
  }

  void _handleAddAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add address feature coming soon'),
      ),
    );
  }

  void _handleContinue() {
    final selectedAddressId = _selectedAddressId;

    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an address'),
        ),
      );
      return;
    }

    final selectedAddress = _addresses.firstWhere(
      (address) => address.id == selectedAddressId,
    );

    final bookingData = _getIncomingBookingData();

    bookingData['selectedAddress'] = selectedAddress;

    context.push(
      AppRoutes.bookingSummary,
      extra: bookingData,
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.selectDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.selectAddress),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.addressQuestion,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Choose the address where the healthcare provider should arrive.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (_, index) {
                        final address = _addresses[index];

                        return _AddressTile(
                          address: address,
                          isSelected: _selectedAddressId == address.id,
                          onTap: () {
                            setState(() => _selectedAddressId = address.id);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _AddAddressButton(onTap: _handleAddAddress),
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
                label: AppStrings.continueText,
                onPressed: _handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    final title = address.title.toLowerCase();

    if (title == 'home') {
      return Icons.home_rounded;
    }

    if (title == 'work') {
      return Icons.work_rounded;
    }

    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 24 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(
                  alpha: isSelected ? 0.16 : 0.10,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                _icon,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    address.address,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${address.city}, ${address.postalCode}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.borderGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              AppStrings.addNewAddress,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}