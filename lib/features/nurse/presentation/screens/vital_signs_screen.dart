import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../patient/data/models/vital_signs_model.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _respiratoryController = TextEditingController();
  final TextEditingController _oxygenController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  static final List<TextInputFormatter> _digitsOnlyFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  static final List<TextInputFormatter> _decimalFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*$')),
  ];

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _respiratoryController.dispose();
    _oxygenController.dispose();
    _notesController.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  String _cleanDecimal(String value) {
    return value.trim().replaceAll(',', '.');
  }

  num? _parseNumber(String? value) {
    final clean = _cleanDecimal(value ?? '');
    return num.tryParse(clean);
  }

  String? _requiredInRange(
    String? value, {
    required num min,
    required num max,
    String unit = '',
  }) {
    final raw = value?.trim() ?? '';

    if (raw.isEmpty) {
      return 'Required';
    }

    final parsed = _parseNumber(raw);

    if (parsed == null) {
      return 'Enter a valid number';
    }

    if (parsed < min || parsed > max) {
      return 'Expected $min–$max$unit';
    }

    return null;
  }

  String? _validateSystolic(String? value) {
    return _requiredInRange(
      value,
      min: 60,
      max: 250,
      unit: ' mmHg',
    );
  }

  String? _validateDiastolic(String? value) {
    final error = _requiredInRange(
      value,
      min: 30,
      max: 150,
      unit: ' mmHg',
    );

    if (error != null) return error;

    final systolic = int.tryParse(_systolicController.text.trim());
    final diastolic = int.tryParse(value?.trim() ?? '');

    if (systolic != null && diastolic != null && diastolic >= systolic) {
      return 'Must be less than systolic';
    }

    return null;
  }

  int _requiredInt(TextEditingController controller) {
    return int.parse(controller.text.trim());
  }

  double _requiredDouble(TextEditingController controller) {
    return double.parse(_cleanDecimal(controller.text));
  }

  Future<void> _handleSave() async {
    if (_isLoadingNotifier.value) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    _isLoadingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final vitals = VitalSignsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bloodPressureSystolic: _requiredInt(_systolicController),
      bloodPressureDiastolic: _requiredInt(_diastolicController),
      heartRate: _requiredInt(_heartRateController),
      temperature: _requiredDouble(_temperatureController),
      respiratoryRate: _requiredInt(_respiratoryController),
      oxygenSaturation: _requiredDouble(_oxygenController),
      recordedAt: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    _isLoadingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vital signs recorded successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.pop(vitals);
  }

  void _goBack() {
    if (_isLoadingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Record Vital Signs'),
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const _HeaderCard(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildBloodPressureInput(),
                          const SizedBox(height: AppSpacing.xl),
                          _VitalInput(
                            title: 'Heart Rate',
                            subtitle: 'Beats per minute',
                            unit: 'bpm',
                            icon: Icons.favorite_outlined,
                            controller: _heartRateController,
                            inputFormatters: _digitsOnlyFormatters,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              return _requiredInRange(
                                value,
                                min: 30,
                                max: 220,
                                unit: ' bpm',
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _VitalInput(
                            title: 'Temperature',
                            subtitle: 'Body temperature in Celsius',
                            unit: '°C',
                            icon: Icons.thermostat_outlined,
                            controller: _temperatureController,
                            inputFormatters: _decimalFormatters,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _requiredInRange(
                                value,
                                min: 30,
                                max: 43,
                                unit: '°C',
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _VitalInput(
                            title: 'Respiratory Rate',
                            subtitle: 'Breaths per minute',
                            unit: '/min',
                            icon: Icons.air_outlined,
                            controller: _respiratoryController,
                            inputFormatters: _digitsOnlyFormatters,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              return _requiredInRange(
                                value,
                                min: 5,
                                max: 60,
                                unit: '/min',
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _VitalInput(
                            title: 'Oxygen Saturation',
                            subtitle: 'SpO₂ percentage',
                            unit: '%',
                            icon: Icons.opacity_outlined,
                            controller: _oxygenController,
                            inputFormatters: _decimalFormatters,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _requiredInRange(
                                value,
                                min: 50,
                                max: 100,
                                unit: '%',
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _NotesInput(controller: _notesController),
                          const SizedBox(height: AppSpacing.xl),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isLoadingNotifier,
                            builder: (context, isLoading, _) {
                              return CustomButton(
                                label: 'Save Vital Signs',
                                isLoading: isLoading,
                                onPressed: _handleSave,
                              );
                            },
                          ),
                        ],
                      ),
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

  Widget _buildBloodPressureInput() {
    return _VitalSectionCard(
      title: 'Blood Pressure',
      subtitle: 'Systolic / Diastolic in mmHg',
      icon: Icons.favorite_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactNumberField(
                  controller: _systolicController,
                  hint: 'Systolic',
                  validator: _validateSystolic,
                  inputFormatters: _digitsOnlyFormatters,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CompactNumberField(
                  controller: _diastolicController,
                  hint: 'Diastolic',
                  validator: _validateDiastolic,
                  inputFormatters: _digitsOnlyFormatters,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _ClinicalHint(
            text: 'Reference: below 120/80 mmHg is typically normal.',
          ),
        ],
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
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
                    'Clinical Reading',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter accurate values. All required vitals are validated before saving.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryBlue,
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

class _VitalSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _VitalSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _CompactNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?) validator;
  final List<TextInputFormatter> inputFormatters;

  const _CompactNumberField({
    required this.controller,
    required this.hint,
    required this.validator,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: _InputDecorations.field(
        hintText: hint,
      ),
    );
  }
}

class _VitalInput extends StatelessWidget {
  final String title;
  final String subtitle;
  final String unit;
  final IconData icon;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const _VitalInput({
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.icon,
    required this.controller,
    required this.inputFormatters,
    required this.keyboardType,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return _VitalSectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        textInputAction: TextInputAction.next,
        decoration: _InputDecorations.field(
          hintText: 'Enter value',
          suffixText: unit,
        ),
      ),
    );
  }
}

class _NotesInput extends StatelessWidget {
  final TextEditingController controller;

  const _NotesInput({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _VitalSectionCard(
      title: 'Additional Notes',
      subtitle: 'Optional clinical notes',
      icon: Icons.notes_outlined,
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        textInputAction: TextInputAction.newline,
        decoration: _InputDecorations.field(
          hintText: 'Add any additional notes...',
        ),
      ),
    );
  }
}

class _ClinicalHint extends StatelessWidget {
  final String text;

  const _ClinicalHint({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
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

final class _InputDecorations {
  const _InputDecorations._();

  static InputDecoration field({
    required String hintText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.errorRed,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
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