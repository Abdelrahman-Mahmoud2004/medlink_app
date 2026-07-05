import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/medication_model.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final MedicationModel? medication;

  const AddEditMedicationScreen({
    super.key,
    this.medication,
  });

  @override
  State<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;

  String _frequency = 'Once daily';
  List<String> _times = ['09:00 AM'];
  DateTime _startDate = DateTime.now();
  bool _isActive = true;

  bool get _isEditing => widget.medication != null;

  static const List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
  ];

  @override
  void initState() {
    super.initState();

    final medication = widget.medication;

    _nameController = TextEditingController(text: medication?.name ?? '');
    _dosageController = TextEditingController(text: medication?.dosage ?? '');
    _notesController = TextEditingController(text: medication?.notes ?? '');

    _frequency = medication?.frequency.trim().isNotEmpty == true
        ? medication!.frequency
        : 'Once daily';

    _times = medication?.times.isNotEmpty == true
        ? List<String>.from(medication!.times)
        : ['09:00 AM'];

    _startDate = medication?.startDate ?? DateTime.now();
    _isActive = medication?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  void _saveMedication() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final existing = widget.medication;

    final medication = MedicationModel(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequency,
      times: List.unmodifiable(_times),
      startDate: _startDate,
      notes: _notesController.text.trim(),
      isActive: _isActive,
    );

    context.pop(medication);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    }
  }

  Future<void> _pickStartDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: _startDate,
    );

    if (result == null || !mounted) return;

    setState(() => _startDate = result);
  }

  Future<void> _addTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (result == null || !mounted) return;

    final formatted = _formatTimeOfDay(result);

    if (_times.contains(formatted)) {
      return;
    }

    setState(() {
      _times.add(formatted);
      _times.sort();
    });
  }

  void _removeTime(String time) {
    if (_times.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one time is required'),
        ),
      );
      return;
    }

    setState(() {
      _times.remove(time);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medication' : 'Add Medication'),
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
                          labelText: 'Medication Name',
                          hintText: 'Medication name',
                          prefixIcon: Icon(Icons.medication_rounded),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _dosageController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Dosage',
                          hintText: '500 mg, 1 tablet...',
                          prefixIcon: Icon(Icons.science_outlined),
                        ),
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      DropdownButtonFormField<String>(
                        initialValue: _frequencies.contains(_frequency)
                            ? _frequency
                            : 'Once daily',
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                          prefixIcon: Icon(Icons.repeat_rounded),
                        ),
                        items: _frequencies.map((frequency) {
                          return DropdownMenuItem<String>(
                            value: frequency,
                            child: Text(frequency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _frequency = value);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _StartDateTile(
                        date: _formatDate(_startDate),
                        onTap: _pickStartDate,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _TimesSection(
                        times: _times,
                        onAdd: _addTime,
                        onRemove: _removeTime,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _notesController,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Take after meals, avoid driving...',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      _ActiveSwitchTile(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
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
                label: _isEditing ? 'Save Changes' : 'Add Medication',
                onPressed: _saveMedication,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartDateTile extends StatelessWidget {
  final String date;
  final VoidCallback onTap;

  const _StartDateTile({
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgGray,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Start Date',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _TimesSection extends StatelessWidget {
  final List<String> times;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _TimesSection({
    required this.times,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Dose Times',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: times.map((time) {
              return Chip(
                label: Text(time),
                deleteIcon: const Icon(Icons.close_rounded),
                onDeleted: () => onRemove(time),
                backgroundColor: AppColors.lightBlue,
                side: BorderSide.none,
                labelStyle: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActiveSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActiveSwitchTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: value
            ? AppColors.successGreen.withValues(alpha: 0.08)
            : AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: value ? AppColors.successGreen : AppColors.borderGray,
        ),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
            color: value ? AppColors.successGreen : AppColors.textLight,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value ? 'Medication is active' : 'Medication is paused',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.successGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}