import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/address_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;

  bool _isDefault = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _titleController = TextEditingController(text: address?.title ?? '');
    _addressController = TextEditingController(text: address?.address ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final existing = widget.address;

    final address = AddressModel(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      latitude: existing?.latitude ?? 0.0,
      longitude: existing?.longitude ?? 0.0,
      isDefault: _isDefault,
    );

    context.pop(address);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Address' : 'Add Address'),
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _AddressTypePresets(
                        onSelected: (title) {
                          _titleController.text = title;
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Address Title',
                          hintText: 'Home, Work, Clinic...',
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _addressController,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full Address',
                          hintText: 'Street, building, apartment...',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _cityController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          hintText: 'Cairo, Giza...',
                          prefixIcon: Icon(Icons.location_city_rounded),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _postalCodeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Postal Code',
                          hintText: 'Optional',
                          prefixIcon: Icon(Icons.local_post_office_outlined),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      _DefaultSwitchTile(
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() => _isDefault = value);
                        },
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
                label: _isEditing ? 'Save Changes' : 'Add Address',
                onPressed: _saveAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTypePresets extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _AddressTypePresets({
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const presets = [
      _AddressPreset(label: 'Home', icon: Icons.home_rounded),
      _AddressPreset(label: 'Work', icon: Icons.work_rounded),
      _AddressPreset(label: 'Other', icon: Icons.location_on_rounded),
    ];

    return Row(
      children: presets.map((preset) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelected(preset.label),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Column(
                  children: [
                    Icon(
                      preset.icon,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      preset.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AddressPreset {
  final String label;
  final IconData icon;

  const _AddressPreset({
    required this.label,
    required this.icon,
  });
}

class _DefaultSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DefaultSwitchTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryBlue.withValues(alpha: 0.08)
            : AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: value ? AppColors.primaryBlue : AppColors.borderGray,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Set as default address',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}