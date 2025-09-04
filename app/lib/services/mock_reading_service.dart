import 'dart:math';
import '../models/reading.dart';
import '../models/card_position.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import 'card_service.dart';
import 'guide_service.dart';

/// Mock service for generating AI-powered tarot readings with realistic interpretations
class MockReadingService {
  static MockReadingService? _instance;
  static MockReadingService get instance =>
      _instance ??= MockReadingService._();
  MockReadingService._();

  final CardService _cardService = CardService.instance;
  final GuideService _guideService = GuideService();
  final Random _random = Random();

  /// Create a new reading with AI-generated interpretations
  Future<Reading> createReading({
    required ReadingTopic topic,
    required SpreadType spreadType,
    String? customTitle,
    GuideType? selectedGuide,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    final cards = await _cardService.drawCards(
      spreadType.cardCount,
      allowReversed: true,
      allowDuplicates: false,
    );

    final cardPositions = <CardPosition>[];
    final positionNames = _getPositionNames(spreadType);

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final positionName = positionNames[i];
      final aiInterpretation = await _generateAIInterpretation(
        card: card,
        position: positionName,
        topic: topic,
        spreadType: spreadType,
        selectedGuide: selectedGuide,
      );

      cardPositions.add(
        CardPosition(
          card: card,
          positionName: positionName,
          positionMeaning: _getPositionMeaning(positionName, spreadType),
          aiInterpretation: aiInterpretation,
          order: i,
        ),
      );
    }

    return Reading(
      id: _generateReadingId(),
      createdAt: DateTime.now(),
      topic: topic,
      spreadType: spreadType,
      cards: cardPositions,
      title: customTitle,
      selectedGuide: selectedGuide,
      isSaved: false,
    );
  }

  /// Generate AI interpretation for a card in a specific position and context
  Future<String> _generateAIInterpretation({
    required TarotCard card,
    required String position,
    required ReadingTopic topic,
    required SpreadType spreadType,
    GuideType? selectedGuide,
  }) async {
    // Simulate AI processing time
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Use guide-specific interpretation if a guide is selected
    if (selectedGuide != null) {
      return _guideService.generateInterpretation(
        card,
        selectedGuide,
        topic,
        position: position,
      );
    }

    // Fallback to original interpretation logic if no guide selected
    final baseInterpretation = card.currentMeaning;
    final contextualElements = _getContextualElements(
      topic,
      position,
      spreadType,
    );
    final personalizedTouch = _getPersonalizedTouch(card, topic);

    return _combineInterpretation(
      baseInterpretation: baseInterpretation,
      contextualElements: contextualElements,
      personalizedTouch: personalizedTouch,
      card: card,
      position: position,
    );
  }

  /// Get position meaning for a specific position in a spread
  String _getPositionMeaning(String positionName, SpreadType spreadType) {
    final meanings = <String, String>{
      // Single Card
      'Your Guidance':
          'This card offers guidance and insight for your current situation.',

      // Three Card
      'Past/Situation':
          'This represents the foundation or past influences affecting your current situation.',
      'Present/Action':
          'This shows what you need to focus on or the action to take in the present moment.',
      'Future/Outcome':
          'This indicates the likely outcome or future direction based on current energies.',

      // Celtic Cross
      'Present Situation':
          'This represents your current circumstances and the energy surrounding you now.',
      'Challenge/Cross':
          'This shows the challenge or obstacle you are facing, or what crosses your path.',
      'Distant Past/Foundation':
          'This represents the foundation of the situation or distant past influences.',
      'Recent Past':
          'This shows recent events or influences that have led to the current situation.',
      'Possible Outcome':
          'This indicates a possible outcome if things continue on their current path.',
      'Near Future':
          'This shows what is likely to happen in the immediate future.',
      'Your Approach':
          'This represents your approach to the situation or how you see yourself.',
      'External Influences':
          'This shows external factors and how others see you or influence the situation.',
      'Hopes and Fears':
          'This represents your inner hopes and fears about the situation.',
      'Final Outcome':
          'This indicates the final outcome or resolution of the situation.',

      // Relationship
      'You':
          'This represents your energy, feelings, and approach in the relationship.',
      'Your Partner':
          'This represents your partner\'s energy, feelings, and approach.',
      'The Relationship':
          'This shows the current state and energy of the relationship itself.',
      'What You Bring':
          'This represents what you contribute to the relationship.',
      'What They Bring':
          'This represents what your partner contributes to the relationship.',

      // Career
      'Current Situation':
          'This represents your current professional situation and work environment.',
      'Hidden Influences':
          'This shows hidden factors or behind-the-scenes influences affecting your career.',
      'Your Skills':
          'This represents your talents, abilities, and what you bring to your work.',
      'Challenges':
          'This shows the obstacles or challenges you face in your professional life.',
      'Opportunities':
          'This indicates opportunities available to you in your career path.',
      'Action to Take':
          'This suggests the action you should take to advance your career goals.',
      'Outcome':
          'This shows the likely outcome of your career situation and efforts.',
    };

    return meanings[positionName] ??
        'This position offers insight into your situation.';
  }

  /// Get position names for different spread types
  List<String> _getPositionNames(SpreadType spreadType) {
    switch (spreadType) {
      case SpreadType.singleCard:
        return ['Your Guidance'];

      case SpreadType.threeCard:
        return ['Past/Situation', 'Present/Action', 'Future/Outcome'];

      case SpreadType.celtic:
        return [
          'Present Situation',
          'Challenge/Cross',
          'Distant Past/Foundation',
          'Recent Past',
          'Possible Outcome',
          'Near Future',
          'Your Approach',
          'External Influences',
          'Hopes and Fears',
          'Final Outcome',
        ];

      case SpreadType.relationship:
        return [
          'You',
          'Your Partner',
          'The Relationship',
          'What You Bring',
          'What They Bring',
        ];

      case SpreadType.career:
        return [
          'Current Situation',
          'Hidden Influences',
          'Your Skills',
          'Challenges',
          'Opportunities',
          'Action to Take',
          'Outcome',
        ];

      case SpreadType.celticCross:
        return [
          'Present Situation',
          'Challenge/Cross',
          'Distant Past/Foundation',
          'Recent Past',
          'Possible Outcome',
          'Near Future',
          'Your Approach',
          'External Influences',
          'Hopes and Fears',
          'Final Outcome',
        ];

      case SpreadType.horseshoe:
        return [
          'Past',
          'Present',
          'Hidden Influences',
          'Obstacles',
          'Possible Outcome',
          'Action to Take',
          'Final Result',
        ];
    }
  }

  /// Get contextual elements based on topic and position
  List<String> _getContextualElements(
    ReadingTopic topic,
    String position,
    SpreadType spreadType,
  ) {
    final elements = <String>[];

    // Topic-specific contexts
    switch (topic) {
      case ReadingTopic.self:
        elements.addAll([
          'personal growth',
          'inner wisdom',
          'self-reflection',
          'spiritual journey',
          'authentic self',
        ]);
        break;

      case ReadingTopic.love:
        elements.addAll([
          'romantic connection',
          'emotional bonds',
          'heart matters',
          'relationship dynamics',
          'love energy',
        ]);
        break;

      case ReadingTopic.work:
        elements.addAll([
          'career path',
          'professional growth',
          'workplace dynamics',
          'financial stability',
          'ambition',
        ]);
        break;

      case ReadingTopic.social:
        elements.addAll([
          'friendships',
          'social connections',
          'community',
          'communication',
          'social harmony',
        ]);
        break;
    }

    // Position-specific contexts
    if (position.toLowerCase().contains('past')) {
      elements.addAll([
        'foundation',
        'lessons learned',
        'previous experiences',
      ]);
    } else if (position.toLowerCase().contains('present')) {
      elements.addAll(['current energy', 'immediate focus', 'present moment']);
    } else if (position.toLowerCase().contains('future')) {
      elements.addAll([
        'potential outcome',
        'upcoming opportunities',
        'path ahead',
      ]);
    }

    return elements;
  }

  /// Get personalized touch based on card and topic
  String _getPersonalizedTouch(TarotCard card, ReadingTopic topic) {
    final touches = <String>[];

    // Card-specific personalization
    if (card.isMajorArcana) {
      touches.addAll([
        'This is a significant spiritual lesson',
        'The universe is guiding you through an important phase',
        'This represents a major life theme',
        'Pay special attention to this powerful energy',
      ]);
    } else {
      touches.addAll([
        'This reflects your daily experience',
        'Focus on the practical aspects of this message',
        'This energy is within your control',
        'Small steps can lead to big changes',
      ]);
    }

    // Topic-specific personalization
    switch (topic) {
      case ReadingTopic.self:
        touches.addAll([
          'Trust your inner voice',
          'You have the wisdom within you',
          'This is part of your personal journey',
        ]);
        break;

      case ReadingTopic.love:
        touches.addAll([
          'Open your heart to possibilities',
          'Love requires both giving and receiving',
          'Your emotional well-being matters',
        ]);
        break;

      case ReadingTopic.work:
        touches.addAll([
          'Your professional path is unfolding',
          'Success comes through dedication',
          'Balance ambition with well-being',
        ]);
        break;

      case ReadingTopic.social:
        touches.addAll([
          'Authentic connections bring joy',
          'Community support is available',
          'Your social energy affects others',
        ]);
        break;
    }

    return touches[_random.nextInt(touches.length)];
  }

  /// Combine all elements into a cohesive interpretation
  String _combineInterpretation({
    required String baseInterpretation,
    required List<String> contextualElements,
    required String personalizedTouch,
    required TarotCard card,
    required String position,
  }) {
    final interpretationParts = <String>[];

    // Start with position context
    interpretationParts.add('In the position of "$position", ');

    // Add card introduction
    if (card.isReversed) {
      interpretationParts.add('${card.name} appears reversed, suggesting ');
    } else {
      interpretationParts.add('${card.name} brings the energy of ');
    }

    // Add contextual meaning
    final selectedContext =
        contextualElements[_random.nextInt(contextualElements.length)];
    interpretationParts.add('$selectedContext. ');

    // Add base interpretation (shortened)
    final shortenedBase = _shortenInterpretation(baseInterpretation);
    interpretationParts.add('$shortenedBase ');

    // Add personalized guidance
    interpretationParts.add(personalizedTouch);

    return interpretationParts.join('');
  }

  /// Shorten the base interpretation to avoid overly long text
  String _shortenInterpretation(String interpretation) {
    final sentences = interpretation.split('. ');
    if (sentences.length <= 2) return interpretation;

    return '${sentences[0]}. ${sentences[1]}.';
  }

  /// Generate a unique reading ID
  String _generateReadingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(9999).toString().padLeft(4, '0');
    return 'reading_${timestamp}_$randomSuffix';
  }

  /// Get sample readings for different topics (for testing/demo)
  Future<List<Reading>> getSampleReadings() async {
    final sampleReadings = <Reading>[];

    for (final topic in ReadingTopic.values) {
      final reading = await createReading(
        topic: topic,
        spreadType: SpreadType.threeCard,
        customTitle: 'Sample ${topic.displayName} Reading',
      );
      sampleReadings.add(reading.copyWith(isSaved: true));
    }

    return sampleReadings;
  }

  /// Generate interpretation for manual card selection
  Future<String> generateManualInterpretation({
    required TarotCard card,
    required ReadingTopic topic,
    String? position,
    GuideType? selectedGuide,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    // Use guide-specific interpretation if a guide is selected
    if (selectedGuide != null) {
      return _guideService.generateInterpretation(
        card,
        selectedGuide,
        topic,
        position: position,
      );
    }

    // Fallback to original interpretation logic if no guide selected
    final contextualElements = _getContextualElements(
      topic,
      position ?? 'Your Card',
      SpreadType.singleCard,
    );

    final personalizedTouch = _getPersonalizedTouch(card, topic);

    return _combineInterpretation(
      baseInterpretation: card.currentMeaning,
      contextualElements: contextualElements,
      personalizedTouch: personalizedTouch,
      card: card,
      position: position ?? 'Your Card',
    );
  }

  /// Generate card connections for manual readings
  Future<List<String>> generateCardConnections(List<TarotCard> cards) async {
    if (cards.length < 2) return [];

    // Simulate AI processing delay
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    final connections = <String>[];

    // Analyze suit patterns
    final suits = cards.map((card) => card.suit).toSet();
    if (suits.length == 1) {
      final suit = suits.first;
      connections.add(
        'All cards share the ${suit.displayName} energy, suggesting a focused theme around ${suit.description.toLowerCase()}.',
      );
    }

    // Analyze Major vs Minor Arcana
    final majorCount = cards.where((card) => card.isMajorArcana).length;
    if (majorCount > cards.length / 2) {
      connections.add(
        'The presence of multiple Major Arcana cards indicates significant spiritual lessons and life themes at play.',
      );
    }

    // Analyze reversed cards
    final reversedCount = cards.where((card) => card.isReversed).length;
    if (reversedCount > 0) {
      connections.add(
        'The reversed cards suggest internal processing and the need to look within for answers.',
      );
    }

    // Add thematic connections based on keywords
    final allKeywords = cards.expand((card) => card.keywords).toList();
    final keywordCounts = <String, int>{};
    for (final keyword in allKeywords) {
      keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
    }

    final repeatedKeywords = keywordCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toList();

    if (repeatedKeywords.isNotEmpty) {
      final keyword = repeatedKeywords.first;
      connections.add(
        'The theme of "$keyword" appears multiple times, emphasizing its importance in your current situation.',
      );
    }

    return connections.take(3).toList(); // Limit to 3 connections
  }

  /// Generate daily affirmation based on card of the day
  Future<String> generateDailyAffirmation(TarotCard card) async {
    // Simulate AI processing delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final affirmations = <String>[];

    // Card-specific affirmations
    if (card.keywords.contains('new beginnings')) {
      affirmations.addAll([
        'I embrace new opportunities with an open heart.',
        'Today brings fresh possibilities for growth.',
        'I trust in the journey of new beginnings.',
      ]);
    }

    if (card.keywords.contains('love')) {
      affirmations.addAll([
        'I am worthy of love and connection.',
        'Love flows freely through my life.',
        'I open my heart to give and receive love.',
      ]);
    }

    if (card.keywords.contains('strength')) {
      affirmations.addAll([
        'I have the inner strength to overcome any challenge.',
        'My courage grows stronger with each step I take.',
        'I am resilient and capable of great things.',
      ]);
    }

    if (card.keywords.contains('wisdom')) {
      affirmations.addAll([
        'I trust my inner wisdom to guide me.',
        'Knowledge and understanding flow to me naturally.',
        'I make decisions from a place of clarity and insight.',
      ]);
    }

    // Default affirmations if no specific keywords match
    if (affirmations.isEmpty) {
      affirmations.addAll([
        'I am aligned with my highest good.',
        'Today I choose to see the beauty in every moment.',
        'I trust the process of life unfolding.',
        'I am exactly where I need to be.',
        'My path is illuminated with purpose and meaning.',
      ]);
    }

    return affirmations[_random.nextInt(affirmations.length)];
  }
}
