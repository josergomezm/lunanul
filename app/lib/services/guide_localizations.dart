import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../models/enums.dart';
import '../models/tarot_guide.dart';
import '../services/guide_service.dart';
import '../utils/localization_error_handler.dart';
import '../l10n/generated/app_localizations.dart';

/// Service for managing localized guide content and interpretation templates
class GuideLocalizations {
  static const String _englishInterpretationsPath =
      'assets/data/guide_interpretations_en.json';
  static const String _spanishInterpretationsPath =
      'assets/data/guide_interpretations_es.json';

  // Cache for loaded interpretation data
  Map<String, dynamic>? _englishInterpretations;
  Map<String, dynamic>? _spanishInterpretations;

  // Random number generator for template selection
  final Random _random = Random();

  /// Loads and caches interpretation templates for the specified locale
  Future<Map<String, dynamic>> _loadInterpretationTemplates(
    Locale locale,
  ) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        String assetPath;
        Map<String, dynamic>? cache;

        if (locale.languageCode == 'es') {
          assetPath = _spanishInterpretationsPath;
          cache = _spanishInterpretations;
        } else {
          assetPath = _englishInterpretationsPath;
          cache = _englishInterpretations;
        }

        // Return cached data if available
        if (cache != null) {
          return cache;
        }

        // Load from assets with error handling
        try {
          final String jsonString = await rootBundle.loadString(assetPath);
          final Map<String, dynamic> jsonData = json.decode(jsonString);

          // Validate that interpretation data exists
          if (jsonData.isEmpty) {
            throw FormatException(
              'Invalid interpretation data structure in $assetPath',
            );
          }

          // Cache the loaded data
          if (locale.languageCode == 'es') {
            _spanishInterpretations = jsonData;
          } else {
            _englishInterpretations = jsonData;
          }

          return jsonData;
        } catch (e) {
          // Handle JSON parsing errors
          if (e is FormatException) {
            LocalizationErrorHandler.handleJsonParsingError(
              assetPath,
              e,
              context: 'GuideLocalizations._loadInterpretationTemplates',
            );
          }
          rethrow;
        }
      },
      <String, dynamic>{}, // Fallback empty map
      operationName: 'loadInterpretationTemplates',
      context: 'locale: ${locale.languageCode}',
    );
  }

  /// Gets localized guide name
  String getGuideName(GuideType guideType, AppLocalizations localizations) {
    switch (guideType) {
      case GuideType.sage:
        return localizations.guideSageName;
      case GuideType.healer:
        return localizations.guideHealerName;
      case GuideType.mentor:
        return localizations.guideMentorName;
      case GuideType.visionary:
        return localizations.guideVisionaryName;
    }
  }

  /// Gets localized guide title
  String getGuideTitle(GuideType guideType, AppLocalizations localizations) {
    switch (guideType) {
      case GuideType.sage:
        return localizations.guideSageTitle;
      case GuideType.healer:
        return localizations.guideHealerTitle;
      case GuideType.mentor:
        return localizations.guideMentorTitle;
      case GuideType.visionary:
        return localizations.guideVisionaryTitle;
    }
  }

  /// Gets localized guide description
  String getGuideDescription(
    GuideType guideType,
    AppLocalizations localizations,
  ) {
    switch (guideType) {
      case GuideType.sage:
        return localizations.guideSageDescription;
      case GuideType.healer:
        return localizations.guideHealerDescription;
      case GuideType.mentor:
        return localizations.guideMentorDescription;
      case GuideType.visionary:
        return localizations.guideVisionaryDescription;
    }
  }

  /// Gets localized guide expertise
  String getGuideExpertise(
    GuideType guideType,
    AppLocalizations localizations,
  ) {
    switch (guideType) {
      case GuideType.sage:
        return localizations.guideSageExpertise;
      case GuideType.healer:
        return localizations.guideHealerExpertise;
      case GuideType.mentor:
        return localizations.guideMentorExpertise;
      case GuideType.visionary:
        return localizations.guideVisionaryExpertise;
    }
  }

  /// Creates a localized version of a guide
  TarotGuide localizeGuide(TarotGuide guide, AppLocalizations localizations) {
    return guide.withLocalization(
      localizedName: getGuideName(guide.type, localizations),
      localizedTitle: getGuideTitle(guide.type, localizations),
      localizedDescription: getGuideDescription(guide.type, localizations),
      localizedExpertise: getGuideExpertise(guide.type, localizations),
    );
  }

  /// Gets all localized guides
  List<TarotGuide> getLocalizedGuides(AppLocalizations localizations) {
    return TarotGuide.getAllDefaultGuides()
        .map((guide) => localizeGuide(guide, localizations))
        .toList();
  }

  /// Gets a localized interpretation template for a specific guide and topic
  Future<InterpretationTemplate> getLocalizedInterpretationTemplate(
    GuideType guideType,
    ReadingTopic topic,
    Locale locale,
  ) async {
    final fallbackTemplate = InterpretationTemplate(
      guide: guideType, // Use the requested guide type, not hardcoded sage
      openingPhrase: 'The cards speak to you with wisdom.',
      cardContextTemplate: 'The {cardName} {orientation} reveals {keywords}.',
      actionAdviceTemplate:
          'Consider how {topicApproach} applies to your situation.',
      closingPhrase: 'Trust in the guidance you receive.',
    );

    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final interpretations = await _loadInterpretationTemplates(locale);
        final guideKey = guideType.name;

        if (!interpretations.containsKey(guideKey)) {
          // Fallback to English if guide not found in current locale
          if (locale.languageCode != 'en') {
            return await getLocalizedInterpretationTemplate(
              guideType,
              topic,
              const Locale('en'),
            );
          }
          return fallbackTemplate;
        }

        final guideData = interpretations[guideKey] as Map<String, dynamic>;

        return InterpretationTemplate(
          guide: guideType,
          openingPhrase: _getRandomElement(
            List<String>.from(guideData['openingPhrases'] ?? []),
          ),
          cardContextTemplate: _getRandomElement(
            List<String>.from(guideData['contextTemplates'] ?? []),
          ),
          actionAdviceTemplate: _getRandomElement(
            List<String>.from(guideData['actionTemplates'] ?? []),
          ),
          closingPhrase: _getRandomElement(
            List<String>.from(guideData['closingPhrases'] ?? []),
          ),
        );
      },
      fallbackTemplate, // Fallback value
      operationName: 'getLocalizedInterpretationTemplate',
      context:
          'guide: ${guideType.name}, topic: ${topic.name}, locale: ${locale.languageCode}',
    );
  }

  /// Gets a random element from a list, with fallback
  String _getRandomElement(List<String> list) {
    if (list.isEmpty) {
      return 'The guidance flows through this moment.';
    }
    return list[_random.nextInt(list.length)];
  }

  /// Clears the cached interpretation data
  /// Useful for testing or memory management
  void clearCache() {
    _englishInterpretations = null;
    _spanishInterpretations = null;
  }

  /// Preloads interpretation templates for both supported locales
  /// Useful for improving performance when switching languages
  Future<void> preloadAllInterpretationTemplates() async {
    try {
      await Future.wait([
        _loadInterpretationTemplates(const Locale('en')),
        _loadInterpretationTemplates(const Locale('es')),
      ]);
    } catch (e) {
      // Preloading is optional, so we don't throw errors
      // Just handle gracefully
    }
  }

  /// Validates that interpretation templates are properly structured
  Future<bool> validateInterpretationTemplates(Locale locale) async {
    try {
      final interpretations = await _loadInterpretationTemplates(locale);

      for (final guideType in GuideType.values) {
        final guideKey = guideType.name;
        if (!interpretations.containsKey(guideKey)) {
          return false;
        }

        final guideData = interpretations[guideKey] as Map<String, dynamic>;
        final requiredKeys = [
          'openingPhrases',
          'contextTemplates',
          'actionTemplates',
          'closingPhrases',
        ];

        for (final key in requiredKeys) {
          if (!guideData.containsKey(key) || (guideData[key] as List).isEmpty) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
