import 'dart:math';
import 'package:flutter/material.dart';
import 'customization_service.dart';

/// Mock implementation of CustomizationService for development and testing
class MockCustomizationService implements CustomizationService {
  final Random _random = Random();
  String? _currentThemeId = 'default';
  String? _currentCardBackId = 'classic';
  String? _currentAccentColorId = 'mystical_purple';
  String? _currentAnimationId = 'gentle';

  // Mock theme configurations
  static final List<AppThemeConfig> _mockThemes = [
    AppThemeConfig(
      id: 'default',
      name: 'Lunanul Classic',
      description: 'The original tranquil theme with soft purples and golds',
      previewImageUrl: 'assets/images/themes/classic_preview.png',
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      isPremium: false,
      availableAccentColors: [
        'mystical_purple',
        'golden_hour',
        'moonlight_blue',
      ],
    ),
    AppThemeConfig(
      id: 'celestial',
      name: 'Celestial Dreams',
      description: 'Deep blues and silvers inspired by the night sky',
      previewImageUrl: 'assets/images/themes/celestial_preview.png',
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      isPremium: true,
      availableAccentColors: [
        'starlight_silver',
        'cosmic_blue',
        'aurora_green',
      ],
    ),
    AppThemeConfig(
      id: 'earth_wisdom',
      name: 'Earth Wisdom',
      description: 'Grounding earth tones with forest greens and warm browns',
      previewImageUrl: 'assets/images/themes/earth_preview.png',
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      isPremium: true,
      availableAccentColors: ['forest_green', 'autumn_gold', 'clay_red'],
    ),
    AppThemeConfig(
      id: 'rose_quartz',
      name: 'Rose Quartz Serenity',
      description: 'Soft pinks and warm whites for heart-centered readings',
      previewImageUrl: 'assets/images/themes/rose_quartz_preview.png',
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      isPremium: true,
      availableAccentColors: ['rose_pink', 'pearl_white', 'soft_coral'],
    ),
  ];

  // Mock card back configurations
  static final List<CardBackConfig> _mockCardBacks = [
    CardBackConfig(
      id: 'classic',
      name: 'Classic Lunanul',
      description: 'The original card back design with crescent moon',
      imageUrl: 'assets/images/card_backs/classic.png',
      thumbnailUrl: 'assets/images/card_backs/classic_thumb.png',
      isPremium: false,
      style: CardBackStyle.traditional,
    ),
    CardBackConfig(
      id: 'celestial_mandala',
      name: 'Celestial Mandala',
      description: 'Intricate mandala design with star patterns',
      imageUrl: 'assets/images/card_backs/celestial_mandala.png',
      thumbnailUrl: 'assets/images/card_backs/celestial_mandala_thumb.png',
      isPremium: true,
      style: CardBackStyle.mystical,
    ),
    CardBackConfig(
      id: 'minimalist_moon',
      name: 'Minimalist Moon',
      description: 'Clean, simple design with subtle moon phases',
      imageUrl: 'assets/images/card_backs/minimalist_moon.png',
      thumbnailUrl: 'assets/images/card_backs/minimalist_moon_thumb.png',
      isPremium: true,
      style: CardBackStyle.minimalist,
    ),
    CardBackConfig(
      id: 'ornate_baroque',
      name: 'Ornate Baroque',
      description: 'Elaborate baroque-inspired design with gold accents',
      imageUrl: 'assets/images/card_backs/ornate_baroque.png',
      thumbnailUrl: 'assets/images/card_backs/ornate_baroque_thumb.png',
      isPremium: true,
      style: CardBackStyle.ornate,
    ),
  ];

  // Mock accent color configurations
  static final List<AccentColorConfig> _mockAccentColors = [
    AccentColorConfig(
      id: 'mystical_purple',
      name: 'Mystical Purple',
      primaryColor: const Color(0xFF6B46C1),
      secondaryColor: const Color(0xFF9333EA),
      accentColor: const Color(0xFFDDD6FE),
      isPremium: false,
    ),
    AccentColorConfig(
      id: 'golden_hour',
      name: 'Golden Hour',
      primaryColor: const Color(0xFFD97706),
      secondaryColor: const Color(0xFFF59E0B),
      accentColor: const Color(0xFFFEF3C7),
      isPremium: true,
    ),
    AccentColorConfig(
      id: 'moonlight_blue',
      name: 'Moonlight Blue',
      primaryColor: const Color(0xFF1E40AF),
      secondaryColor: const Color(0xFF3B82F6),
      accentColor: const Color(0xFFDBEAFE),
      isPremium: true,
    ),
    AccentColorConfig(
      id: 'rose_pink',
      name: 'Rose Pink',
      primaryColor: const Color(0xFFBE185D),
      secondaryColor: const Color(0xFFEC4899),
      accentColor: const Color(0xFFFCE7F3),
      isPremium: true,
    ),
  ];

  // Mock animation configurations
  static final List<AnimationConfig> _mockAnimations = [
    AnimationConfig(
      id: 'gentle',
      name: 'Gentle Flow',
      description: 'Soft, calming animations that maintain tranquility',
      cardFlipDuration: const Duration(milliseconds: 800),
      transitionDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeInOut,
      enableParticleEffects: false,
      isPremium: false,
    ),
    AnimationConfig(
      id: 'mystical',
      name: 'Mystical Essence',
      description: 'Ethereal animations with subtle particle effects',
      cardFlipDuration: const Duration(milliseconds: 1000),
      transitionDuration: const Duration(milliseconds: 500),
      animationCurve: Curves.easeInOutCubic,
      enableParticleEffects: true,
      isPremium: true,
    ),
    AnimationConfig(
      id: 'swift',
      name: 'Swift Clarity',
      description: 'Quick, responsive animations for efficient readings',
      cardFlipDuration: const Duration(milliseconds: 400),
      transitionDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeOut,
      enableParticleEffects: false,
      isPremium: true,
    ),
  ];

  @override
  Future<List<AppThemeConfig>> getAvailableThemes() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    return List.from(_mockThemes);
  }

  @override
  Future<AppThemeConfig?> getCurrentTheme() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockThemes.firstWhere(
      (theme) => theme.id == _currentThemeId,
      orElse: () => _mockThemes.first,
    );
  }

  @override
  Future<bool> setTheme(String themeId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    // Check if theme exists
    final themeExists = _mockThemes.any((theme) => theme.id == themeId);
    if (!themeExists) {
      throw const CustomizationException(
        message: 'Theme not found',
        error: CustomizationError.themeNotFound,
      );
    }

    // Simulate occasional failures
    if (_random.nextDouble() < 0.05) {
      throw const CustomizationException(
        message: 'Failed to apply theme',
        error: CustomizationError.storageError,
      );
    }

    _currentThemeId = themeId;
    return true;
  }

  @override
  Future<List<CardBackConfig>> getAvailableCardBacks() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    return List.from(_mockCardBacks);
  }

  @override
  Future<CardBackConfig?> getCurrentCardBack() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockCardBacks.firstWhere(
      (cardBack) => cardBack.id == _currentCardBackId,
      orElse: () => _mockCardBacks.first,
    );
  }

  @override
  Future<bool> setCardBack(String cardBackId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    final cardBackExists = _mockCardBacks.any(
      (cardBack) => cardBack.id == cardBackId,
    );
    if (!cardBackExists) {
      throw const CustomizationException(
        message: 'Card back not found',
        error: CustomizationError.cardBackNotFound,
      );
    }

    _currentCardBackId = cardBackId;
    return true;
  }

  @override
  Future<List<AccentColorConfig>> getAvailableAccentColors({
    String? themeId,
  }) async {
    await Future.delayed(Duration(milliseconds: 80 + _random.nextInt(120)));

    // Filter colors based on theme if specified
    if (themeId != null) {
      final theme = _mockThemes.firstWhere(
        (t) => t.id == themeId,
        orElse: () => _mockThemes.first,
      );
      return _mockAccentColors
          .where((color) => theme.availableAccentColors.contains(color.id))
          .toList();
    }

    return List.from(_mockAccentColors);
  }

  @override
  Future<bool> setAccentColor(String colorId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    final colorExists = _mockAccentColors.any((color) => color.id == colorId);
    if (!colorExists) {
      return false;
    }

    _currentAccentColorId = colorId;
    return true;
  }

  @override
  Future<List<AnimationConfig>> getAvailableAnimations() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    return List.from(_mockAnimations);
  }

  @override
  Future<bool> setAnimationStyle(String animationId) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    final animationExists = _mockAnimations.any(
      (anim) => anim.id == animationId,
    );
    if (!animationExists) {
      return false;
    }

    _currentAnimationId = animationId;
    return true;
  }

  @override
  Future<String?> createCustomTheme({
    required String name,
    required String baseTheme,
    required Map<String, dynamic> customizations,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Validate base theme exists
    final baseThemeExists = _mockThemes.any((theme) => theme.id == baseTheme);
    if (!baseThemeExists) {
      throw const CustomizationException(
        message: 'Base theme not found',
        error: CustomizationError.themeNotFound,
      );
    }

    // Simulate quota limits
    if (_random.nextDouble() < 0.1) {
      throw const CustomizationException(
        message: 'Custom theme quota exceeded',
        error: CustomizationError.quotaExceeded,
      );
    }

    // Generate a custom theme ID
    final customThemeId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    // In a real implementation, this would create and store the custom theme
    return customThemeId;
  }

  @override
  Future<bool> saveCustomizationSettings() async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(200)));

    // Simulate occasional storage failures
    if (_random.nextDouble() < 0.02) {
      throw const CustomizationException(
        message: 'Failed to save customization settings',
        error: CustomizationError.storageError,
      );
    }

    return true;
  }

  @override
  Future<bool> restoreCustomizationSettings() async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(200)));

    // Simulate restoring settings
    _currentThemeId = 'default';
    _currentCardBackId = 'classic';
    _currentAccentColorId = 'mystical_purple';
    _currentAnimationId = 'gentle';

    return true;
  }

  @override
  Future<bool> resetToDefaults() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    _currentThemeId = 'default';
    _currentCardBackId = 'classic';
    _currentAccentColorId = 'mystical_purple';
    _currentAnimationId = 'gentle';

    return true;
  }

  @override
  bool isCustomizationAvailable(CustomizationFeature feature) {
    // Mock availability based on feature type
    switch (feature) {
      case CustomizationFeature.themes:
      case CustomizationFeature.cardBacks:
        return true; // Always available for Oracle tier
      case CustomizationFeature.accentColors:
      case CustomizationFeature.animations:
        return true;
      case CustomizationFeature.customThemes:
        return true; // Premium feature
      case CustomizationFeature.particleEffects:
        return true; // Advanced premium feature
    }
  }

  /// Gets the current accent color configuration
  Future<AccentColorConfig?> getCurrentAccentColor() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockAccentColors.firstWhere(
      (color) => color.id == _currentAccentColorId,
      orElse: () => _mockAccentColors.first,
    );
  }

  /// Gets the current animation configuration
  Future<AnimationConfig?> getCurrentAnimation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _mockAnimations.firstWhere(
      (anim) => anim.id == _currentAnimationId,
      orElse: () => _mockAnimations.first,
    );
  }

  /// Simulates theme preview generation
  Future<String> generateThemePreview(String themeId) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    return 'mock://preview/theme_${themeId}_${DateTime.now().millisecondsSinceEpoch}.png';
  }

  /// Clears all customization cache (useful for testing)
  void clearCache() {
    // In a real implementation, this would clear cached themes, colors, etc.
  }
}
