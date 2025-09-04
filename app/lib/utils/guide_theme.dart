import 'package:flutter/material.dart';
import '../models/enums.dart';
import 'app_theme.dart';

/// Guide-specific visual theme configuration that integrates with AppTheme
class GuideTheme {
  /// Get the primary color for a specific guide type
  static Color getPrimaryColor(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return const Color(0xFF6B46C1); // Deep purple - wisdom and mysticism
      case GuideType.healer:
        return const Color(0xFFEC4899); // Soft pink - compassion and healing
      case GuideType.mentor:
        return const Color(0xFF2563EB); // Strong blue - clarity and direction
      case GuideType.visionary:
        return const Color(0xFF8B5CF6); // Cosmic purple - creativity and vision
    }
  }

  /// Get the accent color for a specific guide type
  static Color getAccentColor(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return const Color(0xFFF59E0B); // Gold - enlightenment and wisdom
      case GuideType.healer:
        return const Color(0xFFFEF7FF); // Warm white - purity and peace
      case GuideType.mentor:
        return const Color(0xFFE5E7EB); // Silver - precision and clarity
      case GuideType.visionary:
        return const Color(
          0xFFFBBF24,
        ); // Starlight gold - inspiration and magic
    }
  }

  /// Get a gradient for guide backgrounds
  static LinearGradient getGradient(GuideType guideType) {
    final primary = getPrimaryColor(guideType);
    final accent = getAccentColor(guideType);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary.withValues(alpha: 0.1),
        primary.withValues(alpha: 0.3),
        accent.withValues(alpha: 0.2),
      ],
    );
  }

  /// Get a radial gradient for guide glows/auras
  static RadialGradient getRadialGradient(GuideType guideType) {
    final primary = getPrimaryColor(guideType);

    return RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        primary.withValues(alpha: 0.3),
        primary.withValues(alpha: 0.1),
        primary.withValues(alpha: 0.0),
      ],
    );
  }

  /// Get the image asset path for a guide
  static String getImageAssetPath(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return 'assets/images/guide_zian.jpg';
      case GuideType.healer:
        return 'assets/images/guide_lyra.jpg';
      case GuideType.mentor:
        return 'assets/images/guide_kael.jpg';
      case GuideType.visionary:
        return 'assets/images/guide_elara.jpg';
    }
  }

  /// Get the appropriate icon data for fallback when SVG is not available
  static IconData getIconData(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return Icons.auto_awesome; // Constellation/interconnected pattern
      case GuideType.healer:
        return Icons.favorite; // Heart/lotus shape
      case GuideType.mentor:
        return Icons.trending_up; // Arrow/mountain peak
      case GuideType.visionary:
        return Icons.visibility; // Eye/nebula
    }
  }

  /// Get guide-specific color scheme for theming
  static ColorScheme getColorScheme(
    GuideType guideType,
    Brightness brightness,
  ) {
    final primary = getPrimaryColor(guideType);
    final accent = getAccentColor(guideType);

    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: accent,
    );
  }

  /// Get text color that contrasts well with guide's primary color
  static Color getContrastingTextColor(GuideType guideType) {
    final primary = getPrimaryColor(guideType);
    // Use luminance to determine if we need light or dark text
    return primary.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Get a subtle background color for guide-themed containers
  static Color getSubtleBackgroundColor(GuideType guideType) {
    return getPrimaryColor(guideType).withValues(alpha: 0.05);
  }

  /// Get border color for guide-themed elements
  static Color getBorderColor(GuideType guideType, {bool isSelected = false}) {
    final primary = getPrimaryColor(guideType);
    if (isSelected) {
      return primary;
    }
    return primary.withValues(alpha: 0.3);
  }

  /// Get shadow color for guide-themed elements
  static Color getShadowColor(GuideType guideType) {
    return getPrimaryColor(guideType).withValues(alpha: 0.2);
  }

  /// Get a themed decoration for guide cards
  static BoxDecoration getCardDecoration(
    GuideType guideType, {
    bool isSelected = false,
    bool isHovered = false,
    bool isRecommended = false,
    bool isLocked = false,
  }) {
    final primary = getPrimaryColor(guideType);

    return BoxDecoration(
      borderRadius: GuideBorderRadius.card,
      gradient: isLocked
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.withValues(alpha: 0.1),
                Colors.grey.withValues(alpha: 0.2),
                Colors.grey.withValues(alpha: 0.1),
              ],
            )
          : getGradient(guideType),
      border: Border.all(
        color: isLocked
            ? Colors.grey.withValues(alpha: 0.4)
            : isSelected
            ? primary
            : isRecommended
            ? AppTheme.primaryPurple.withValues(alpha: 0.5)
            : primary.withValues(alpha: 0.2),
        width: isSelected
            ? 3
            : isRecommended
            ? 2
            : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isLocked
              ? Colors.grey.withValues(alpha: 0.2)
              : getShadowColor(guideType),
          blurRadius: isSelected
              ? GuideElevations.selectedCard
              : isHovered
              ? GuideElevations.hoveredCard
              : GuideElevations.card,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get a themed text style for guide content
  static TextStyle getGuideTextStyle(
    BuildContext context,
    GuideType guideType, {
    TextStyle? baseStyle,
    bool isTitle = false,
  }) {
    final primary = getPrimaryColor(guideType);
    final baseTextStyle =
        baseStyle ??
        (isTitle
            ? Theme.of(context).textTheme.titleMedium
            : Theme.of(context).textTheme.bodyMedium);

    return baseTextStyle?.copyWith(
          color: getContrastingTextColor(guideType),
          fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: primary.withValues(alpha: 0.3),
            ),
          ],
        ) ??
        const TextStyle();
  }

  /// Get a pulsing animation for guide glyphs
  static Widget getPulsingGlyph(Widget child, GuideType guideType) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: GuideAnimations.glowPulseDuration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: getPrimaryColor(guideType).withValues(alpha: 0.3),
                  blurRadius: 20 * scale,
                  spreadRadius: 5 * scale,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Create a shimmering effect for guide elements
  static Widget getShimmerEffect(Widget child, GuideType guideType) {
    return AnimatedContainer(
      duration: GuideAnimations.glowPulseDuration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            getPrimaryColor(guideType).withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Animation configurations for guide interactions
class GuideAnimations {
  static const Duration selectionDuration = Duration(milliseconds: 300);
  static const Duration hoverDuration = Duration(milliseconds: 200);
  static const Duration glowPulseDuration = Duration(milliseconds: 2000);
  static const Duration cardFlipDuration = Duration(milliseconds: 400);

  static const Curve selectionCurve = Curves.easeInOutCubic;
  static const Curve hoverCurve = Curves.easeInOut;
  static const Curve glowCurve = Curves.easeInOut;
  static const Curve cardFlipCurve = Curves.easeInOutBack;
}

/// Elevation levels for guide-themed elements
class GuideElevations {
  static const double card = 4.0;
  static const double selectedCard = 8.0;
  static const double hoveredCard = 6.0;
  static const double modal = 16.0;
}

/// Spacing specifically for guide layouts
class GuideSpacing {
  static const double cardPadding = 16.0;
  static const double cardMargin = 12.0;
  static const double glyphSize = 48.0;
  static const double iconSize = 24.0;
  static const double badgeSize = 20.0;
}

/// Border radius values for guide elements
class GuideBorderRadius {
  static const BorderRadius card = BorderRadius.all(Radius.circular(20));
  static const BorderRadius glyph = BorderRadius.all(Radius.circular(24));
  static const BorderRadius badge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius modal = BorderRadius.all(Radius.circular(28));
}
