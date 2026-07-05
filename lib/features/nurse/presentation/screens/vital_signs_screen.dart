import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../patient/data/models/vital_signs_model.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key}); // IMPROVED: super.key

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  // FIX: this whole form had zero validation before — a nurse could tap
  // Save on completely empty fields and it would "succeed". It's a
  // medical form, so a Form + real validators is not optional.
  final _formKey = GlobalKey<FormState>();

  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _respiratoryController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _respiratoryController.dispose();
    _oxygenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _requiredInRange(String? value, {required num min, required num max, String unit = ''}) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final parsed = num.tryParse(value);
    if (parsed == null) return 'Enter a number';
    if (parsed < min || parsed > max) return 'Expected $min–$max$unit';
    return null;
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    // FIX: the old version threw all this input away and just showed a
    // snackbar. It now actually builds the model that gets handed back
    // to whichever screen opened this one.
    final vitals = VitalSignsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bloodPressureSystolic: int.parse(_systolicController.text),
      bloodPressureDiastolic: int.parse(_diastolicController.text),
      heartRate: int.parse(_heartRateController.text),
      temperature: double.parse(_temperatureController.text),
      respiratoryRate: int.parse(_respiratoryController.text),
      oxygenSaturation: double.parse(_oxygenController.text),
      recordedAt: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // FIX: guard before touching context post-await
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vital signs recorded successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      // FIX: returns the recorded vitals to the caller (ActiveVisitScreen
      // awaits this and displays it) instead of just popping with nothing.
      context.pop(vitals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Record Vital Signs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBloodPressureInput(context),
                const SizedBox(height: AppSpacing.xl),
                _VitalInput(
                  title: 'Heart Rate (bpm)',
                  icon: Icons.favorite_outlined,
                  controller: _heartRateController,
                  validator: (v) => _requiredInRange(v, min: 30, max: 220, unit: ' bpm'),
                ),
                const SizedBox(height: AppSpacing.xl),
                _VitalInput(
                  title: 'Temperature (°C)',
                  icon: Icons.thermostat_outlined,
                  controller: _temperatureController,
                  isDecimal: true, // FIX: explicit flag instead of parsing the title string
                  validator: (v) => _requiredInRange(v, min: 30, max: 43, unit: '°C'),
                ),
                const SizedBox(height: AppSpacing.xl),
                _VitalInput(
                  title: 'Respiratory Rate (breaths/min)',
                  icon: Icons.air_outlined,
                  controller: _respiratoryController,
                  validator: (v) => _requiredInRange(v, min: 5, max: 60, unit: '/min'),
                ),
                const SizedBox(height: AppSpacing.xl),
                _VitalInput(
                  title: 'Oxygen Saturation (%)',
                  icon: Icons.opacity_outlined,
                  controller: _oxygenController,
                  isDecimal: true,
                  validator: (v) => _requiredInRange(v, min: 50, max: 100, unit: '%'),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add any additional notes...',
                    filled: true,
                    fillColor: AppColors.bgGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.borderGray),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.lg),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomButton(
                  label: 'Save Vital Signs',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBloodPressureInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Pressure (mmHg)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            const Icon(Icons.favorite_outlined, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _systolicController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // FIX: was unrestricted
                validator: (v) => _requiredInRange(v, min: 60, max: 250),
                decoration: _fieldDecoration('Systolic'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _diastolicController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => _requiredInRange(v, min: 30, max: 150),
                decoration: _fieldDecoration('Diastolic'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Reference: below 120/80 mmHg is typically normal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder( // IMPROVED: was missing — errors had no visual border cue
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
    );
  }
}

class _VitalInput extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool isDecimal;

  const _VitalInput({
    required this.title,
    required this.icon,
    required this.controller,
    required this.validator,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
                inputFormatters: [
                  // FIX: input is now actually restricted — before, a
                  // nurse could type letters into "Heart Rate".
                  if (isDecimal)
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                  else
                    FilteringTextInputFormatter.digitsOnly,
                ],
                validator: validator,
                decoration: InputDecoration(
                  hintText: 'Enter value',
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
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.errorRed),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
