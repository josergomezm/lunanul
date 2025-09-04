import 'package:flutter/material.dart';

/// Service interface for managing Oracle tier customization features
/// Handles themes, card backs, and visual personalization options
abstract class CustomizationService {
  /// Gets all available app themes for Oracle subscribers
  ///
  /// Returns a list of available theme configurations
  Future<List<AppThemeConfig>> getAvailableThemes();

  /// Gets the currently active theme
  ///
  /// Returns the current theme configuration
  Future<AppThemeConfig?> getCurrentTheme();

  /// Sets a new theme for the app
  ///
  /// [themeId] - The ID of the theme to apply
  ///
  /// Returns true if the theme was successfully applied
  Future<bool> setTheme(String themeId);

  /// Gets all available card back designs
  ///
  /// Returns a list of available card back configurations
  Future<List<CardBackConfig>> getAvailableCardBacks();

  /// Gets the currently selected card back design
  ///
  /// Returns the current card back configuration
  Future<CardBackConfig?> getCurrentCardBack();

  /// Sets a new card back design
  ///
  /// [cardBackId] - The ID of the card back to use
  ///
  /// Returns true if the card back was successfully set
  Future<bool> setCardBack(String cardBackId);

  /// Gets available color accent options for the current theme
  ///
  /// [themeId] - The theme to get accent colors for (optional, uses current if null)
  ///
  /// Returns a list of available accent colors
  Future<List<AccentColorConfig>> getAvailableAccentColors({String? themeId});

  /// Sets a custom accent color for the current theme
  ///
  /// [colorId] - The ID of the accent color to apply
  ///
  /// Returns true if the accent color was successfully applied
  Future<bool> setAccentColor(String colorId);

  /// Gets available animation styles and effects
  ///
  /// Returns a list of available animation configurations
  Future<List<AnimationConfig>> getAvailableAnimations();

  /// Sets animation preferences for the app
  ///
  /// [animationId] - The ID of the animation style to use
  ///
  /// Returns true if the animation style was successfully set
  Future<bool> setAnimationStyle(String animationId);

  /// Creates a custom theme configuration
  ///
  /// [name] - Name for the custom theme
  /// [baseTheme] - Base theme to start from
  /// [customizations] - Map of customization options
  ///
  /// Returns the ID of the created custom theme
  Future<String?> createCustomTheme({
    required String name,
    required String baseTheme,
    required Map<String, dynamic> customizations,
  });

  /// Saves the current customization settings to user preferences
  ///
  /// Returns true if settings were successfully saved
  Future<bool> saveCustomizationSettings();

  /// Restores customization settings from user preferences
  ///
  /// Returns true if settings were successfully restored
  Future<bool> restoreCustomizationSettings();

  /// Resets all customizations to default values
  ///
  /// Returns true if reset was successful
  Future<bool> resetToDefaults();

  /// Checks if a specific customization feature is available
  ///
  /// [feature] - The customization feature to check
  ///
  /// Returns true if the feature is available for the current subscription
  bool isCustomizationAvailable(CustomizationFeature feature);
}

/// Configuration for app themes
class AppThemeConfig {
  final String id;
  final String name;
  final String description;
  final String previewImageUrl;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool isPremium;
  final List<String> availableAccentColors;

  const AppThemeConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImageUrl,
    required this.lightTheme,
    required this.darkTheme,
    this.isPremium = false,
    this.availableAccentColors = const [],
  });
}

/// Configuration for card back designs
class CardBackConfig {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final bool isPremium;
  final CardBackStyle style;
  final Map<String, dynamic> customProperties;

  const CardBackConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.isPremium = false,
    this.style = CardBackStyle.traditional,
    this.customProperties = const {},
  });
}

/// Configuration for accent colors
class AccentColorConfig {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final bool isPremium;

  const AccentColorConfig({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.isPremium = false,
  });
}

/// Configuration for animations
class AnimationConfig {
  final String id;
  final String name;
  final String description;
  final Duration cardFlipDuration;
  final Duration transitionDuration;
  final Curve animationCurve;
  final bool enableParticleEffects;
  final bool isPremium;

  const AnimationConfig({
    required this.id,
    required this.name,
    required this.description,
    this.cardFlipDuration = const Duration(milliseconds: 600),
    this.transitionDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enableParticleEffects = false,
    this.isPremium = false,
  });
}

/// Types of card back styles
enum CardBackStyle {
  traditional,
  modern,
  mystical,
  minimalist,
  ornate,
  celestial,
}

/// Available customization features
enum CustomizationFeature {
  themes,
  cardBacks,
  accentColors,
  animations,
  customThemes,
  particleEffects,
}

/// Exception thrown when customization operations fail
class CustomizationException implements Exception {
  final String message;
  final CustomizationError error;
  final dynamic originalError;

  const CustomizationException({
    required this.message,
    required this.error,
    this.originalError,
  });

  @override
  String toString() => 'CustomizationException: $message';
}

/// Types of customization errors
enum CustomizationError {
  themeNotFound,
  cardBackNotFound,
  invalidConfiguration,
  storageError,
  networkError,
  subscriptionRequired,
  quotaExceeded,
}
