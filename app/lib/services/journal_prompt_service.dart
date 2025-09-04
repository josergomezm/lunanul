import '../models/enums.dart';

/// Service interface for generating personalized journal prompts based on tarot readings
/// This is an Oracle tier premium feature that creates contextual reflection questions
abstract class JournalPromptService {
  /// Generates personalized journal prompts based on a single card reading
  ///
  /// [cardName] - The name of the tarot card drawn
  /// [position] - The position/meaning of the card in the reading (optional)
  /// [userContext] - Additional context about the user's situation (optional)
  ///
  /// Returns a list of personalized reflection questions
  Future<List<String>> generateCardPrompts({
    required String cardName,
    String? position,
    String? userContext,
  });

  /// Generates journal prompts for a multi-card spread reading
  ///
  /// [cards] - List of card names in the spread
  /// [spreadType] - The type of spread that was performed
  /// [cardPositions] - Map of card names to their positions in the spread
  /// [overallTheme] - The overall theme or message of the reading
  /// [userQuestion] - The question the user asked (if any)
  ///
  /// Returns a list of comprehensive reflection questions
  Future<List<String>> generateSpreadPrompts({
    required List<String> cards,
    required SpreadType spreadType,
    required Map<String, String> cardPositions,
    String? overallTheme,
    String? userQuestion,
  });

  /// Generates follow-up prompts based on previous readings and journal entries
  ///
  /// [previousCards] - Cards from recent readings
  /// [journalEntries] - Previous journal entries for context
  /// [timeframe] - How far back to look for patterns (in days)
  ///
  /// Returns prompts that help identify patterns and growth
  Future<List<String>> generateFollowUpPrompts({
    required List<String> previousCards,
    List<String>? journalEntries,
    int timeframe = 30,
  });

  /// Generates seasonal or themed prompts for regular reflection
  ///
  /// [season] - Current season or time period
  /// [theme] - Specific theme for reflection (growth, relationships, etc.)
  ///
  /// Returns general prompts for ongoing self-reflection
  Future<List<String>> generateThematicPrompts({
    String? season,
    ReflectionTheme? theme,
  });

  /// Gets prompt suggestions based on card archetypes and meanings
  ///
  /// [cardArchetype] - The archetype of the card (Major/Minor Arcana, suit, etc.)
  /// [cardMeaning] - The traditional meaning of the card
  ///
  /// Returns prompts tailored to the card's symbolic meaning
  List<String> getArchetypePrompts({
    required CardArchetype cardArchetype,
    required String cardMeaning,
  });

  /// Validates and filters prompts for appropriateness and relevance
  ///
  /// [prompts] - List of generated prompts to validate
  /// [userPreferences] - User preferences for prompt style and content
  ///
  /// Returns filtered and validated prompts
  Future<List<String>> validatePrompts({
    required List<String> prompts,
    JournalPromptPreferences? userPreferences,
  });
}

/// Themes for reflection prompts
enum ReflectionTheme {
  personalGrowth,
  relationships,
  career,
  spirituality,
  creativity,
  healing,
  manifestation,
  shadowWork,
}

/// Card archetypes for prompt generation
enum CardArchetype { majorArcana, cups, wands, swords, pentacles, court }

/// User preferences for journal prompts
class JournalPromptPreferences {
  final PromptStyle style;
  final int maxPromptsPerReading;
  final bool includeActionItems;
  final bool includeReflectionQuestions;
  final List<ReflectionTheme> preferredThemes;
  final PromptComplexity complexity;

  const JournalPromptPreferences({
    this.style = PromptStyle.gentle,
    this.maxPromptsPerReading = 3,
    this.includeActionItems = true,
    this.includeReflectionQuestions = true,
    this.preferredThemes = const [],
    this.complexity = PromptComplexity.moderate,
  });
}

/// Style of journal prompts
enum PromptStyle { gentle, direct, poetic, analytical, spiritual }

/// Complexity level of prompts
enum PromptComplexity { simple, moderate, deep }

/// Exception thrown when prompt generation fails
class JournalPromptException implements Exception {
  final String message;
  final JournalPromptError error;
  final dynamic originalError;

  const JournalPromptException({
    required this.message,
    required this.error,
    this.originalError,
  });

  @override
  String toString() => 'JournalPromptException: $message';
}

/// Types of journal prompt errors
enum JournalPromptError {
  networkError,
  invalidCard,
  quotaExceeded,
  serviceUnavailable,
  contentFiltered,
  invalidPreferences,
}
