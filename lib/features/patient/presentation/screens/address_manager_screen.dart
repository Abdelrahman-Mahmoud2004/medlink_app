import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/address_model.dart';

class AddressManagerScreen extends StatefulWidget {
  const AddressManagerScreen({super.key});

  @override
  State<AddressManagerScreen> createState() => _AddressManagerScreenState();
}

class _AddressManagerScreenState extends State<AddressManagerScreen> {
  late List<AddressModel> _addresses;

  @override
  void initState() {
    super.initState();

    _addresses = const [
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
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientProfile);
  }

  Future<void> _addAddress() async {
    final result = await context.push<AddressModel>(
      AppRoutes.addEditAddress,
    );

    if (result == null || !mounted) return;

    setState(() {
      if (result.isDefault) {
        _addresses = _addresses
            .map((address) => address.copyWith(isDefault: false))
            .toList();
      }

      _addresses.add(result);
    });
  }

  Future<void> _editAddress(AddressModel address) async {
    final result = await context.push<AddressModel>(
      AppRoutes.addEditAddress,
      extra: address,
    );

    if (result == null || !mounted) return;

    setState(() {
      if (result.isDefault) {
        _addresses = _addresses
            .map((item) => item.copyWith(isDefault: false))
            .toList();
      }

      final index = _addresses.indexWhere((item) => item.id == result.id);

      if (index != -1) {
        _addresses[index] = result;
      }
    });
  }

  void _setDefault(AddressModel selectedAddress) {
    setState(() {
      _addresses = _addresses.map((address) {
        return address.copyWith(
          isDefault: address.id == selectedAddress.id,
        );
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default address updated'),
      ),
    );
  }

  Future<void> _deleteAddress(AddressModel address) async {
    if (address.isDefault && _addresses.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set another default address first'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Address?'),
          content: Text(
            'Are you sure you want to delete "${address.displayTitle}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              onPressed: () => dialogContext.pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _addresses.removeWhere((item) => item.id == address.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Address Manager'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _addresses.isEmpty
                  ? const _EmptyAddressState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final address = _addresses[index];

                        return _AddressCard(
                          address: address,
                          onEdit: () => _editAddress(address),
                          onDelete: () => _deleteAddress(address),
                          onSetDefault: () => _setDefault(address),
                        );
                      },
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
                label: 'Add New Address',
                onPressed: _addAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  IconData get _icon {
    if (address.isHome) return Icons.home_rounded;
    if (address.isWork) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: address.isDefault ? AppColors.primaryBlue : AppColors.borderGray,
          width: address.isDefault ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: address.isDefault
                ? AppColors.primaryBlue.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              'Default',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.successGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      address.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
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
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (!address.isDefault)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSetDefault,
                    child: const Text('Set Default'),
                  ),
                ),
              if (!address.isDefault) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: AppColors.primaryBlue,
                size: 46,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No addresses yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your home or work address to make booking faster.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}