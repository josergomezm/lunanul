import 'enums.dart';

/// Defines what features and capabilities are available for a subscription tier
class FeatureAccess {
  const FeatureAccess({
    required this.hasUnlimitedReadings,
    required this.availableSpreads,
    required this.availableGuides,
    required this.maxReadings,
    required this.maxManualInterpretations,
    required this.isAdFree,
    required this.hasAudioReadings,
    required this.hasAdvancedSpreads,
    required this.hasCustomization,
    required this.hasEarlyAccess,
    this.customFeatures = const {},
  });

  /// Whether the user has unlimited access to AI readings
  final bool hasUnlimitedReadings;

  /// List of spread types available to this tier
  final List<SpreadType> availableSpreads;

  /// List of guide types available to this tier
  final List<GuideType> availableGuides;

  /// Maximum number of readings per month (0 = unlimited)
  final int maxReadings;

  /// Maximum manual interpretations per month (0 = unlimited)
  final int maxManualInterpretations;

  /// Whether ads are disabled for this tier
  final bool isAdFree;

  /// Whether AI-generated audio readings are available
  final bool hasAudioReadings;

  /// Whether advanced/specialized spreads are available
  final bool hasAdvancedSpreads;

  /// Whether customization options (themes, card backs) are available
  final bool hasCustomization;

  /// Whether early access to new features is available
  final bool hasEarlyAccess;

  /// Additional custom features specific to this tier
  final Map<String, bool> customFeatures;

  /// Check if a specific spread type is available
  bool canAccessSpread(SpreadType spread) {
    return availableSpreads.contains(spread);
  }

  /// Check if a specific guide is available
  bool canAccessGuide(GuideType guide) {
    return availableGuides.contains(guide);
  }

  /// Check if readings are unlimited
  bool get hasUnlimitedReadingsAccess => maxReadings == 0;

  /// Check if manual interpretations are unlimited
  bool get hasUnlimitedManualInterpretations => maxManualInterpretations == 0;

  /// Check if a custom feature is enabled
  bool hasCustomFeature(String featureKey) {
    return customFeatures[featureKey] ?? false;
  }

  /// Create a copy with updated values
  FeatureAccess copyWith({
    bool? hasUnlimitedReadings,
    List<SpreadType>? availableSpreads,
    List<GuideType>? availableGuides,
    int? maxReadings,
    int? maxManualInterpretations,
    bool? isAdFree,
    bool? hasAudioReadings,
    bool? hasAdvancedSpreads,
    bool? hasCustomization,
    bool? hasEarlyAccess,
    Map<String, bool>? customFeatures,
  }) {
    return FeatureAccess(
      hasUnlimitedReadings: hasUnlimitedReadings ?? this.hasUnlimitedReadings,
      availableSpreads: availableSpreads ?? this.availableSpreads,
      availableGuides: availableGuides ?? this.availableGuides,
      maxReadings: maxReadings ?? this.maxReadings,
      maxManualInterpretations:
          maxManualInterpretations ?? this.maxManualInterpretations,
      isAdFree: isAdFree ?? this.isAdFree,
      hasAudioReadings: hasAudioReadings ?? this.hasAudioReadings,
      hasAdvancedSpreads: hasAdvancedSpreads ?? this.hasAdvancedSpreads,
      hasCustomization: hasCustomization ?? this.hasCustomization,
      hasEarlyAccess: hasEarlyAccess ?? this.hasEarlyAccess,
      customFeatures: customFeatures ?? this.customFeatures,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'hasUnlimitedReadings': hasUnlimitedReadings,
      'availableSpreads': availableSpreads.map((s) => s.name).toList(),
      'availableGuides': availableGuides.map((g) => g.name).toList(),
      'maxReadings': maxReadings,
      'maxManualInterpretations': maxManualInterpretations,
      'isAdFree': isAdFree,
      'hasAudioReadings': hasAudioReadings,
      'hasAdvancedSpreads': hasAdvancedSpreads,
      'hasCustomization': hasCustomization,
      'hasEarlyAccess': hasEarlyAccess,
      'customFeatures': customFeatures,
    };
  }

  /// Create from JSON
  factory FeatureAccess.fromJson(Map<String, dynamic> json) {
    return FeatureAccess(
      hasUnlimitedReadings: json['hasUnlimitedReadings'] as bool,
      availableSpreads: (json['availableSpreads'] as List<dynamic>)
          .map((s) => SpreadType.fromString(s as String))
          .toList(),
      availableGuides: (json['availableGuides'] as List<dynamic>)
          .map((g) => GuideType.fromString(g as String))
          .toList(),
      maxReadings: json['maxReadings'] as int,
      maxManualInterpretations: json['maxManualInterpretations'] as int,
      isAdFree: json['isAdFree'] as bool,
      hasAudioReadings: json['hasAudioReadings'] as bool,
      hasAdvancedSpreads: json['hasAdvancedSpreads'] as bool,
      hasCustomization: json['hasCustomization'] as bool,
      hasEarlyAccess: json['hasEarlyAccess'] as bool,
      customFeatures: Map<String, bool>.from(
        json['customFeatures'] as Map? ?? {},
      ),
    );
  }

  /// Create feature access for Seeker (free) tier
  factory FeatureAccess.seeker() {
    return const FeatureAccess(
      hasUnlimitedReadings: false,
      availableSpreads: [SpreadType.singleCard, SpreadType.threeCard],
      availableGuides: [GuideType.healer, GuideType.mentor],
      maxReadings: 3,
      maxManualInterpretations: 5,
      isAdFree: false,
      hasAudioReadings: false,
      hasAdvancedSpreads: false,
      hasCustomization: false,
      hasEarlyAccess: false,
    );
  }

  /// Create feature access for Mystic (core subscription) tier
  factory FeatureAccess.mystic() {
    return const FeatureAccess(
      hasUnlimitedReadings: true,
      availableSpreads: SpreadType.values,
      availableGuides: GuideType.values,
      maxReadings: 0, // unlimited
      maxManualInterpretations: 0, // unlimited
      isAdFree: true,
      hasAudioReadings: false,
      hasAdvancedSpreads: false,
      hasCustomization: false,
      hasEarlyAccess: false,
    );
  }

  /// Create feature access for Oracle (premium) tier
  factory FeatureAccess.oracle() {
    return const FeatureAccess(
      hasUnlimitedReadings: true,
      availableSpreads: SpreadType.values,
      availableGuides: GuideType.values,
      maxReadings: 0, // unlimited
      maxManualInterpretations: 0, // unlimited
      isAdFree: true,
      hasAudioReadings: true,
      hasAdvancedSpreads: true,
      hasCustomization: true,
      hasEarlyAccess: true,
    );
  }

  /// Get feature access for a specific subscription tier
  factory FeatureAccess.forTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return FeatureAccess.seeker();
      case SubscriptionTier.mystic:
        return FeatureAccess.mystic();
      case SubscriptionTier.oracle:
        return FeatureAccess.oracle();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureAccess &&
        other.hasUnlimitedReadings == hasUnlimitedReadings &&
        other.maxReadings == maxReadings &&
        other.maxManualInterpretations == maxManualInterpretations &&
        other.isAdFree == isAdFree &&
        other.hasAudioReadings == hasAudioReadings &&
        other.hasAdvancedSpreads == hasAdvancedSpreads &&
        other.hasCustomization == hasCustomization &&
        other.hasEarlyAccess == hasEarlyAccess;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasUnlimitedReadings,
      maxReadings,
      maxManualInterpretations,
      isAdFree,
      hasAudioReadings,
      hasAdvancedSpreads,
      hasCustomization,
      hasEarlyAccess,
    );
  }

  @override
  String toString() {
    return 'FeatureAccess(unlimited: $hasUnlimitedReadings, '
        'spreads: ${availableSpreads.length}, guides: ${availableGuides.length}, '
        'adFree: $isAdFree)';
  }
}
