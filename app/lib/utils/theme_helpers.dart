import 'package:flutter/material.dart';

/// Utility functions for theme-aware styling
class ThemeHelpers {
  /// Returns a background color with appropriate opacity for the current theme
  static Color getBackgroundOverlay(BuildContext context, {double? opacity}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = opacity ?? (isDark ? 0.8 : 0.9);

    return Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: effectiveOpacity);
  }

  /// Returns a card color with appropriate opacity for better visibility over backgrounds
  static Color getCardColor(BuildContext context, {double? opacity}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = opacity ?? (isDark ? 0.95 : 0.98);

    return Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: effectiveOpacity);
  }

  /// Returns appropriate shadow for the current theme
  static List<BoxShadow> getCardShadow(
    BuildContext context, {
    double? elevation,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveElevation = elevation ?? 8.0;

    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.1),
        blurRadius: effectiveElevation,
        offset: Offset(0, effectiveElevation / 2),
      ),
    ];
  }

  /// Returns a gradient overlay color for backgrounds
  static Color getGradientOverlay(BuildContext context, double opacity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? Colors.black.withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity);
  }
}
