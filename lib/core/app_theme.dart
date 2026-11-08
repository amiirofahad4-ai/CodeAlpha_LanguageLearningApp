import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'constants.dart';

/// Light and dark Material 3 themes built on the brand palette.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final radius = BorderRadius.circular(AppConstants.radius);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? AppColors.primaryDarkMode : AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: surface,
          onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          onSurfaceVariant: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
          outline: border,
          outlineVariant: border,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(
      base.textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final buttonShape = RoundedRectangleBorder(borderRadius: radius);
    final buttonText = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: buttonShape,
          side: BorderSide(color: border, width: 1.5),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.titleSmall,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: border),
      ),
    );
  }
}
