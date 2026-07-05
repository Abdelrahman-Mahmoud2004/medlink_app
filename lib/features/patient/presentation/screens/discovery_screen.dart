import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../data/models/nurse_model.dart';
import '../widgets/nurse_filter_sheet.dart';
import '../widgets/recommended_nurse_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final List<NurseModel> _allNurses;
  List<NurseModel> _filteredNurses = [];

  String _selectedCategory = 'All';
  NurseFilters? _currentFilters;

  static const List<String> _categories = [
    'All',
    'Elderly Care',
    'Post-Surgery',
    'Pediatrics',
    'ICU',
    'Home Care',
  ];

  @override
  void initState() {
    super.initState();
    _allNurses = _buildDummyNurses();
    _filteredNurses = List.of(_allNurses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NurseModel> _buildDummyNurses() => [
        const NurseModel(
          id: '1',
          name: 'Fatima Al-Sayed',
          specialty: 'ICU Specialist',
          imageUrl: 'https://via.placeholder.com/150',
          rating: 4.9,
          reviewCount: 124,
          hourlyRate: 'EGP 650',
          experience: '7 Years Exp.',
          isAvailable: true,
          availabilityStatus: 'Available today',
          patientsServed: 500,
          isCertified: true,
          isOnline: true,
        ),
        const NurseModel(
          id: '2',
          name: 'Ahmed Hassan',
          specialty: 'Geriatric Care',
          imageUrl: 'https://via.placeholder.com/150',
          rating: 4.8,
          reviewCount: 98,
          hourlyRate: 'EGP 550',
          experience: '5 Years Exp.',
          isAvailable: false,
          availabilityStatus: 'Next slot: 2pm',
          patientsServed: 320,
          isCertified: true,
          isOnline: false,
        ),
        const NurseModel(
          id: '3',
          name: 'Layla Mahmoud',
          specialty: 'Pediatric Nurse',
          imageUrl: 'https://via.placeholder.com/150',
          rating: 5.0,
          reviewCount: 156,
          hourlyRate: 'EGP 700',
          experience: '8 Years Exp.',
          isAvailable: true,
          availabilityStatus: 'Available now',
          patientsServed: 450,
          isCertified: true,
          isOnline: true,
        ),
        const NurseModel(
          id: '4',
          name: 'Omar Hassan',
          specialty: 'Post-Surgery Care',
          imageUrl: 'https://via.placeholder.com/150',
          rating: 4.7,
          reviewCount: 89,
          hourlyRate: 'EGP 600',
          experience: '6 Years Exp.',
          isAvailable: true,
          availabilityStatus: 'Available today',
          patientsServed: 280,
          isCertified: true,
          isOnline: true,
        ),
        const NurseModel(
          id: '5',
          name: 'Hana Ali',
          specialty: 'Home Care',
          imageUrl: 'https://via.placeholder.com/150',
          rating: 4.6,
          reviewCount: 72,
          hourlyRate: 'EGP 450',
          experience: '4 Years Exp.',
          isAvailable: false,
          availabilityStatus: 'Next slot: 4pm',
          patientsServed: 200,
          isCertified: false,
          isOnline: false,
        ),
      ];

  bool get _hasActiveFilters {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasCategory = _selectedCategory != 'All';
    final hasAdvancedFilters = _currentFilters?.hasActiveFilters ?? false;

    return hasSearch || hasCategory || hasAdvancedFilters;
  }

  bool _matchesCategory(NurseModel nurse, String category) {
    if (category == 'All') return true;

    final specialty = nurse.specialty.toLowerCase();

    switch (category) {
      case 'Elderly Care':
        return specialty.contains('elderly') ||
            specialty.contains('geriatric');

      case 'Post-Surgery':
        return specialty.contains('post-surgery') ||
            specialty.contains('post surgery') ||
            specialty.contains('post-op') ||
            specialty.contains('surgery');

      case 'Pediatrics':
        return specialty.contains('pediatric') ||
            specialty.contains('pediatrics');

      case 'ICU':
        return specialty.contains('icu');

      case 'Home Care':
        return specialty.contains('home care');

      default:
        return specialty.contains(category.toLowerCase());
    }
  }

  void _openNurseProfile(NurseModel nurse) {
    context.push(
      AppRoutes.nurseProfile,
      extra: nurse,
    );
  }

  void _startBooking(NurseModel nurse) {
    context.push(
      AppRoutes.selectDateTime,
      extra: nurse,
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _applyAllFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredNurses = _allNurses.where((nurse) {
        if (query.isNotEmpty) {
          final matchesName = nurse.name.toLowerCase().contains(query);
          final matchesSpecialty =
              nurse.specialty.toLowerCase().contains(query);

          if (!matchesName && !matchesSpecialty) {
            return false;
          }
        }

        if (!_matchesCategory(nurse, _selectedCategory)) {
          return false;
        }

        final filters = _currentFilters;

        if (filters != null) {
          if (nurse.hourlyRateValue < filters.priceRange.start ||
              nurse.hourlyRateValue > filters.priceRange.end) {
            return false;
          }

          if (nurse.rating < filters.minRating) {
            return false;
          }

          if (filters.specialties.isNotEmpty &&
              !filters.specialties.contains(nurse.specialty)) {
            return false;
          }

          if (filters.availableNow && !nurse.isAvailable) {
            return false;
          }

          if (filters.certified && !nurse.isCertified) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _handleSearch(String _) {
    _applyAllFilters();
  }

  void _handleCategorySelect(String category) {
    _selectedCategory = category;
    _applyAllFilters();
  }

  void _handleFilter() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NurseFilterSheet(
          onApply: (filters) {
            _currentFilters = filters;
            _applyAllFilters();
          },
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _applyAllFilters();
  }

  void _clearAllFilters() {
    _searchController.clear();
    _selectedCategory = 'All';
    _currentFilters = null;
    _applyAllFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text(AppStrings.findNurse),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: _filteredNurses.isEmpty
                  ? _buildEmptyState(context)
                  : _buildNurseList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppColors.bgGray,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchByNameOrSpecialty,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textLight,
                    ),
                    suffixIcon: _searchController.text.trim().isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textLight,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: AppColors.borderGray,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: AppColors.borderGray,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _FilterButton(
                hasActiveFilters: _hasActiveFilters,
                onTap: _handleFilter,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCategoryChips(),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () => _handleCategorySelect(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.borderGray,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.025),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            isSelected ? AppColors.white : AppColors.textDark,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNurseList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      itemCount: _filteredNurses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final nurse = _filteredNurses[index];

        return RecommendedNurseCard(
          nurse: nurse,
          onTap: () => _openNurseProfile(nurse),
          onBookTap: () => _startBooking(nurse),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 46,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.noNursesFound,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.adjustSearchOrFilters,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.clearAllFilters),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onTap;

  const _FilterButton({
    required this.hasActiveFilters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color:
                  hasActiveFilters ? AppColors.primaryBlue : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: hasActiveFilters
                    ? AppColors.primaryBlue
                    : AppColors.borderGray,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasActiveFilters
                      ? AppColors.primaryBlue.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasActiveFilters ? AppColors.white : AppColors.primaryBlue,
              size: 22,
            ),
          ),
          if (hasActiveFilters)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.warningOrange,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}