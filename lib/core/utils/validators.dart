import '../../config/constants.dart';
import '../../config/strings.dart';

final class AppValidators {
  AppValidators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);

    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();

    final emailRegex = RegExp(
      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppStrings.invalidPassword;
    }

    return null;
  }

  static String? strongPassword(String? value) {
    final basicError = password(value);

    if (basicError != null) {
      return basicError;
    }

    final passwordValue = value!;

    if (!passwordValue.contains(RegExp(r'[A-Z]'))) {
      return AppStrings.passwordUppercase;
    }

    if (!passwordValue.contains(RegExp(r'[0-9]'))) {
      return AppStrings.passwordNumber;
    }

    if (!passwordValue.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppStrings.passwordSpecial;
    }

    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() getPassword,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }

      if (value != getPassword()) {
        return AppStrings.passwordMismatch;
      }

      return null;
    };
  }

  static String? name(String? value) {
    final requiredError = required(value);

    if (requiredError != null) {
      return requiredError;
    }

    final nameValue = value!.trim();

    if (nameValue.length < 3) {
      return AppStrings.invalidName;
    }

    return null;
  }

  static String? phone(String? value) {
    final requiredError = required(value);

    if (requiredError != null) {
      return requiredError;
    }

    final phoneValue = value!.trim();
    final digitsOnly = phoneValue.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < AppConstants.minPhoneLength ||
        digitsOnly.length > AppConstants.maxPhoneLength) {
      return AppStrings.invalidPhone;
    }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    final otpValue = value.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(otpValue)) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    return null;
  }
}