import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class MyExpertisePricingScreen extends StatefulWidget {
  const MyExpertisePricingScreen({super.key});

  @override
  State<MyExpertisePricingScreen> createState() =>
      _MyExpertisePricingScreenState();
}

class _MyExpertisePricingScreenState extends State<MyExpertisePricingScreen> {
  final ValueNotifier<List<_ServicePricing>> _servicesNotifier =
      ValueNotifier<List<_ServicePricing>>(
    const [
      _ServicePricing(name: 'Home Care', price: 250, enabled: true),
      _ServicePricing(name: 'Post-Surgery Care', price: 400, enabled: true),
      _ServicePricing(name: 'Vital Signs Monitoring', price: 150, enabled: true),
      _ServicePricing(name: 'Medication Administration', price: 200, enabled: false),
      _ServicePricing(name: 'Wound Dressing', price: 300, enabled: true),
    ],
  );

  @override
  void dispose() {
    _servicesNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.nurseSettings);
  }

  void _toggle(int index, bool value) {
    final list = List<_ServicePricing>.of(_servicesNotifier.value);
    list[index] = list[index].copyWith(enabled: value);
    _servicesNotifier.value = list;
  }

  void _updatePrice(int index, String value) {
    final price = double.tryParse(value.trim()) ?? 0;
    final list = List<_ServicePricing>.of(_servicesNotifier.value);
    list[index] = list[index].copyWith(price: price);
    _servicesNotifier.value = list;
  }

  void _save() {
    final selected = _servicesNotifier.value.where((item) => item.enabled);

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable at least one service'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (selected.any((item) => item.price <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All enabled services must have valid prices'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expertise and pricing saved'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.pop();
  }

  double _averagePrice(List<_ServicePricing> services) {
    final enabled = services.where((item) => item.enabled).toList();
    if (enabled.isEmpty) return 0;
    return enabled.fold<double>(0, (sum, item) => sum + item.price) /
        enabled.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Expertise & Pricing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<_ServicePricing>>(
          valueListenable: _servicesNotifier,
          builder: (context, services, _) {
            final enabledCount = services.where((item) => item.enabled).length;
            final average = _averagePrice(services);

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(
                      [
                        _HeaderCard(
                          enabledCount: enabledCount,
                          averagePrice: average,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: services.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final service = services[index];

                            return _ServicePricingTile(
                              service: service,
                              onToggle: (value) => _toggle(index, value),
                              onPriceChanged: (value) =>
                                  _updatePrice(index, value),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: const Text('Save Expertise & Pricing'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServicePricing {
  final String name;
  final double price;
  final bool enabled;

  const _ServicePricing({
    required this.name,
    required this.price,
    required this.enabled,
  });

  _ServicePricing copyWith({
    String? name,
    double? price,
    bool? enabled,
  }) {
    return _ServicePricing(
      name: name ?? this.name,
      price: price ?? this.price,
      enabled: enabled ?? this.enabled,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int enabledCount;
  final double averagePrice;

  const _HeaderCard({
    required this.enabledCount,
    required this.averagePrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_services_rounded,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$enabledCount active services',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Average EGP ${averagePrice.toStringAsFixed(0)} / visit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicePricingTile extends StatelessWidget {
  final _ServicePricing service;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onPriceChanged;

  const _ServicePricingTile({
    required this.service,
    required this.onToggle,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Row(
          children: [
            Switch(
              value: service.enabled,
              activeThumbColor: AppColors.primaryBlue,
              onChanged: onToggle,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                service.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            SizedBox(
              width: 95,
              child: TextFormField(
                initialValue: service.price.toStringAsFixed(0),
                enabled: service.enabled,
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: onPriceChanged,
                decoration: const InputDecoration(
                  prefixText: 'EGP ',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
    );
  }
}