import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Short-hands for theme access and snackbars.
extension ContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Shows a floating snackbar. Set [isError] for a red one.
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : null,
        ),
      );
  }
}
