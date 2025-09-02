import 'dart:math';
import '../models/manual_interpretation.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import 'mock_reading_service.dart';

/// Service for managing manual interpretations
class ManualInterpretationService {
  static ManualInterpretationService? _instance;
  static ManualInterpretationService get instance =>
      _instance ??= ManualInterpretationService._();
  ManualInterpretationService._();

  final List<ManualInterpretation> _savedInterpretations = [];
  final MockReadingService _readingService = MockReadingService.instance;

  /// Generate contextual interpretation for a card based on topic and position
  Future<String> generateInterpretation({
    required TarotCard card,
    required ReadingTopic topic,
    required String positionName,
    GuideType? selectedGuide,
  }) async {
    // Use guide-specific interpretation if a guide is selected
    if (selectedGuide != null) {
      return await _readingService.generateManualInterpretation(
        card: card,
        topic: topic,
        position: positionName,
        selectedGuide: selectedGuide,
      );
    }

    // Fallback to original interpretation logic if no guide selected
    await Future.delayed(const Duration(milliseconds: 800));

    final baseMeaning = card.currentMeaning;
    final topicContext = _getTopicContext(topic);
    final positionContext = _getPositionContext(positionName);

    // Generate contextual interpretation
    final interpretation = _buildContextualInterpretation(
      card: card,
      baseMeaning: baseMeaning,
      topicContext: topicContext,
      positionContext: positionContext,
    );

    return interpretation;
  }

  /// Get suggested position names based on number of cards
  List<String> getSuggestedPositions(int cardCount) {
    switch (cardCount) {
      case 1:
        return ['Current Situation'];
      case 2:
        return ['Challenge', 'Guidance'];
      case 3:
        return ['Past/Foundation', 'Present/Focus', 'Future/Outcome'];
      case 4:
        return ['Situation', 'Challenge', 'Action', 'Outcome'];
      case 5:
        return ['Past', 'Present', 'Future', 'Action', 'Outcome'];
      default:
        return List.generate(cardCount, (index) => 'Position ${index + 1}');
    }
  }

  /// Analyze connections between selected cards
  List<CardConnection> analyzeCardConnections(List<ManualCardPosition> cards) {
    final connections = <CardConnection>[];

    for (int i = 0; i < cards.length; i++) {
      for (int j = i + 1; j < cards.length; j++) {
        final card1 = cards[i];
        final card2 = cards[j];

        final connection = _findConnection(card1, card2);
        if (connection != null) {
          connections.add(connection);
        }
      }
    }

    return connections;
  }

  /// Save a manual interpretation
  Future<void> saveInterpretation(ManualInterpretation interpretation) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final existingIndex = _savedInterpretations.indexWhere(
      (i) => i.id == interpretation.id,
    );
    if (existingIndex >= 0) {
      _savedInterpretations[existingIndex] = interpretation.copyWith(
        isSaved: true,
      );
    } else {
      _savedInterpretations.add(interpretation.copyWith(isSaved: true));
    }
  }

  /// Get all saved interpretations
  Future<List<ManualInterpretation>> getSavedInterpretations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_savedInterpretations.where((i) => i.isSaved));
  }

  /// Delete a saved interpretation
  Future<void> deleteInterpretation(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedInterpretations.removeWhere((i) => i.id == id);
  }

  /// Get topic-specific context for interpretations
  String _getTopicContext(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return 'In the context of personal growth and self-reflection';
      case ReadingTopic.love:
        return 'In matters of the heart and relationships';
      case ReadingTopic.work:
        return 'Regarding your career and professional life';
      case ReadingTopic.social:
        return 'In your social connections and friendships';
    }
  }

  /// Get position-specific context
  String _getPositionContext(String positionName) {
    final lowerPosition = positionName.toLowerCase();

    if (lowerPosition.contains('past') ||
        lowerPosition.contains('foundation')) {
      return 'representing the foundation or past influences';
    } else if (lowerPosition.contains('present') ||
        lowerPosition.contains('current')) {
      return 'showing your current situation or focus';
    } else if (lowerPosition.contains('future') ||
        lowerPosition.contains('outcome')) {
      return 'indicating potential outcomes or future direction';
    } else if (lowerPosition.contains('challenge') ||
        lowerPosition.contains('obstacle')) {
      return 'highlighting challenges or obstacles to consider';
    } else if (lowerPosition.contains('action') ||
        lowerPosition.contains('advice')) {
      return 'suggesting actions or advice to consider';
    } else if (lowerPosition.contains('guidance') ||
        lowerPosition.contains('wisdom')) {
      return 'offering guidance and wisdom';
    } else {
      return 'in this position';
    }
  }

  /// Build contextual interpretation combining all elements
  String _buildContextualInterpretation({
    required TarotCard card,
    required String baseMeaning,
    required String topicContext,
    required String positionContext,
  }) {
    final interpretations = [
      '$topicContext, ${card.displayName} $positionContext suggests $baseMeaning',
      'The ${card.name}${card.isReversed ? ' reversed' : ''} $positionContext indicates $baseMeaning $topicContext.',
      '$topicContext, this card $positionContext reveals $baseMeaning',
    ];

    // Add card-specific insights
    final keywords = card.keywords.take(3).join(', ');
    final keywordInsight = 'Key themes include: $keywords.';

    final selectedInterpretation =
        interpretations[Random().nextInt(interpretations.length)];

    return '$selectedInterpretation $keywordInsight';
  }

  /// Find connections between two cards
  CardConnection? _findConnection(
    ManualCardPosition card1,
    ManualCardPosition card2,
  ) {
    final connections = <String>[];

    // Same suit connection
    if (card1.card.suit == card2.card.suit) {
      connections.add(
        'Both cards share the ${card1.card.suit.displayName} suit, suggesting a unified theme around ${card1.card.suit.description.toLowerCase()}.',
      );
    }

    // Major Arcana connection
    if (card1.card.isMajorArcana && card2.card.isMajorArcana) {
      connections.add(
        'Both Major Arcana cards indicate significant spiritual or life lessons at play.',
      );
    }

    // Reversed cards connection
    if (card1.card.isReversed && card2.card.isReversed) {
      connections.add(
        'Both reversed cards suggest internal reflection or blocked energy that needs attention.',
      );
    }

    // Keyword connections
    final sharedKeywords = card1.card.keywords
        .where(
          (k1) => card2.card.keywords.any(
            (k2) => k1.toLowerCase() == k2.toLowerCase(),
          ),
        )
        .toList();

    if (sharedKeywords.isNotEmpty) {
      connections.add(
        'These cards share themes of ${sharedKeywords.join(', ')}, reinforcing their combined message.',
      );
    }

    if (connections.isEmpty) return null;

    return CardConnection(
      card1: card1,
      card2: card2,
      connectionType: _getConnectionType(card1, card2),
      description: connections.join(' '),
    );
  }

  /// Determine the type of connection between cards
  ConnectionType _getConnectionType(
    ManualCardPosition card1,
    ManualCardPosition card2,
  ) {
    if (card1.card.suit == card2.card.suit) {
      return ConnectionType.suit;
    } else if (card1.card.isMajorArcana && card2.card.isMajorArcana) {
      return ConnectionType.majorArcana;
    } else if (card1.card.isReversed && card2.card.isReversed) {
      return ConnectionType.reversed;
    } else {
      return ConnectionType.thematic;
    }
  }
}

/// Represents a connection between two cards in a manual interpretation
class CardConnection {
  final ManualCardPosition card1;
  final ManualCardPosition card2;
  final ConnectionType connectionType;
  final String description;

  const CardConnection({
    required this.card1,
    required this.card2,
    required this.connectionType,
    required this.description,
  });
}

/// Types of connections between cards
enum ConnectionType {
  suit('Suit Connection'),
  majorArcana('Major Arcana Connection'),
  reversed('Reversed Energy Connection'),
  thematic('Thematic Connection');

  const ConnectionType(this.displayName);
  final String displayName;
}
