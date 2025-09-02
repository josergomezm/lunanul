import 'dart:convert';
import 'enums.dart';

/// Represents the personality traits and voice characteristics of a tarot guide
class GuidePersonality {
  final GuideType guideType;
  final String voiceTone;
  final List<String> vocabularyStyle;
  final String focusArea;
  final Map<String, String> samplePhrases;
  final Map<ReadingTopic, String> topicApproach;

  const GuidePersonality({
    required this.guideType,
    required this.voiceTone,
    required this.vocabularyStyle,
    required this.focusArea,
    required this.samplePhrases,
    required this.topicApproach,
  });

  /// Create a copy of this personality with some properties changed
  GuidePersonality copyWith({
    GuideType? guideType,
    String? voiceTone,
    List<String>? vocabularyStyle,
    String? focusArea,
    Map<String, String>? samplePhrases,
    Map<ReadingTopic, String>? topicApproach,
  }) {
    return GuidePersonality(
      guideType: guideType ?? this.guideType,
      voiceTone: voiceTone ?? this.voiceTone,
      vocabularyStyle: vocabularyStyle ?? this.vocabularyStyle,
      focusArea: focusArea ?? this.focusArea,
      samplePhrases: samplePhrases ?? this.samplePhrases,
      topicApproach: topicApproach ?? this.topicApproach,
    );
  }

  /// Get the approach for a specific reading topic
  String getTopicApproach(ReadingTopic topic) {
    return topicApproach[topic] ?? focusArea;
  }

  /// Get a sample phrase for a specific context
  String getSamplePhrase(String context) {
    return samplePhrases[context] ?? samplePhrases['default'] ?? '';
  }

  /// Check if this personality is suitable for a given topic
  bool isSuitableForTopic(ReadingTopic topic) {
    final recommended = GuideType.getRecommendedForTopic(topic);
    return recommended.contains(guideType);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'guideType': guideType.name,
      'voiceTone': voiceTone,
      'vocabularyStyle': vocabularyStyle,
      'focusArea': focusArea,
      'samplePhrases': samplePhrases,
      'topicApproach': topicApproach.map(
        (key, value) => MapEntry(key.name, value),
      ),
    };
  }

  /// Create from JSON
  factory GuidePersonality.fromJson(Map<String, dynamic> json) {
    final topicApproachMap = <ReadingTopic, String>{};
    if (json['topicApproach'] != null) {
      final topicApproachJson = json['topicApproach'] as Map<String, dynamic>;
      for (final entry in topicApproachJson.entries) {
        final topic = ReadingTopic.fromString(entry.key);
        topicApproachMap[topic] = entry.value as String;
      }
    }

    return GuidePersonality(
      guideType: GuideType.fromString(json['guideType'] as String),
      voiceTone: json['voiceTone'] as String,
      vocabularyStyle: List<String>.from(json['vocabularyStyle'] as List),
      focusArea: json['focusArea'] as String,
      samplePhrases: Map<String, String>.from(json['samplePhrases'] as Map),
      topicApproach: topicApproachMap,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory GuidePersonality.fromJsonString(String jsonString) {
    return GuidePersonality.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuidePersonality && other.guideType == guideType;
  }

  @override
  int get hashCode => guideType.hashCode;

  @override
  String toString() {
    return 'GuidePersonality(guideType: ${guideType.name}, voiceTone: $voiceTone)';
  }

  /// Factory method to create default personalities for each guide type
  static GuidePersonality createDefault(GuideType guideType) {
    switch (guideType) {
      case GuideType.sage:
        return GuidePersonality(
          guideType: GuideType.sage,
          voiceTone: 'calm, profound, esoteric',
          vocabularyStyle: [
            'metaphors',
            'universal energies',
            'cosmic wisdom',
            'spiritual insights',
          ],
          focusArea: 'Deep spiritual insight and karmic patterns',
          samplePhrases: {
            'opening': 'The universe speaks through this card...',
            'reflection': 'This reflects the cosmic dance of...',
            'guidance': 'The ancient wisdom suggests...',
            'default': 'In the grand tapestry of existence...',
          },
          topicApproach: {
            ReadingTopic.self:
                'Exploring your soul\'s journey and higher purpose',
            ReadingTopic.love:
                'Understanding the karmic connections in relationships',
            ReadingTopic.work: 'Aligning your career with your spiritual path',
            ReadingTopic.social:
                'Seeing the deeper patterns in human connections',
          },
        );

      case GuideType.healer:
        return GuidePersonality(
          guideType: GuideType.healer,
          voiceTone: 'gentle, affirming, emotionally supportive',
          vocabularyStyle: [
            'nurturing language',
            'emotional validation',
            'healing metaphors',
            'self-compassion',
          ],
          focusArea: 'Emotional healing and self-compassion',
          samplePhrases: {
            'opening': 'Your heart knows the truth...',
            'reflection': 'Be gentle with yourself as...',
            'guidance': 'Trust in your inner healing wisdom...',
            'default': 'You are worthy of love and understanding...',
          },
          topicApproach: {
            ReadingTopic.self:
                'Nurturing your emotional well-being and self-love',
            ReadingTopic.love:
                'Healing relationship wounds and opening your heart',
            ReadingTopic.work:
                'Finding emotional balance in your professional life',
            ReadingTopic.social:
                'Healing social anxieties and building healthy boundaries',
          },
        );

      case GuideType.mentor:
        return GuidePersonality(
          guideType: GuideType.mentor,
          voiceTone: 'clear, direct, action-oriented',
          vocabularyStyle: [
            'practical steps',
            'actionable advice',
            'real-world implications',
            'strategic thinking',
          ],
          focusArea: 'Clear guidance and actionable advice',
          samplePhrases: {
            'opening': 'The practical step forward is...',
            'reflection': 'Focus your energy on...',
            'guidance': 'Take concrete action by...',
            'default': 'Here\'s what you need to do...',
          },
          topicApproach: {
            ReadingTopic.self:
                'Building practical skills for personal development',
            ReadingTopic.love:
                'Taking clear steps to improve your relationships',
            ReadingTopic.work:
                'Strategic career planning and professional growth',
            ReadingTopic.social:
                'Developing effective communication and leadership skills',
          },
        );

      case GuideType.visionary:
        return GuidePersonality(
          guideType: GuideType.visionary,
          voiceTone: 'inspiring, expansive, creative',
          vocabularyStyle: [
            'possibility language',
            'creative metaphors',
            'visionary concepts',
            'potential exploration',
          ],
          focusArea: 'Inspiration and creative possibilities',
          samplePhrases: {
            'opening': 'Imagine if...',
            'reflection': 'What new possibility is calling...',
            'guidance': 'Your creative spirit is ready to...',
            'default': 'The universe is conspiring to help you create...',
          },
          topicApproach: {
            ReadingTopic.self: 'Discovering your untapped creative potential',
            ReadingTopic.love: 'Envisioning new possibilities in relationships',
            ReadingTopic.work: 'Unleashing innovation and creative solutions',
            ReadingTopic.social:
                'Inspiring others and building creative communities',
          },
        );
    }
  }
}
