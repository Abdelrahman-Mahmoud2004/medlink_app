import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/family_member_model.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  late List<FamilyMemberModel> _members;

  @override
  void initState() {
    super.initState();

    _members = const [
      FamilyMemberModel(
        id: '1',
        fullName: 'Fatima Zahra',
        relationship: 'Self',
        phone: '+20 1012345678',
        bloodType: 'O+',
        allergies: 'None',
        chronicConditions: 'None',
        isPrimary: true,
      ),
      FamilyMemberModel(
        id: '2',
        fullName: 'Omar Ali',
        relationship: 'Father',
        phone: '+20 1098765432',
        bloodType: 'A+',
        allergies: 'Penicillin',
        chronicConditions: 'Diabetes',
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

  Future<void> _addMember() async {
    final result = await context.push<FamilyMemberModel>(
      AppRoutes.addEditFamilyMember,
    );

    if (result == null || !mounted) return;

    setState(() {
      if (result.isPrimary) {
        _members =
            _members.map((member) => member.copyWith(isPrimary: false)).toList();
      }

      _members.add(result);
    });
  }

  Future<void> _editMember(FamilyMemberModel member) async {
    final result = await context.push<FamilyMemberModel>(
      AppRoutes.addEditFamilyMember,
      extra: member,
    );

    if (result == null || !mounted) return;

    setState(() {
      if (result.isPrimary) {
        _members =
            _members.map((item) => item.copyWith(isPrimary: false)).toList();
      }

      final index = _members.indexWhere((item) => item.id == result.id);

      if (index != -1) {
        _members[index] = result;
      }
    });
  }

  void _setPrimary(FamilyMemberModel selectedMember) {
    setState(() {
      _members = _members.map((member) {
        return member.copyWith(
          isPrimary: member.id == selectedMember.id,
        );
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Primary member updated'),
      ),
    );
  }

  Future<void> _deleteMember(FamilyMemberModel member) async {
    if (member.isPrimary && _members.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set another primary member first'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Member?'),
          content: Text(
            'Are you sure you want to delete "${member.displayName}"?',
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
      _members.removeWhere((item) => item.id == member.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Family member deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Family Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _members.isEmpty
                  ? const _EmptyMembersState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _members.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final member = _members[index];

                        return _FamilyMemberCard(
                          member: member,
                          onEdit: () => _editMember(member),
                          onDelete: () => _deleteMember(member),
                          onSetPrimary: () => _setPrimary(member),
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
                label: 'Add Family Member',
                onPressed: _addMember,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMemberModel member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _FamilyMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: member.isPrimary ? AppColors.primaryBlue : AppColors.borderGray,
          width: member.isPrimary ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: member.isPrimary
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
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryBlue,
                  size: 32,
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
                            member.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        if (member.isPrimary) ...[
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
                              'Primary',
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      member.displayRelationship,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (member.phone.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        member.phone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: _MedicalInfoBox(
                  label: 'Blood Type',
                  value: member.bloodType.trim().isEmpty
                      ? 'N/A'
                      : member.bloodType,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MedicalInfoBox(
                  label: 'Allergies',
                  value: member.allergies.trim().isEmpty
                      ? 'None'
                      : member.allergies,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          _MedicalInfoBox(
            label: 'Chronic Conditions',
            value: member.chronicConditions.trim().isEmpty
                ? 'None'
                : member.chronicConditions,
            fullWidth: true,
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              if (!member.isPrimary)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSetPrimary,
                    child: const Text('Set Primary'),
                  ),
                ),
              if (!member.isPrimary) const SizedBox(width: AppSpacing.md),
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

class _MedicalInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;

  const _MedicalInfoBox({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textLight,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: fullWidth ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMembersState extends StatelessWidget {
  const _EmptyMembersState();

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
                Icons.family_restroom_rounded,
                color: AppColors.primaryBlue,
                size: 46,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No family members yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add dependents to book healthcare visits for them.',
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