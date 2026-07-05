import 'package:flutter/material.dart';

import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class NurseFilterSheet extends StatefulWidget {
  final NurseFilters? initialFilters;
  final ValueChanged<NurseFilters> onApply;

  const NurseFilterSheet({
    super.key,
    this.initialFilters,
    required this.onApply,
  });

  @override
  State<NurseFilterSheet> createState() => _NurseFilterSheetState();
}

class _NurseFilterSheetState extends State<NurseFilterSheet> {
  late RangeValues _priceRange;
  late double _minRating;
  late List<String> _selectedSpecialties;
  late bool _availableNow;
  late bool _certified;

  static const List<String> _specialties = [
    'Elderly Care',
    'Post-Surgery',
    'Pediatrics',
    'ICU',
    'Home Care',
    'Wound Care',
    'Physiotherapy',
  ];

  @override
  void initState() {
    super.initState();

    final initial = widget.initialFilters;

    _priceRange = initial?.priceRange ?? NurseFilters.defaultPriceRange;
    _minRating = initial?.minRating ?? NurseFilters.defaultMinRating;
    _selectedSpecialties = List<String>.from(initial?.specialties ?? const []);
    _availableNow = initial?.availableNow ?? false;
    _certified = initial?.certified ?? false;
  }

  bool get _hasChanges {
    return _availableNow ||
        _certified ||
        _selectedSpecialties.isNotEmpty ||
        _minRating != NurseFilters.defaultMinRating ||
        _priceRange.start != NurseFilters.defaultPriceRange.start ||
        _priceRange.end != NurseFilters.defaultPriceRange.end;
  }

  void _handleApply() {
    widget.onApply(
      NurseFilters(
        priceRange: _priceRange,
        minRating: _minRating,
        specialties: List.unmodifiable(_selectedSpecialties),
        availableNow: _availableNow,
        certified: _certified,
      ),
    );

    Navigator.pop(context);
  }

  void _handleReset() {
    setState(() {
      _priceRange = NurseFilters.defaultPriceRange;
      _minRating = NurseFilters.defaultMinRating;
      _selectedSpecialties = [];
      _availableNow = false;
      _certified = false;
    });
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (_selectedSpecialties.contains(specialty)) {
        _selectedSpecialties.remove(specialty);
      } else {
        _selectedSpecialties.add(specialty);
      }
    });
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              const SizedBox(height: AppSpacing.lg),
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xl),
              _buildPriceSection(context),
              const SizedBox(height: AppSpacing.xl),
              _buildRatingSection(context),
              const SizedBox(height: AppSpacing.xl),
              _buildSpecialtiesSection(context),
              const SizedBox(height: AppSpacing.xl),
              _buildSwitches(context),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.borderGray,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Refine nurses by price, rating, specialty and availability.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return _FilterSection(
      title: 'Hourly Rate',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ValueBadge(label: _money(_priceRange.start)),
              _ValueBadge(label: _money(_priceRange.end)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RangeSlider(
            values: _priceRange,
            min: NurseFilters.minPrice,
            max: NurseFilters.maxPrice,
            divisions: 40,
            labels: RangeLabels(
              _money(_priceRange.start),
              _money(_priceRange.end),
            ),
            activeColor: AppColors.primaryBlue,
            inactiveColor: AppColors.borderGray,
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return _FilterSection(
      title: 'Minimum Rating',
      child: Row(
        children: [
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= _minRating;

              return GestureDetector(
                onTap: () {
                  setState(() => _minRating = starValue.toDouble());
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    isSelected
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isSelected ? Colors.amber : AppColors.borderGray,
                    size: 34,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${_minRating.toStringAsFixed(0)}+',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesSection(BuildContext context) {
    return _FilterSection(
      title: 'Specialties',
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: _specialties.map((specialty) {
          final isSelected = _selectedSpecialties.contains(specialty);

          return GestureDetector(
            onTap: () => _toggleSpecialty(specialty),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.bgGray,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.borderGray,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primaryBlue.withValues(alpha: 0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    specialty,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color:
                              isSelected ? AppColors.white : AppColors.textDark,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitches(BuildContext context) {
    return Column(
      children: [
        _FilterSwitchTile(
          icon: Icons.flash_on_rounded,
          title: 'Available now',
          subtitle: 'Show nurses currently available for booking.',
          value: _availableNow,
          onChanged: (value) {
            setState(() => _availableNow = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterSwitchTile(
          icon: Icons.verified_rounded,
          title: 'Certified only',
          subtitle: 'Show only verified and certified providers.',
          value: _certified,
          onChanged: (value) {
            setState(() => _certified = value);
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Reset',
            isOutlined: true,
            onPressed: _handleReset,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: CustomButton(
            label: _hasChanges ? 'Apply Filters' : 'Apply',
            onPressed: _handleApply,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  final String label;

  const _ValueBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _FilterSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryBlue.withValues(alpha: 0.08)
            : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: value ? AppColors.primaryBlue : AppColors.borderGray,
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 24,
            ),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryBlue,
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.24),
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.borderGray,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Filter model
// -----------------------------------------------------------------------------

class NurseFilters {
  static const double minPrice = 0;
  static const double maxPrice = 1000;

  static const RangeValues defaultPriceRange = RangeValues(200, 800);
  static const double defaultMinRating = 4.0;

  final RangeValues priceRange;
  final double minRating;
  final List<String> specialties;
  final bool availableNow;
  final bool certified;

  const NurseFilters({
    required this.priceRange,
    required this.minRating,
    required this.specialties,
    required this.availableNow,
    required this.certified,
  });

  bool get hasActiveFilters {
    return availableNow ||
        certified ||
        specialties.isNotEmpty ||
        minRating != defaultMinRating ||
        priceRange.start != defaultPriceRange.start ||
        priceRange.end != defaultPriceRange.end;
  }

  NurseFilters copyWith({
    RangeValues? priceRange,
    double? minRating,
    List<String>? specialties,
    bool? availableNow,
    bool? certified,
  }) {
    return NurseFilters(
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      specialties: specialties ?? this.specialties,
      availableNow: availableNow ?? this.availableNow,
      certified: certified ?? this.certified,
    );
  }
}