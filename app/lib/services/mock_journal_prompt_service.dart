import 'dart:math';
import '../models/enums.dart';
import 'journal_prompt_service.dart';

/// Mock implementation of JournalPromptService for development and testing
class MockJournalPromptService implements JournalPromptService {
  final Random _random = Random();

  // Mock prompt templates organized by card types and themes
  static const Map<String, List<String>> _cardPrompts = {
    'The Fool': [
      'What new journey are you ready to embark upon with childlike wonder?',
      'How can you embrace beginner\'s mind in your current situation?',
      'What leap of faith is calling to you right now?',
    ],
    'The Tower': [
      'What structure in your life feels unstable but needs to fall away for new growth?',
      'How can you find stability within yourself during times of upheaval?',
      'What beliefs or patterns are ready to be released?',
    ],
    'The Star': [
      'What hopes and dreams are guiding you forward?',
      'How can you trust in the healing process you\'re experiencing?',
      'What inspiration is flowing through you right now?',
    ],
    'Death': [
      'What aspect of your life is ready for transformation?',
      'How can you honor what you\'re releasing while welcoming what\'s emerging?',
      'What new version of yourself is being born?',
    ],
  };

  static const Map<ReflectionTheme, List<String>> _thematicPrompts = {
    ReflectionTheme.personalGrowth: [
      'What patterns in your life are you ready to transform?',
      'How have you grown since this time last year?',
      'What aspect of yourself deserves more compassion?',
    ],
    ReflectionTheme.relationships: [
      'How can you show up more authentically in your relationships?',
      'What boundaries do you need to establish or strengthen?',
      'How do you want to be loved and supported?',
    ],
    ReflectionTheme.spirituality: [
      'How do you connect with the sacred in your daily life?',
      'What spiritual practices bring you the most peace?',
      'How can you deepen your relationship with your intuition?',
    ],
  };

  static const List<String> _followUpPrompts = [
    'Looking at your recent readings, what themes keep appearing?',
    'How have the messages from your cards manifested in your life?',
    'What patterns do you notice in your spiritual journey?',
    'How has your relationship with tarot evolved recently?',
  ];

  @override
  Future<List<String>> generateCardPrompts({
    required String cardName,
    String? position,
    String? userContext,
  }) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    // Get specific prompts for the card if available
    List<String> prompts = List.from(_cardPrompts[cardName] ?? []);

    // Add position-specific prompts if position is provided
    if (position != null) {
      prompts.addAll(_generatePositionPrompts(cardName, position));
    }

    // Add context-specific prompts if user context is provided
    if (userContext != null && userContext.isNotEmpty) {
      prompts.addAll(_generateContextualPrompts(cardName, userContext));
    }

    // If no specific prompts found, generate generic ones
    if (prompts.isEmpty) {
      prompts = _generateGenericCardPrompts(cardName);
    }

    // Shuffle and return up to 3 prompts
    prompts.shuffle(_random);
    return prompts.take(3).toList();
  }

  @override
  Future<List<String>> generateSpreadPrompts({
    required List<String> cards,
    required SpreadType spreadType,
    required Map<String, String> cardPositions,
    String? overallTheme,
    String? userQuestion,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    List<String> prompts = [];

    // Add spread-specific prompts
    prompts.addAll(_generateSpreadSpecificPrompts(spreadType, cards));

    // Add theme-based prompts if theme is identified
    if (overallTheme != null) {
      prompts.addAll(_generateThemePrompts(overallTheme));
    }

    // Add question-related prompts if user asked a question
    if (userQuestion != null && userQuestion.isNotEmpty) {
      prompts.addAll(_generateQuestionPrompts(userQuestion, cards));
    }

    // Add integration prompts for multiple cards
    prompts.addAll(_generateIntegrationPrompts(cards));

    prompts.shuffle(_random);
    return prompts.take(4).toList();
  }

  @override
  Future<List<String>> generateFollowUpPrompts({
    required List<String> previousCards,
    List<String>? journalEntries,
    int timeframe = 30,
  }) async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(250)));

    List<String> prompts = List.from(_followUpPrompts);

    // Add pattern-based prompts
    if (previousCards.length > 3) {
      prompts.addAll(_generatePatternPrompts(previousCards));
    }

    // Add journal-based prompts if entries are provided
    if (journalEntries != null && journalEntries.isNotEmpty) {
      prompts.addAll(_generateJournalReflectionPrompts(journalEntries));
    }

    prompts.shuffle(_random);
    return prompts.take(3).toList();
  }

  @override
  Future<List<String>> generateThematicPrompts({
    String? season,
    ReflectionTheme? theme,
  }) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));

    List<String> prompts = [];

    // Add theme-specific prompts
    if (theme != null && _thematicPrompts.containsKey(theme)) {
      prompts.addAll(_thematicPrompts[theme]!);
    }

    // Add seasonal prompts
    if (season != null) {
      prompts.addAll(_generateSeasonalPrompts(season));
    }

    // Add general reflection prompts if nothing specific
    if (prompts.isEmpty) {
      prompts = [
        'What is your heart calling you to explore today?',
        'How can you honor your authentic self in this moment?',
        'What wisdom is emerging from your recent experiences?',
      ];
    }

    prompts.shuffle(_random);
    return prompts.take(3).toList();
  }

  @override
  List<String> getArchetypePrompts({
    required CardArchetype cardArchetype,
    required String cardMeaning,
  }) {
    switch (cardArchetype) {
      case CardArchetype.majorArcana:
        return [
          'What major life lesson is this card highlighting for you?',
          'How does this archetypal energy show up in your life?',
          'What spiritual growth is this card inviting you to embrace?',
        ];
      case CardArchetype.cups:
        return [
          'How are your emotions guiding you right now?',
          'What does your heart need for healing and nourishment?',
          'How can you deepen your emotional connections?',
        ];
      case CardArchetype.wands:
        return [
          'What creative fire is burning within you?',
          'How can you channel your passion into meaningful action?',
          'What inspires you to keep moving forward?',
        ];
      case CardArchetype.swords:
        return [
          'What mental patterns or thoughts need your attention?',
          'How can you communicate your truth more clearly?',
          'What decisions are you being called to make?',
        ];
      case CardArchetype.pentacles:
        return [
          'How can you ground your dreams into practical reality?',
          'What resources do you have available to support your goals?',
          'How do you want to manifest abundance in your life?',
        ];
      case CardArchetype.court:
        return [
          'What qualities of this court card do you embody?',
          'How can you develop the positive aspects of this personality?',
          'What role are you being called to play in your current situation?',
        ];
    }
  }

  @override
  Future<List<String>> validatePrompts({
    required List<String> prompts,
    JournalPromptPreferences? userPreferences,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));

    List<String> validatedPrompts = List.from(prompts);

    // Apply user preferences if provided
    if (userPreferences != null) {
      // Filter by complexity
      if (userPreferences.complexity == PromptComplexity.simple) {
        validatedPrompts = validatedPrompts
            .where((prompt) => prompt.split(' ').length <= 15)
            .toList();
      }

      // Limit number of prompts
      if (validatedPrompts.length > userPreferences.maxPromptsPerReading) {
        validatedPrompts = validatedPrompts
            .take(userPreferences.maxPromptsPerReading)
            .toList();
      }

      // Filter by style (mock implementation)
      validatedPrompts = _applyStyleFilter(
        validatedPrompts,
        userPreferences.style,
      );
    }

    return validatedPrompts;
  }

  List<String> _generatePositionPrompts(String cardName, String position) {
    return [
      'How does $cardName in the $position position speak to your current situation?',
      'What message does this card have for you in the context of $position?',
    ];
  }

  List<String> _generateContextualPrompts(String cardName, String userContext) {
    return [
      'How does $cardName relate to your situation with $userContext?',
      'What guidance does this card offer regarding $userContext?',
    ];
  }

  List<String> _generateGenericCardPrompts(String cardName) {
    return [
      'What does $cardName mean to you in this moment?',
      'How can you embody the energy of $cardName today?',
      'What lesson is $cardName teaching you?',
    ];
  }

  List<String> _generateSpreadSpecificPrompts(
    SpreadType spreadType,
    List<String> cards,
  ) {
    switch (spreadType) {
      case SpreadType.threeCard:
        return [
          'How do these three cards work together to tell your story?',
          'What progression do you see from past to present to future?',
        ];
      case SpreadType.celtic:
        return [
          'What is the central theme emerging from this comprehensive reading?',
          'How do the different aspects of your life connect in this spread?',
        ];
      default:
        return [
          'What overall message do these cards have for you?',
          'How do all the cards in this spread relate to each other?',
        ];
    }
  }

  List<String> _generateThemePrompts(String theme) {
    return [
      'How does the theme of $theme show up in your life right now?',
      'What action can you take to honor this theme of $theme?',
    ];
  }

  List<String> _generateQuestionPrompts(String question, List<String> cards) {
    return [
      'How do these cards answer your question: "$question"?',
      'What additional insights do these cards offer beyond your original question?',
    ];
  }

  List<String> _generateIntegrationPrompts(List<String> cards) {
    return [
      'How can you integrate the wisdom from all these cards into your daily life?',
      'What common thread connects all the cards in your reading?',
    ];
  }

  List<String> _generatePatternPrompts(List<String> previousCards) {
    return [
      'What patterns do you notice in your recent card draws?',
      'Which cards have appeared multiple times, and what might they be trying to tell you?',
    ];
  }

  List<String> _generateJournalReflectionPrompts(List<String> journalEntries) {
    return [
      'Looking back at your recent journal entries, what growth do you notice?',
      'How have your insights evolved since your last reflection?',
    ];
  }

  List<String> _generateSeasonalPrompts(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return [
          'What new growth is emerging in your life this spring?',
          'How can you plant seeds for your future self?',
        ];
      case 'summer':
        return [
          'How can you fully embrace the abundance of this season?',
          'What is flourishing in your life right now?',
        ];
      case 'autumn':
      case 'fall':
        return [
          'What are you ready to release as the season changes?',
          'How can you harvest the wisdom from your recent experiences?',
        ];
      case 'winter':
        return [
          'How can you find warmth and light during this introspective season?',
          'What inner work is calling for your attention?',
        ];
      default:
        return [
          'How does the current season reflect your inner landscape?',
          'What seasonal wisdom can guide you forward?',
        ];
    }
  }

  List<String> _applyStyleFilter(List<String> prompts, PromptStyle style) {
    // Mock style filtering - in a real implementation, this would use NLP
    switch (style) {
      case PromptStyle.gentle:
        return prompts
            .where(
              (prompt) =>
                  !prompt.contains('challenge') && !prompt.contains('confront'),
            )
            .toList();
      case PromptStyle.direct:
        return prompts; // Return all prompts for direct style
      case PromptStyle.poetic:
        return prompts
            .where(
              (prompt) =>
                  prompt.contains('heart') ||
                  prompt.contains('soul') ||
                  prompt.contains('spirit'),
            )
            .toList();
      case PromptStyle.analytical:
        return prompts
            .where(
              (prompt) =>
                  prompt.contains('pattern') ||
                  prompt.contains('analyze') ||
                  prompt.contains('examine'),
            )
            .toList();
      case PromptStyle.spiritual:
        return prompts
            .where(
              (prompt) =>
                  prompt.contains('sacred') ||
                  prompt.contains('divine') ||
                  prompt.contains('spiritual'),
            )
            .toList();
    }
  }
}
