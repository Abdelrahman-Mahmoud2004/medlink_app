import 'package:flutter/material.dart';

final class AppFonts {
  AppFonts._();

  static const String cairo = 'Cairo';
  static const String poppins = 'Poppins';
}

final class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF4A7FD7);
  static const Color darkBlue = Color(0xFF2C5AA0);
  static const Color lightBlue = Color(0xFFE8F0FF);

  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color errorRed = Color(0xFFEF4444);

  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgGray = Color(0xFFF9FAFB);

  static const Color onlineGreen = Color(0xFF10B981);
  static const Color offlineGray = Color(0xFF9CA3AF);
}

final class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

final class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

final class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.cairo,
      scaffoldBackgroundColor: AppColors.white,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.darkBlue,
        surface: AppColors.white,
        error: AppColors.errorRed,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _textStyle(
          18,
          FontWeight.w700,
          AppColors.textDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textDark,
        ),
      ),

      textTheme: TextTheme(
        displayLarge: _textStyle(32, FontWeight.w800, AppColors.textDark),
        displayMedium: _textStyle(28, FontWeight.w800, AppColors.textDark),
        displaySmall: _textStyle(24, FontWeight.w800, AppColors.textDark),
        headlineMedium: _textStyle(20, FontWeight.w700, AppColors.textDark),
        headlineSmall: _textStyle(18, FontWeight.w700, AppColors.textDark),
        titleLarge: _textStyle(16, FontWeight.w700, AppColors.textDark),
        titleMedium: _textStyle(14, FontWeight.w600, AppColors.textDark),
        bodyLarge: _textStyle(16, FontWeight.w400, AppColors.textDark),
        bodyMedium: _textStyle(14, FontWeight.w400, AppColors.textDark),
        bodySmall: _textStyle(12, FontWeight.w400, AppColors.textLight),
        labelLarge: _textStyle(14, FontWeight.w700, AppColors.primaryBlue),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.borderGray,
          disabledForegroundColor: AppColors.textLight,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: _textStyle(
            16,
            FontWeight.w700,
            AppColors.white,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          disabledForegroundColor: AppColors.textLight,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          side: const BorderSide(
            color: AppColors.borderGray,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: _textStyle(
            16,
            FontWeight.w700,
            AppColors.primaryBlue,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: _textStyle(
            14,
            FontWeight.w700,
            AppColors.primaryBlue,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgGray,
        hintStyle: _textStyle(
          14,
          FontWeight.w400,
          AppColors.textLight,
        ),
        labelStyle: _textStyle(
          14,
          FontWeight.w600,
          AppColors.textDark,
        ),
        errorStyle: _textStyle(
          12,
          FontWeight.w500,
          AppColors.errorRed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.borderGray,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.borderGray,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }

          return AppColors.white;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(
          color: AppColors.borderGray,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }

          return AppColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue.withValues(alpha: 0.24);
          }

          return AppColors.borderGray;
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: _textStyle(
          12,
          FontWeight.w700,
          AppColors.primaryBlue,
        ),
        unselectedLabelStyle: _textStyle(
          12,
          FontWeight.w500,
          AppColors.textLight,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: _textStyle(
          14,
          FontWeight.w500,
          AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderGray,
        thickness: 1,
      ),
    );
  }

  static TextStyle _textStyle(
    double size,
    FontWeight weight,
    Color color, {
    String fontFamily = AppFonts.cairo,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFamily: fontFamily,
    );
  }
}