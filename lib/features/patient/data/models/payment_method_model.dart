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

  static PaymentMethodType fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'card':
        return PaymentMethodType.card;
      case 'wallet':
        return PaymentMethodType.wallet;
      case 'mobilewallet':
      case 'mobile_wallet':
      case 'mobile-wallet':
      case 'mobile wallet':
        return PaymentMethodType.mobileWallet;
      case 'cash':
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
    return clean.isEmpty ? 'CARD' : clean.toUpperCase();
  }

  String get displayLast4 {
    final clean = last4.trim();
    return clean.isEmpty ? '0000' : clean;
  }

  String get displayExpiry {
    final clean = expiry.trim();
    return clean.isEmpty ? '--/--' : clean;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last4': last4,
      'brand': brand,
      'expiry': expiry,
      'isDefault': isDefault,
    };
  }

  static bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final clean = value.trim().toLowerCase();
      return clean == 'true' || clean == '1' || clean == 'yes';
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