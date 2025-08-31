import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

/// Service for managing localized tarot card content
class TarotCardLocalizations {
  static const String _englishCardsPath = 'assets/data/tarot_cards_en.json';
  static const String _spanishCardsPath = 'assets/data/tarot_cards_es.json';

  // Cache for loaded card data
  Map<String, Map<String, dynamic>>? _englishCards;
  Map<String, Map<String, dynamic>>? _spanishCards;

  /// Loads and caches card data for the specified locale
  Future<Map<String, dynamic>> _loadCardData(Locale locale) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        String assetPath;
        Map<String, Map<String, dynamic>>? cache;

        if (locale.languageCode == 'es') {
          assetPath = _spanishCardsPath;
          cache = _spanishCards;
        } else {
          assetPath = _englishCardsPath;
          cache = _englishCards;
        }

        // Return cached data if available
        if (cache != null) {
          return {'cards': cache};
        }

        // Load from assets with error handling
        try {
          final String jsonString = await rootBundle.loadString(assetPath);
          final Map<String, dynamic> jsonData = json.decode(jsonString);

          // Validate that cards data exists
          if (!jsonData.containsKey('cards') || jsonData['cards'] is! Map) {
            throw FormatException('Invalid card data structure in $assetPath');
          }

          // Cache the loaded data
          final Map<String, Map<String, dynamic>> cardsData =
              Map<String, Map<String, dynamic>>.from(
                jsonData['cards'].map(
                  (key, value) =>
                      MapEntry(key, Map<String, dynamic>.from(value)),
                ),
              );

          if (locale.languageCode == 'es') {
            _spanishCards = cardsData;
          } else {
            _englishCards = cardsData;
          }

          return jsonData;
        } catch (e) {
          // Handle JSON parsing errors
          if (e is FormatException) {
            return LocalizationErrorHandler.handleJsonParsingError(
              assetPath,
              e,
              context: 'TarotCardLocalizations._loadCardData',
            );
          }
          rethrow;
        }
      },
      {'cards': <String, Map<String, dynamic>>{}}, // Fallback empty cards data
      operationName: 'loadCardData',
      context: 'locale: ${locale.languageCode}',
    );
  }

  /// Gets the localized name of a tarot card
  /// Falls back to English if the card is not found in the requested locale
  Future<String> getCardName(String cardId, Locale locale) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final cardData = await _loadCardData(locale);
        final cards = cardData.safeGetMap('cards');

        if (cards.containsKey(cardId)) {
          final card = cards.safeGetMap(cardId);
          final name = card.safeGetString('name');
          if (name.isNotEmpty) {
            return name;
          }
        }

        // Fallback to English if not found or empty
        if (locale.languageCode != 'en') {
          return await getCardName(cardId, const Locale('en'));
        }

        // Last resort fallback
        return _formatCardIdAsName(cardId);
      },
      _formatCardIdAsName(cardId), // Fallback value
      operationName: 'getCardName',
      context: 'cardId: $cardId, locale: ${locale.languageCode}',
    );
  }

  /// Gets the upright meaning of a tarot card
  /// Falls back to English if not found in the requested locale
  Future<String> getUprightMeaning(String cardId, Locale locale) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final cardData = await _loadCardData(locale);
        final cards = cardData.safeGetMap('cards');

        if (cards.containsKey(cardId)) {
          final card = cards.safeGetMap(cardId);
          final meaning = card.safeGetString('uprightMeaning');
          if (meaning.isNotEmpty) {
            return meaning;
          }
        }

        // Fallback to English if not found or empty
        if (locale.languageCode != 'en') {
          return await getUprightMeaning(cardId, const Locale('en'));
        }

        // Last resort fallback
        return 'Meaning not available';
      },
      'Meaning not available', // Fallback value
      operationName: 'getUprightMeaning',
      context: 'cardId: $cardId, locale: ${locale.languageCode}',
    );
  }

  /// Gets the reversed meaning of a tarot card
  /// Falls back to English if not found in the requested locale
  Future<String> getReversedMeaning(String cardId, Locale locale) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final cardData = await _loadCardData(locale);
        final cards = cardData.safeGetMap('cards');

        if (cards.containsKey(cardId)) {
          final card = cards.safeGetMap(cardId);
          final meaning = card.safeGetString('reversedMeaning');
          if (meaning.isNotEmpty) {
            return meaning;
          }
        }

        // Fallback to English if not found or empty
        if (locale.languageCode != 'en') {
          return await getReversedMeaning(cardId, const Locale('en'));
        }

        // Last resort fallback
        return 'Meaning not available';
      },
      'Meaning not available', // Fallback value
      operationName: 'getReversedMeaning',
      context: 'cardId: $cardId, locale: ${locale.languageCode}',
    );
  }

  /// Gets the keywords for a tarot card
  /// Falls back to English if not found in the requested locale
  Future<List<String>> getKeywords(String cardId, Locale locale) async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final cardData = await _loadCardData(locale);
        final cards = cardData.safeGetMap('cards');

        if (cards.containsKey(cardId)) {
          final card = cards.safeGetMap(cardId);
          final keywords = card.safeGetStringList('keywords');
          if (keywords.isNotEmpty) {
            return keywords;
          }
        }

        // Fallback to English if not found or empty
        if (locale.languageCode != 'en') {
          return await getKeywords(cardId, const Locale('en'));
        }

        // Last resort fallback
        return <String>[];
      },
      <String>[], // Fallback value
      operationName: 'getKeywords',
      context: 'cardId: $cardId, locale: ${locale.languageCode}',
    );
  }

  /// Gets all available card IDs
  /// Uses English cards as the source of truth for available cards
  Future<List<String>> getAvailableCardIds() async {
    try {
      final cardData = await _loadCardData(const Locale('en'));
      final cards = cardData['cards'] as Map<String, dynamic>?;
      return cards?.keys.toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Gets complete card information for a given card ID and locale
  Future<Map<String, dynamic>?> getCardInfo(
    String cardId,
    Locale locale,
  ) async {
    try {
      final name = await getCardName(cardId, locale);
      final uprightMeaning = await getUprightMeaning(cardId, locale);
      final reversedMeaning = await getReversedMeaning(cardId, locale);
      final keywords = await getKeywords(cardId, locale);

      return {
        'id': cardId,
        'name': name,
        'uprightMeaning': uprightMeaning,
        'reversedMeaning': reversedMeaning,
        'keywords': keywords,
      };
    } catch (e) {
      return null;
    }
  }

  /// Checks if a card exists in the localization data
  Future<bool> cardExists(String cardId) async {
    try {
      final availableCards = await getAvailableCardIds();
      return availableCards.contains(cardId);
    } catch (e) {
      return false;
    }
  }

  /// Clears the cached card data
  /// Useful for testing or memory management
  void clearCache() {
    _englishCards = null;
    _spanishCards = null;
  }

  /// Formats a card ID as a readable name (fallback utility)
  String _formatCardIdAsName(String cardId) {
    return cardId
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Preloads card data for both supported locales
  /// Useful for improving performance when switching languages
  Future<void> preloadAllCardData() async {
    try {
      await Future.wait([
        _loadCardData(const Locale('en')),
        _loadCardData(const Locale('es')),
      ]);
    } catch (e) {
      // Preloading is optional, so we don't throw errors
      // Just log or handle gracefully
    }
  }
}
