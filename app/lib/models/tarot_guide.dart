import 'dart:convert';
import 'package:flutter/material.dart';
import 'enums.dart';
import 'guide_personality.dart';

/// Represents a tarot guide with visual identity and personality traits
class TarotGuide {
  final GuideType type;
  final String name;
  final String title;
  final String description;
  final String expertise;
  final String iconPath;
  final Color primaryColor;
  final Color accentColor;
  final List<ReadingTopic> bestForTopics;
  final GuidePersonality personality;

  // Localized content (optional, used when localization is available)
  final String? localizedName;
  final String? localizedTitle;
  final String? localizedDescription;
  final String? localizedExpertise;

  const TarotGuide({
    required this.type,
    required this.name,
    required this.title,
    required this.description,
    required this.expertise,
    required this.iconPath,
    required this.primaryColor,
    required this.accentColor,
    required this.bestForTopics,
    required this.personality,
    this.localizedName,
    this.localizedTitle,
    this.localizedDescription,
    this.localizedExpertise,
  });

  /// Create a copy of this guide with some properties changed
  TarotGuide copyWith({
    GuideType? type,
    String? name,
    String? title,
    String? description,
    String? expertise,
    String? iconPath,
    Color? primaryColor,
    Color? accentColor,
    List<ReadingTopic>? bestForTopics,
    GuidePersonality? personality,
    String? localizedName,
    String? localizedTitle,
    String? localizedDescription,
    String? localizedExpertise,
  }) {
    return TarotGuide(
      type: type ?? this.type,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      expertise: expertise ?? this.expertise,
      iconPath: iconPath ?? this.iconPath,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      bestForTopics: bestForTopics ?? this.bestForTopics,
      personality: personality ?? this.personality,
      localizedName: localizedName ?? this.localizedName,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      localizedDescription: localizedDescription ?? this.localizedDescription,
      localizedExpertise: localizedExpertise ?? this.localizedExpertise,
    );
  }

  /// Get the effective name (localized if available, otherwise fallback to original)
  String get effectiveName => localizedName ?? name;

  /// Get the effective title (localized if available, otherwise fallback to original)
  String get effectiveTitle => localizedTitle ?? title;

  /// Get the effective description (localized if available, otherwise fallback to original)
  String get effectiveDescription => localizedDescription ?? description;

  /// Get the effective expertise (localized if available, otherwise fallback to original)
  String get effectiveExpertise => localizedExpertise ?? expertise;

  /// Get the full display name with title
  String get fullDisplayName => '$effectiveName, $effectiveTitle';

  /// Check if this guide is recommended for a specific topic
  bool isRecommendedForTopic(ReadingTopic topic) {
    return bestForTopics.contains(topic);
  }

  /// Get the guide's approach for a specific topic
  String getTopicApproach(ReadingTopic topic) {
    return personality.getTopicApproach(topic);
  }

  /// Get the appropriate icon for this guide type
  IconData get iconData {
    switch (type) {
      case GuideType.sage:
        return Icons.auto_awesome; // Constellation/interconnected pattern
      case GuideType.healer:
        return Icons.favorite; // Lotus/heart shape
      case GuideType.mentor:
        return Icons.trending_up; // Arrow/mountain peak
      case GuideType.visionary:
        return Icons.visibility; // Eye/nebula
    }
  }

  /// Create a localized version of this guide
  TarotGuide withLocalization({
    String? localizedName,
    String? localizedTitle,
    String? localizedDescription,
    String? localizedExpertise,
  }) {
    return copyWith(
      localizedName: localizedName,
      localizedTitle: localizedTitle,
      localizedDescription: localizedDescription,
      localizedExpertise: localizedExpertise,
    );
  }

  /// Check if this guide has localized content
  bool get hasLocalization {
    return localizedName != null ||
        localizedTitle != null ||
        localizedDescription != null ||
        localizedExpertise != null;
  }

  /// Validate guide data
  bool get isValid {
    return name.isNotEmpty &&
        title.isNotEmpty &&
        description.isNotEmpty &&
        expertise.isNotEmpty &&
        iconPath.isNotEmpty &&
        bestForTopics.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'title': title,
      'description': description,
      'expertise': expertise,
      'iconPath': iconPath,
      'primaryColor': primaryColor.toARGB32(),
      'accentColor': accentColor.toARGB32(),
      'bestForTopics': bestForTopics.map((topic) => topic.name).toList(),
      'personality': personality.toJson(),
      'localizedName': localizedName,
      'localizedTitle': localizedTitle,
      'localizedDescription': localizedDescription,
      'localizedExpertise': localizedExpertise,
    };
  }

  /// Create from JSON
  factory TarotGuide.fromJson(Map<String, dynamic> json) {
    return TarotGuide(
      type: GuideType.fromString(json['type'] as String),
      name: json['name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      expertise: json['expertise'] as String,
      iconPath: json['iconPath'] as String,
      primaryColor: Color(json['primaryColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      bestForTopics: (json['bestForTopics'] as List)
          .map((topic) => ReadingTopic.fromString(topic as String))
          .toList(),
      personality: GuidePersonality.fromJson(
        json['personality'] as Map<String, dynamic>,
      ),
      localizedName: json['localizedName'] as String?,
      localizedTitle: json['localizedTitle'] as String?,
      localizedDescription: json['localizedDescription'] as String?,
      localizedExpertise: json['localizedExpertise'] as String?,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory TarotGuide.fromJsonString(String jsonString) {
    return TarotGuide.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TarotGuide && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'TarotGuide(type: ${type.name}, name: $name, title: $title)';
  }

  /// Factory method to create default guides for each guide type
  static TarotGuide createDefault(GuideType guideType) {
    // Import GuideTheme for consistent colors
    final primaryColor = _getGuideThemePrimaryColor(guideType);
    final accentColor = _getGuideThemeAccentColor(guideType);

    switch (guideType) {
      case GuideType.sage:
        return TarotGuide(
          type: GuideType.sage,
          name: 'Zian',
          title: 'The Wise Mystic',
          description:
              'A profound guide who speaks in cosmic truths and universal wisdom, helping you understand the deeper spiritual patterns in your life.',
          expertise:
              'Deep spiritual insight, karmic patterns, and reconnecting with higher purpose',
          iconPath: 'assets/images/guide_zian.jpg',
          primaryColor: primaryColor,
          accentColor: accentColor,
          bestForTopics: [ReadingTopic.self, ReadingTopic.work],
          personality: GuidePersonality.createDefault(GuideType.sage),
        );

      case GuideType.healer:
        return TarotGuide(
          type: GuideType.healer,
          name: 'Lyra',
          title: 'The Compassionate Healer',
          description:
              'A gentle, nurturing guide who offers emotional support and healing wisdom, perfect for times when you need comfort and self-compassion.',
          expertise:
              'Emotional healing, self-care, navigating difficult emotions, and building self-love',
          iconPath: 'assets/images/guide_lyra.jpg',
          primaryColor: primaryColor,
          accentColor: accentColor,
          bestForTopics: [
            ReadingTopic.self,
            ReadingTopic.love,
            ReadingTopic.social,
          ],
          personality: GuidePersonality.createDefault(GuideType.healer),
        );

      case GuideType.mentor:
        return TarotGuide(
          type: GuideType.mentor,
          name: 'Kael',
          title: 'The Practical Strategist',
          description:
              'A clear, direct guide who provides actionable advice and practical solutions, ideal for career decisions and real-world challenges.',
          expertise:
              'Career guidance, practical decisions, strategic planning, and actionable steps',
          iconPath: 'assets/images/guide_kael.jpg',
          primaryColor: primaryColor,
          accentColor: accentColor,
          bestForTopics: [ReadingTopic.work, ReadingTopic.social],
          personality: GuidePersonality.createDefault(GuideType.mentor),
        );

      case GuideType.visionary:
        return TarotGuide(
          type: GuideType.visionary,
          name: 'Elara',
          title: 'The Creative Muse',
          description:
              'An inspiring guide who helps you explore possibilities and unlock your creative potential, perfect for overcoming blocks and envisioning new futures.',
          expertise:
              'Creative inspiration, exploring possibilities, overcoming blocks, and unlocking potential',
          iconPath: 'assets/images/guide_elara.jpg',
          primaryColor: primaryColor,
          accentColor: accentColor,
          bestForTopics: [ReadingTopic.love, ReadingTopic.self],
          personality: GuidePersonality.createDefault(GuideType.visionary),
        );
    }
  }

  /// Helper method to get primary color from GuideTheme
  static Color _getGuideThemePrimaryColor(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return const Color(0xFF6B46C1); // Deep purple
      case GuideType.healer:
        return const Color(0xFFEC4899); // Soft pink
      case GuideType.mentor:
        return const Color(0xFF2563EB); // Strong blue
      case GuideType.visionary:
        return const Color(0xFF8B5CF6); // Cosmic purple
    }
  }

  /// Helper method to get accent color from GuideTheme
  static Color _getGuideThemeAccentColor(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return const Color(0xFFF59E0B); // Gold
      case GuideType.healer:
        return const Color(0xFFFEF7FF); // Warm white
      case GuideType.mentor:
        return const Color(0xFFE5E7EB); // Silver
      case GuideType.visionary:
        return const Color(0xFFFBBF24); // Starlight gold
    }
  }

  /// Get all default guides
  static List<TarotGuide> getAllDefaultGuides() {
    return GuideType.values.map((type) => createDefault(type)).toList();
  }
}
