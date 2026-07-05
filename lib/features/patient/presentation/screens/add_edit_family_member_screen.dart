import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/family_member_model.dart';

class AddEditFamilyMemberScreen extends StatefulWidget {
  final FamilyMemberModel? member;

  const AddEditFamilyMemberScreen({
    super.key,
    this.member,
  });

  @override
  State<AddEditFamilyMemberScreen> createState() =>
      _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends State<AddEditFamilyMemberScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;

  String _relationship = 'Self';
  String _bloodType = 'O+';
  bool _isPrimary = false;

  bool get _isEditing => widget.member != null;

  static const List<String> _relationships = [
    'Self',
    'Father',
    'Mother',
    'Sibling',
    'Spouse',
    'Child',
    'Other',
  ];

  static const List<String> _bloodTypes = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();

    final member = widget.member;

    _nameController = TextEditingController(text: member?.fullName ?? '');
    _phoneController = TextEditingController(text: member?.phone ?? '');
    _allergiesController = TextEditingController(text: member?.allergies ?? '');
    _conditionsController =
        TextEditingController(text: member?.chronicConditions ?? '');

    _relationship = member?.relationship.trim().isNotEmpty == true
        ? member!.relationship
        : 'Self';

    _bloodType =
        member?.bloodType.trim().isNotEmpty == true ? member!.bloodType : 'O+';

    _isPrimary = member?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _saveMember() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final existing = widget.member;

    final member = FamilyMemberModel(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _nameController.text.trim(),
      relationship: _relationship,
      phone: _phoneController.text.trim(),
      bloodType: _bloodType,
      allergies: _allergiesController.text.trim(),
      chronicConditions: _conditionsController.text.trim(),
      isPrimary: _isPrimary,
    );

    context.pop(member);
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

  String? _phoneValidator(String? value) {
    final clean = value?.trim() ?? '';

    if (clean.isEmpty) {
      return null;
    }

    if (clean.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Family Member' : 'Add Family Member'),
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
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter full name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      DropdownButtonFormField<String>(
                        initialValue: _relationships.contains(_relationship)
                            ? _relationship
                            : 'Other',
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          prefixIcon: Icon(Icons.family_restroom_rounded),
                        ),
                        items: _relationships.map((relationship) {
                          return DropdownMenuItem<String>(
                            value: relationship,
                            child: Text(relationship),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _relationship = value);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Optional',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: _phoneValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      DropdownButtonFormField<String>(
                        initialValue:
                            _bloodTypes.contains(_bloodType) ? _bloodType : 'Unknown',
                        decoration: const InputDecoration(
                          labelText: 'Blood Type',
                          prefixIcon: Icon(Icons.bloodtype_rounded),
                        ),
                        items: _bloodTypes.map((bloodType) {
                          return DropdownMenuItem<String>(
                            value: bloodType,
                            child: Text(bloodType),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _bloodType = value);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _allergiesController,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Allergies',
                          hintText: 'Write allergies or None',
                          prefixIcon: Icon(Icons.warning_amber_rounded),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _conditionsController,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Chronic Conditions',
                          hintText: 'Diabetes, hypertension, asthma...',
                          prefixIcon: Icon(Icons.medical_information_outlined),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      _PrimarySwitchTile(
                        value: _isPrimary,
                        onChanged: (value) {
                          setState(() => _isPrimary = value);
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
                label: _isEditing ? 'Save Changes' : 'Add Member',
                onPressed: _saveMember,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimarySwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrimarySwitchTile({
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
              'Set as primary patient',
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