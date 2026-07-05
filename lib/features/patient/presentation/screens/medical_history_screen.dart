import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/medical_record_model.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  MedicalRecordType? _selectedType;

  late final List<MedicalRecordModel> _records;

  @override
  void initState() {
    super.initState();

    _records = [
      MedicalRecordModel(
        id: '1',
        title: 'General Health Checkup',
        providerName: 'Cairo Medical Center',
        type: MedicalRecordType.general,
        recordDate: DateTime.now().subtract(const Duration(days: 14)),
        summary: 'Routine checkup with stable overall health indicators.',
        notes: 'Blood pressure and heart rate were within normal limits.',
        attachments: const ['checkup_report.pdf'],
      ),
      MedicalRecordModel(
        id: '2',
        title: 'Blood Test Results',
        providerName: 'Alfa Labs',
        type: MedicalRecordType.labResult,
        recordDate: DateTime.now().subtract(const Duration(days: 30)),
        summary: 'Complete blood count and basic chemistry panel.',
        notes: 'Follow up with provider if symptoms change.',
        attachments: const ['blood_test.pdf'],
      ),
      MedicalRecordModel(
        id: '3',
        title: 'Post-Surgery Care Notes',
        providerName: 'MedLink Nurse Visit',
        type: MedicalRecordType.surgery,
        recordDate: DateTime.now().subtract(const Duration(days: 60)),
        summary: 'Post-surgery wound care and recovery tracking.',
        notes: 'Wound healing progress documented during home visit.',
      ),
      MedicalRecordModel(
        id: '4',
        title: 'Medication Prescription',
        providerName: 'Home Healthcare Provider',
        type: MedicalRecordType.prescription,
        recordDate: DateTime.now().subtract(const Duration(days: 75)),
        summary: 'Medication plan for short-term recovery.',
        notes: 'Medication schedule should be followed as prescribed.',
        attachments: const ['prescription.png'],
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MedicalRecordModel> get _filteredRecords {
    final cleanQuery = _query.trim().toLowerCase();

    return _records.where((record) {
      final matchesSearch = cleanQuery.isEmpty ||
          record.title.toLowerCase().contains(cleanQuery) ||
          record.providerName.toLowerCase().contains(cleanQuery) ||
          record.summary.toLowerCase().contains(cleanQuery);

      final matchesType = _selectedType == null || record.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientProfile);
  }

  void _openDetails(MedicalRecordModel record) {
    context.push(
      AppRoutes.medicalRecordDetails,
      extra: record,
    );
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _query = '';
      _selectedType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Medical History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: records.isEmpty
                  ? _EmptyMedicalRecordsState(onClear: _clearFilters)
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: records.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final record = records[index];

                        return _MedicalRecordCard(
                          record: record,
                          onTap: () => _openDetails(record),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.bgGray,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _query = value);
            },
            decoration: InputDecoration(
              hintText: 'Search medical records',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textLight,
              ),
              suffixIcon: _query.trim().isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textLight,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MedicalRecordType.values.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final type = isAll ? null : MedicalRecordType.values[index - 1];
                final isSelected = _selectedType == type;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = type);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primaryBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.borderGray,
                      ),
                    ),
                    child: Text(
                      isAll ? 'All' : type!.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textDark,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecordModel record;
  final VoidCallback onTap;

  const _MedicalRecordCard({
    required this.record,
    required this.onTap,
  });

  IconData get _icon {
    switch (record.type) {
      case MedicalRecordType.general:
        return Icons.health_and_safety_rounded;
      case MedicalRecordType.diagnosis:
        return Icons.medical_information_rounded;
      case MedicalRecordType.labResult:
        return Icons.science_rounded;
      case MedicalRecordType.prescription:
        return Icons.receipt_long_rounded;
      case MedicalRecordType.surgery:
        return Icons.healing_rounded;
      case MedicalRecordType.allergy:
        return Icons.warning_amber_rounded;
      case MedicalRecordType.vaccine:
        return Icons.vaccines_rounded;
      case MedicalRecordType.imaging:
        return Icons.image_search_rounded;
    }
  }

  Color get _color {
    switch (record.type) {
      case MedicalRecordType.labResult:
        return const Color(0xFF8B5CF6);
      case MedicalRecordType.prescription:
        return AppColors.primaryBlue;
      case MedicalRecordType.allergy:
        return AppColors.errorRed;
      case MedicalRecordType.surgery:
        return AppColors.warningOrange;
      default:
        return AppColors.successGreen;
    }
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  _icon,
                  color: _color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      record.displayProvider,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      record.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          record.type.label,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: _color,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          _formatDate(record.recordDate),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.textLight,
                                    fontSize: 10.5,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMedicalRecordsState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyMedicalRecordsState({
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_off_rounded,
              color: AppColors.textLight,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No records found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try changing your search or filter.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}