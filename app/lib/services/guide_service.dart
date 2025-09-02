import 'dart:math';
import 'dart:ui';
import '../models/tarot_card.dart';
import '../models/tarot_guide.dart';
import '../models/enums.dart';
import '../services/guide_localizations.dart';
import '../l10n/generated/app_localizations.dart';

/// Service for managing tarot guides and generating guide-specific interpretations
class GuideService {
  static final GuideService _instance = GuideService._internal();
  factory GuideService() => _instance;
  GuideService._internal();

  /// Random number generator for interpretation variation
  final Random _random = Random();

  /// Guide localization service
  final GuideLocalizations _guideLocalizations = GuideLocalizations();

  /// Static guide data with all four guide personalities and their characteristics
  static final List<TarotGuide> _allGuides = [
    TarotGuide.createDefault(GuideType.sage),
    TarotGuide.createDefault(GuideType.healer),
    TarotGuide.createDefault(GuideType.mentor),
    TarotGuide.createDefault(GuideType.visionary),
  ];

  /// Get all available guides
  List<TarotGuide> getAllGuides() {
    return List.unmodifiable(_allGuides);
  }

  /// Get all localized guides
  List<TarotGuide> getLocalizedGuides(AppLocalizations localizations) {
    return _guideLocalizations.getLocalizedGuides(localizations);
  }

  /// Get a specific guide by type
  TarotGuide? getGuideByType(GuideType type) {
    try {
      return _allGuides.firstWhere((guide) => guide.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Get guide recommendations based on reading topic
  List<GuideType> getRecommendedGuides(ReadingTopic topic) {
    return GuideType.getRecommendedForTopic(topic);
  }

  /// Get the most recommended guide for a specific topic
  GuideType? getBestGuideForTopic(ReadingTopic topic) {
    final recommended = getRecommendedGuides(topic);
    return recommended.isNotEmpty ? recommended.first : null;
  }

  /// Generate guide-specific interpretation for a tarot card
  String generateInterpretation(
    TarotCard card,
    GuideType guideType,
    ReadingTopic topic, {
    String? position,
  }) {
    final guide = getGuideByType(guideType);
    if (guide == null) {
      return _generateFallbackInterpretation(card, topic);
    }

    final template = _getInterpretationTemplate(guideType, topic);
    final cardMeaning = card.currentMeaning;
    final keywords = card.effectiveKeywords;

    return _buildInterpretation(
      template: template,
      card: card,
      cardMeaning: cardMeaning,
      keywords: keywords,
      guide: guide,
      topic: topic,
      position: position,
    );
  }

  /// Generate localized guide-specific interpretation for a tarot card
  Future<String> generateLocalizedInterpretation(
    TarotCard card,
    GuideType guideType,
    ReadingTopic topic,
    Locale locale, {
    String? position,
  }) async {
    final guide = getGuideByType(guideType);
    if (guide == null) {
      return _generateFallbackInterpretation(card, topic);
    }

    final template = await _guideLocalizations
        .getLocalizedInterpretationTemplate(guideType, topic, locale);
    final cardMeaning = card.currentMeaning;
    final keywords = card.effectiveKeywords;

    return _buildInterpretation(
      template: template,
      card: card,
      cardMeaning: cardMeaning,
      keywords: keywords,
      guide: guide,
      topic: topic,
      position: position,
    );
  }

  /// Get interpretation template for a specific guide and topic combination
  InterpretationTemplate _getInterpretationTemplate(
    GuideType guideType,
    ReadingTopic topic,
  ) {
    switch (guideType) {
      case GuideType.sage:
        return _getSageTemplate(topic);
      case GuideType.healer:
        return _getHealerTemplate(topic);
      case GuideType.mentor:
        return _getMentorTemplate(topic);
      case GuideType.visionary:
        return _getVisionaryTemplate(topic);
    }
  }

  /// Clear localization cache
  void clearLocalizationCache() {
    _guideLocalizations.clearCache();
  }

  /// Preload localized interpretation templates
  Future<void> preloadLocalizedTemplates() async {
    await _guideLocalizations.preloadAllInterpretationTemplates();
  }

  /// Build the complete interpretation using template and card data
  String _buildInterpretation({
    required InterpretationTemplate template,
    required TarotCard card,
    required String cardMeaning,
    required List<String> keywords,
    required TarotGuide guide,
    required ReadingTopic topic,
    String? position,
  }) {
    final buffer = StringBuffer();

    // Opening phrase with guide's voice
    buffer.write(template.openingPhrase);
    buffer.write(' ');

    // Card context with guide-specific language
    final cardContext = template.cardContextTemplate
        .replaceAll('{cardName}', card.effectiveName)
        .replaceAll('{keywords}', _formatKeywords(keywords))
        .replaceAll('{orientation}', card.isReversed ? 'reversed' : 'upright');

    if (position != null && position.isNotEmpty) {
      buffer.write(cardContext.replaceAll('{position}', position));
    } else {
      buffer.write(cardContext.replaceAll(' in the {position} position', ''));
    }
    buffer.write(' ');

    // Core meaning interpretation
    buffer.write(cardMeaning);
    buffer.write(' ');

    // Action advice with guide's approach
    final actionAdvice = template.actionAdviceTemplate.replaceAll(
      '{topicApproach}',
      guide.getTopicApproach(topic),
    );
    buffer.write(actionAdvice);
    buffer.write(' ');

    // Closing phrase
    buffer.write(template.closingPhrase);

    return buffer.toString();
  }

  /// Format keywords for natural language inclusion
  String _formatKeywords(List<String> keywords) {
    if (keywords.isEmpty) return '';
    if (keywords.length == 1) return keywords.first;
    if (keywords.length == 2) return '${keywords.first} and ${keywords.last}';

    final lastKeyword = keywords.last;
    final otherKeywords = keywords.take(keywords.length - 1).join(', ');
    return '$otherKeywords, and $lastKeyword';
  }

  /// Generate fallback interpretation when guide is not available
  String _generateFallbackInterpretation(TarotCard card, ReadingTopic topic) {
    return 'The ${card.effectiveName} speaks to themes of ${card.effectiveKeywords.take(3).join(", ")}. ${card.currentMeaning}';
  }
}

/// Extension methods for GuideService to handle interpretation templates
extension GuideServiceTemplates on GuideService {
  /// Get Sage (Zian) interpretation templates
  InterpretationTemplate _getSageTemplate(ReadingTopic topic) {
    final openingPhrases = [
      'The universe speaks through ${_getRandomElement(_sageOpenings)}',
      'In the cosmic tapestry, ${_getRandomElement(_sageOpenings)}',
      'The ancient wisdom reveals ${_getRandomElement(_sageOpenings)}',
    ];

    final contextTemplates = [
      'The {cardName} {orientation} carries the energy of {keywords}',
      'Through {cardName}, the cosmos shows you the path of {keywords}',
      'The spiritual essence of {cardName} illuminates {keywords}',
    ];

    final actionTemplates = [
      'Align yourself with {topicApproach} and trust in the universal flow.',
      'Meditate on {topicApproach} to unlock deeper understanding.',
      'The stars guide you toward {topicApproach} with divine timing.',
    ];

    final closingPhrases = [
      'Trust in the wisdom of the universe.',
      'All is unfolding as it should in the grand design.',
      'The cosmic forces are aligning for your highest good.',
    ];

    return InterpretationTemplate(
      guide: GuideType.sage,
      openingPhrase: _getRandomElement(openingPhrases),
      cardContextTemplate: _getRandomElement(contextTemplates),
      actionAdviceTemplate: _getRandomElement(actionTemplates),
      closingPhrase: _getRandomElement(closingPhrases),
    );
  }

  /// Get Healer (Lyra) interpretation templates
  InterpretationTemplate _getHealerTemplate(ReadingTopic topic) {
    final openingPhrases = [
      'Your heart knows the truth, and ${_getRandomElement(_healerOpenings)}',
      'With gentle compassion, ${_getRandomElement(_healerOpenings)}',
      'Trust in your inner healing wisdom as ${_getRandomElement(_healerOpenings)}',
    ];

    final contextTemplates = [
      'The {cardName} {orientation} offers healing through {keywords}',
      'Embrace the gentle message of {cardName} and its gift of {keywords}',
      'Your soul is ready to receive the nurturing energy of {cardName} and {keywords}',
    ];

    final actionTemplates = [
      'Be gentle with yourself as you explore {topicApproach}.',
      'Honor your emotions and allow {topicApproach} to unfold naturally.',
      'Practice self-compassion while embracing {topicApproach}.',
    ];

    final closingPhrases = [
      'You are worthy of love and healing.',
      'Trust in your ability to heal and grow.',
      'Your heart holds infinite wisdom and strength.',
    ];

    return InterpretationTemplate(
      guide: GuideType.healer,
      openingPhrase: _getRandomElement(openingPhrases),
      cardContextTemplate: _getRandomElement(contextTemplates),
      actionAdviceTemplate: _getRandomElement(actionTemplates),
      closingPhrase: _getRandomElement(closingPhrases),
    );
  }

  /// Get Mentor (Kael) interpretation templates
  InterpretationTemplate _getMentorTemplate(ReadingTopic topic) {
    final openingPhrases = [
      'The practical path forward is clear: ${_getRandomElement(_mentorOpenings)}',
      'Focus your energy and attention because ${_getRandomElement(_mentorOpenings)}',
      'Take decisive action as ${_getRandomElement(_mentorOpenings)}',
    ];

    final contextTemplates = [
      'The {cardName} {orientation} provides concrete guidance through {keywords}',
      'Analyze the message of {cardName} and apply its lessons of {keywords}',
      'The strategic insight of {cardName} points to {keywords} as your focus',
    ];

    final actionTemplates = [
      'Create a clear plan for {topicApproach} and execute it step by step.',
      'Channel your efforts toward {topicApproach} with determination.',
      'Set specific goals related to {topicApproach} and take immediate action.',
    ];

    final closingPhrases = [
      'Success comes through consistent, focused effort.',
      'You have the skills and determination to achieve your goals.',
      'Take the first step today—momentum builds with action.',
    ];

    return InterpretationTemplate(
      guide: GuideType.mentor,
      openingPhrase: _getRandomElement(openingPhrases),
      cardContextTemplate: _getRandomElement(contextTemplates),
      actionAdviceTemplate: _getRandomElement(actionTemplates),
      closingPhrase: _getRandomElement(closingPhrases),
    );
  }

  /// Get Visionary (Elara) interpretation templates
  InterpretationTemplate _getVisionaryTemplate(ReadingTopic topic) {
    final openingPhrases = [
      'Imagine the possibilities as ${_getRandomElement(_visionaryOpenings)}',
      'Your creative spirit is awakening because ${_getRandomElement(_visionaryOpenings)}',
      'New horizons are calling as ${_getRandomElement(_visionaryOpenings)}',
    ];

    final contextTemplates = [
      'The {cardName} {orientation} sparks inspiration through {keywords}',
      'Envision the potential that {cardName} reveals through {keywords}',
      'The creative energy of {cardName} illuminates new possibilities in {keywords}',
    ];

    final actionTemplates = [
      'Explore the creative potential within {topicApproach} without limits.',
      'Dream boldly about {topicApproach} and let inspiration guide you.',
      'Embrace innovation and fresh perspectives in {topicApproach}.',
    ];

    final closingPhrases = [
      'The universe is conspiring to help you create something beautiful.',
      'Your imagination is your greatest tool for transformation.',
      'Trust in the magic of new beginnings and endless possibilities.',
    ];

    return InterpretationTemplate(
      guide: GuideType.visionary,
      openingPhrase: _getRandomElement(openingPhrases),
      cardContextTemplate: _getRandomElement(contextTemplates),
      actionAdviceTemplate: _getRandomElement(actionTemplates),
      closingPhrase: _getRandomElement(closingPhrases),
    );
  }

  /// Get random element from a list
  T _getRandomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  /// Sage opening variations
  List<String> get _sageOpenings => [
    'this card emerges from the depths of universal consciousness',
    'the eternal patterns reveal themselves',
    'the cosmic wheel turns to show you this truth',
    'ancient energies align to bring you this message',
  ];

  /// Healer opening variations
  List<String> get _healerOpenings => [
    'this card offers gentle guidance for your journey',
    'your inner healer recognizes this wisdom',
    'this message comes with love and understanding',
    'your heart is ready to receive this healing',
  ];

  /// Mentor opening variations
  List<String> get _mentorOpenings => [
    'this card provides the strategic insight you need',
    'the solution becomes clear through this guidance',
    'this practical wisdom will serve you well',
    'the path to success is illuminated here',
  ];

  /// Visionary opening variations
  List<String> get _visionaryOpenings => [
    'this card opens doorways to new possibilities',
    'creative inspiration flows through this message',
    'your potential is expanding through this revelation',
    'innovation and breakthrough await in this guidance',
  ];
}

/// Data class for interpretation templates
class InterpretationTemplate {
  final GuideType guide;
  final String openingPhrase;
  final String cardContextTemplate;
  final String actionAdviceTemplate;
  final String closingPhrase;

  const InterpretationTemplate({
    required this.guide,
    required this.openingPhrase,
    required this.cardContextTemplate,
    required this.actionAdviceTemplate,
    required this.closingPhrase,
  });

  @override
  String toString() {
    return 'InterpretationTemplate(guide: ${guide.name})';
  }
}
