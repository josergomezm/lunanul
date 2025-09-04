import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

/// Service for managing localized dynamic content like journal prompts and topic descriptions
class DynamicContentLocalizations {
  static const String _englishPromptsPath =
      'assets/data/journal_prompts_en.json';
  static const String _spanishPromptsPath =
      'assets/data/journal_prompts_es.json';

  // Cache for loaded prompt data
  List<String>? _englishPrompts;
  List<String>? _spanishPrompts;

  // Random number generator for prompt selection
  final Random _random = Random();

  /// Loads and caches journal prompts for the specified locale
  Future<List<String>> _loadJournalPrompts(Locale locale) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        String assetPath;
        List<String>? cache;

        if (locale.languageCode == 'es') {
          assetPath = _spanishPromptsPath;
          cache = _spanishPrompts;
        } else {
          assetPath = _englishPromptsPath;
          cache = _englishPrompts;
        }

        // Return cached data if available
        if (cache != null) {
          return cache;
        }

        // Load from assets with error handling
        try {
          final String jsonString = await rootBundle.loadString(assetPath);
          final Map<String, dynamic> jsonData = json.decode(jsonString);

          // Validate that prompts data exists
          if (!jsonData.containsKey('prompts') ||
              jsonData['prompts'] is! List) {
            throw FormatException(
              'Invalid prompts data structure in $assetPath',
            );
          }

          // Extract prompts list with safe conversion
          final List<String> prompts = jsonData.safeGetStringList('prompts');

          // Validate that we have at least one prompt
          if (prompts.isEmpty) {
            throw FormatException('No prompts found in $assetPath');
          }

          // Cache the loaded data
          if (locale.languageCode == 'es') {
            _spanishPrompts = prompts;
          } else {
            _englishPrompts = prompts;
          }

          return prompts;
        } catch (e) {
          // Handle JSON parsing errors
          if (e is FormatException) {
            LocalizationErrorHandler.handleJsonParsingError(
              assetPath,
              e,
              context: 'DynamicContentLocalizations._loadJournalPrompts',
            );
          }
          rethrow;
        }
      },
      <String>[], // Fallback empty prompts list
      operationName: 'loadJournalPrompts',
      context: 'locale: ${locale.languageCode}',
    );
  }

  /// Gets a journal prompt by index
  /// Falls back to English if not found in the requested locale
  Future<String> getJournalPrompt(int index, Locale locale) async {
    const fallbackPrompt = 'What insights are emerging for you today?';

    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final prompts = await _loadJournalPrompts(locale);

        if (index >= 0 && index < prompts.length) {
          final prompt = prompts[index];
          if (prompt.isNotEmpty) {
            return prompt;
          }
        }

        // Fallback to English if index is out of range or prompt is empty
        if (locale.languageCode != 'en') {
          return await getJournalPrompt(index, const Locale('en'));
        }

        // Last resort fallback
        return fallbackPrompt;
      },
      fallbackPrompt, // Fallback value
      operationName: 'getJournalPrompt',
      context: 'index: $index, locale: ${locale.languageCode}',
    );
  }

  /// Gets a random journal prompt
  /// Falls back to English if not found in the requested locale
  Future<String> getRandomJournalPrompt(Locale locale) async {
    const fallbackPrompt = 'What insights are emerging for you today?';

    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final prompts = await _loadJournalPrompts(locale);

        if (prompts.isNotEmpty) {
          final randomIndex = _random.nextInt(prompts.length);
          final prompt = prompts[randomIndex];
          if (prompt.isNotEmpty) {
            return prompt;
          }
        }

        // Fallback to English if no prompts available or prompt is empty
        if (locale.languageCode != 'en') {
          return await getRandomJournalPrompt(const Locale('en'));
        }

        // Last resort fallback
        return fallbackPrompt;
      },
      fallbackPrompt, // Fallback value
      operationName: 'getRandomJournalPrompt',
      context: 'locale: ${locale.languageCode}',
    );
  }

  /// Gets the total number of available journal prompts for a locale
  Future<int> getJournalPromptCount(Locale locale) async {
    try {
      final prompts = await _loadJournalPrompts(locale);
      return prompts.length;
    } catch (e) {
      return 0;
    }
  }

  /// Gets all journal prompts for a locale
  Future<List<String>> getAllJournalPrompts(Locale locale) async {
    try {
      return await _loadJournalPrompts(locale);
    } catch (e) {
      return [];
    }
  }

  /// Gets localized topic description
  String getTopicDescription(ReadingTopic topic, Locale locale) {
    if (locale.languageCode == 'es') {
      switch (topic) {
        case ReadingTopic.self:
          return 'Crecimiento personal y autodescubrimiento';
        case ReadingTopic.love:
          return 'Relaciones y conexiones emocionales';
        case ReadingTopic.work:
          return 'Carrera y vida profesional';
        case ReadingTopic.social:
          return 'Comunidad e interacciones sociales';
      }
    } else {
      // Default to English
      switch (topic) {
        case ReadingTopic.self:
          return 'Personal growth and self-discovery';
        case ReadingTopic.love:
          return 'Relationships and emotional connections';
        case ReadingTopic.work:
          return 'Career and professional life';
        case ReadingTopic.social:
          return 'Community and social interactions';
      }
    }
  }

  /// Gets localized topic display name
  String getTopicDisplayName(ReadingTopic topic, Locale locale) {
    if (locale.languageCode == 'es') {
      switch (topic) {
        case ReadingTopic.self:
          return 'Yo';
        case ReadingTopic.love:
          return 'Amor';
        case ReadingTopic.work:
          return 'Trabajo';
        case ReadingTopic.social:
          return 'Social';
      }
    } else {
      // Default to English
      switch (topic) {
        case ReadingTopic.self:
          return 'Self';
        case ReadingTopic.love:
          return 'Love';
        case ReadingTopic.work:
          return 'Work';
        case ReadingTopic.social:
          return 'Social';
      }
    }
  }

  /// Gets localized spread description
  String getSpreadDescription(SpreadType spreadType, Locale locale) {
    if (locale.languageCode == 'es') {
      switch (spreadType) {
        case SpreadType.singleCard:
          return 'Perspectiva rápida para guía inmediata';
        case SpreadType.threeCard:
          return 'Pasado, Presente, Futuro o Situación, Acción, Resultado';
        case SpreadType.celtic:
        case SpreadType.celticCross:
          return 'Lectura completa para situaciones complejas';
        case SpreadType.horseshoe:
          return 'Tirada de siete cartas para guía y resultados';
        case SpreadType.relationship:
          return 'Enfocado en dinámicas de relación';
        case SpreadType.career:
          return 'Guía profesional y decisiones de carrera';
      }
    } else {
      // Default to English
      switch (spreadType) {
        case SpreadType.singleCard:
          return 'Quick insight for immediate guidance';
        case SpreadType.threeCard:
          return 'Past, Present, Future or Situation, Action, Outcome';
        case SpreadType.celtic:
        case SpreadType.celticCross:
          return 'Comprehensive reading for complex situations';
        case SpreadType.horseshoe:
          return 'Seven-card spread for guidance and outcomes';
        case SpreadType.relationship:
          return 'Focused on relationship dynamics';
        case SpreadType.career:
          return 'Professional guidance and career decisions';
      }
    }
  }

  /// Gets localized spread display name
  String getSpreadDisplayName(SpreadType spreadType, Locale locale) {
    if (locale.languageCode == 'es') {
      switch (spreadType) {
        case SpreadType.singleCard:
          return 'Una Carta';
        case SpreadType.threeCard:
          return 'Tres Cartas';
        case SpreadType.celtic:
        case SpreadType.celticCross:
          return 'Cruz Celta';
        case SpreadType.horseshoe:
          return 'Herradura';
        case SpreadType.relationship:
          return 'Relación';
        case SpreadType.career:
          return 'Camino Profesional';
      }
    } else {
      // Default to English
      switch (spreadType) {
        case SpreadType.singleCard:
          return 'Single Card';
        case SpreadType.threeCard:
          return 'Three Card';
        case SpreadType.celtic:
        case SpreadType.celticCross:
          return 'Celtic Cross';
        case SpreadType.horseshoe:
          return 'Horseshoe';
        case SpreadType.relationship:
          return 'Relationship';
        case SpreadType.career:
          return 'Career Path';
      }
    }
  }

  /// Gets localized tarot suit description
  String getTarotSuitDescription(TarotSuit suit, Locale locale) {
    if (locale.languageCode == 'es') {
      switch (suit) {
        case TarotSuit.majorArcana:
          return 'Los temas principales de la vida y lecciones espirituales';
        case TarotSuit.cups:
          return 'Emociones, relaciones e intuición';
        case TarotSuit.wands:
          return 'Creatividad, pasión y carrera';
        case TarotSuit.swords:
          return 'Pensamientos, comunicación y desafíos';
        case TarotSuit.pentacles:
          return 'Asuntos materiales, dinero y salud';
      }
    } else {
      // Default to English
      switch (suit) {
        case TarotSuit.majorArcana:
          return 'The major life themes and spiritual lessons';
        case TarotSuit.cups:
          return 'Emotions, relationships, and intuition';
        case TarotSuit.wands:
          return 'Creativity, passion, and career';
        case TarotSuit.swords:
          return 'Thoughts, communication, and challenges';
        case TarotSuit.pentacles:
          return 'Material matters, money, and health';
      }
    }
  }

  /// Gets localized tarot suit display name
  String getTarotSuitDisplayName(TarotSuit suit, Locale locale) {
    if (locale.languageCode == 'es') {
      switch (suit) {
        case TarotSuit.majorArcana:
          return 'Arcanos Mayores';
        case TarotSuit.cups:
          return 'Copas';
        case TarotSuit.wands:
          return 'Bastos';
        case TarotSuit.swords:
          return 'Espadas';
        case TarotSuit.pentacles:
          return 'Pentáculos';
      }
    } else {
      // Default to English
      switch (suit) {
        case TarotSuit.majorArcana:
          return 'Major Arcana';
        case TarotSuit.cups:
          return 'Cups';
        case TarotSuit.wands:
          return 'Wands';
        case TarotSuit.swords:
          return 'Swords';
        case TarotSuit.pentacles:
          return 'Pentacles';
      }
    }
  }

  /// Clears the cached prompt data
  /// Useful for testing or memory management
  void clearCache() {
    _englishPrompts = null;
    _spanishPrompts = null;
  }

  /// Preloads journal prompts for both supported locales
  /// Useful for improving performance when switching languages
  Future<void> preloadAllJournalPrompts() async {
    try {
      await Future.wait([
        _loadJournalPrompts(const Locale('en')),
        _loadJournalPrompts(const Locale('es')),
      ]);
    } catch (e) {
      // Preloading is optional, so we don't throw errors
      // Just handle gracefully
    }
  }

  /// Gets a journal prompt for a specific day (deterministic based on day)
  /// This ensures users get the same prompt for the same day
  Future<String> getDailyJournalPrompt(DateTime date, Locale locale) async {
    const fallbackPrompt = 'What insights are emerging for you today?';

    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final prompts = await _loadJournalPrompts(locale);

        if (prompts.isNotEmpty) {
          // Use day of year to get consistent prompt for the same date
          final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
          final promptIndex = dayOfYear % prompts.length;
          final prompt = prompts[promptIndex];
          if (prompt.isNotEmpty) {
            return prompt;
          }
        }

        // Fallback to English if no prompts available or prompt is empty
        if (locale.languageCode != 'en') {
          return await getDailyJournalPrompt(date, const Locale('en'));
        }

        // Last resort fallback
        return fallbackPrompt;
      },
      fallbackPrompt, // Fallback value
      operationName: 'getDailyJournalPrompt',
      context:
          'date: ${date.toIso8601String()}, locale: ${locale.languageCode}',
    );
  }
}
