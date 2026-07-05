import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PaymentMethodType {
  card,
  wallet,
  mobileWallet,
  cash;

  String get displayName {
    switch (this) {
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.wallet:
        return 'MedLink Wallet';
      case PaymentMethodType.mobileWallet:
        return 'Mobile Wallet';
      case PaymentMethodType.cash:
        return 'Cash on Visit';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.card:
        return Icons.credit_card_rounded;
      case PaymentMethodType.wallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethodType.mobileWallet:
        return Icons.phone_android_rounded;
      case PaymentMethodType.cash:
        return Icons.payments_rounded;
    }
  }

  String get storageValue {
    switch (this) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.wallet:
        return 'wallet';
      case PaymentMethodType.mobileWallet:
        return 'mobile_wallet';
      case PaymentMethodType.cash:
        return 'cash';
    }
  }

  static PaymentMethodType fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'card':
      case 'credit_card':
      case 'credit-card':
      case 'credit card':
      case 'debit_card':
      case 'debit-card':
      case 'debit card':
        return PaymentMethodType.card;

      case 'wallet':
      case 'medlink_wallet':
      case 'medlink-wallet':
      case 'medlink wallet':
        return PaymentMethodType.wallet;

      case 'mobilewallet':
      case 'mobile_wallet':
      case 'mobile-wallet':
      case 'mobile wallet':
      case 'vodafone_cash':
      case 'vodafone-cash':
      case 'vodafone cash':
        return PaymentMethodType.mobileWallet;

      case 'cash':
      case 'cash_on_visit':
      case 'cash-on-visit':
      case 'cash on visit':
      case 'cod':
      case 'pay_on_visit':
      case 'pay-on-visit':
      case 'pay on visit':
        return PaymentMethodType.cash;

      default:
        return PaymentMethodType.card;
    }
  }
}

class SavedCard extends Equatable {
  final String id;
  final String last4;
  final String brand;
  final String expiry;
  final bool isDefault;

  const SavedCard({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
    this.isDefault = false,
  });

  String get displayBrand {
    final clean = brand.trim();

    if (clean.isEmpty) {
      return 'CARD';
    }

    return clean.toUpperCase();
  }

  String get displayLast4 {
    final clean = last4.trim();

    if (clean.isEmpty) {
      return '0000';
    }

    if (clean.length > 4) {
      return clean.substring(clean.length - 4);
    }

    return clean.padLeft(4, '0');
  }

  String get displayExpiry {
    final clean = expiry.trim();

    if (clean.isEmpty) {
      return '--/--';
    }

    return clean;
  }

  String get maskedNumber {
    return '•••• •••• •••• $displayLast4';
  }

  SavedCard copyWith({
    String? id,
    String? last4,
    String? brand,
    String? expiry,
    bool? isDefault,
  }) {
    return SavedCard(
      id: id ?? this.id,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory SavedCard.empty() {
    return const SavedCard(
      id: '',
      last4: '',
      brand: '',
      expiry: '',
      isDefault: false,
    );
  }

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['id']?.toString() ?? '',
      last4: json['last4']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      expiry: json['expiry']?.toString() ?? '',
      isDefault: _toBool(json['isDefault'] ?? json['is_default']),
    );
  }

  factory SavedCard.fromStorageJson(Map<String, dynamic> json) {
    return SavedCard.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last4': displayLast4,
      'brand': displayBrand,
      'expiry': displayExpiry,
      'isDefault': isDefault,
    };
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'last4': displayLast4,
      'brand': displayBrand,
      'expiry': displayExpiry,
      'isDefault': isDefault,
    };
  }

  static bool _toBool(Object? value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    if (value is String) {
      final clean = value.trim().toLowerCase();

      return clean == 'true' ||
          clean == '1' ||
          clean == 'yes' ||
          clean == 'y';
    }

    return false;
  }

  @override
  List<Object?> get props => [
        id,
        last4,
        brand,
        expiry,
        isDefault,
      ];
}