import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import 'tarot_card_localizations.dart';

/// Service for managing tarot cards, loading card data, and shuffling
class CardService {
  static CardService? _instance;
  static CardService get instance => _instance ??= CardService._();
  CardService._();

  List<TarotCard>? _allCards;
  final Random _random = Random();
  final TarotCardLocalizations _localizations = TarotCardLocalizations();

  /// Get all 78 tarot cards
  Future<List<TarotCard>> getAllCards() async {
    if (_allCards != null) {
      return List.from(_allCards!);
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/tarot_cards.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> cardsJson = jsonData['cards'] as List<dynamic>;

      _allCards = cardsJson
          .map(
            (cardJson) => TarotCard.fromJson(cardJson as Map<String, dynamic>),
          )
          .toList();

      return List.from(_allCards!);
    } catch (e) {
      throw Exception('Failed to load tarot cards: $e');
    }
  }

  /// Get a specific card by ID
  Future<TarotCard?> getCardById(String id) async {
    final cards = await getAllCards();
    try {
      return cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get cards by suit
  Future<List<TarotCard>> getCardsBySuit(TarotSuit suit) async {
    final cards = await getAllCards();
    return cards.where((card) => card.suit == suit).toList();
  }

  /// Get Major Arcana cards only
  Future<List<TarotCard>> getMajorArcanaCards() async {
    return getCardsBySuit(TarotSuit.majorArcana);
  }

  /// Get Minor Arcana cards only
  Future<List<TarotCard>> getMinorArcanaCards() async {
    final cards = await getAllCards();
    return cards.where((card) => card.suit != TarotSuit.majorArcana).toList();
  }

  /// Get court cards (Page, Knight, Queen, King)
  Future<List<TarotCard>> getCourtCards() async {
    final cards = await getAllCards();
    return cards.where((card) => card.isCourtCard).toList();
  }

  /// Shuffle and draw a single card
  Future<TarotCard> drawSingleCard({bool allowReversed = true}) async {
    final cards = await getAllCards();
    final shuffledCards = _shuffleCards(cards);
    final drawnCard = shuffledCards.first;

    if (allowReversed && _random.nextBool()) {
      return drawnCard.copyWith(isReversed: true);
    }

    return drawnCard;
  }

  /// Shuffle and draw multiple cards
  Future<List<TarotCard>> drawCards(
    int count, {
    bool allowReversed = true,
    bool allowDuplicates = false,
  }) async {
    if (count <= 0) {
      throw ArgumentError('Count must be greater than 0');
    }

    final cards = await getAllCards();

    if (!allowDuplicates && count > cards.length) {
      throw ArgumentError(
        'Cannot draw $count unique cards from a deck of ${cards.length}',
      );
    }

    final shuffledCards = _shuffleCards(cards);
    final drawnCards = <TarotCard>[];

    if (allowDuplicates) {
      // Allow duplicates - can draw the same card multiple times
      for (int i = 0; i < count; i++) {
        final card = shuffledCards[_random.nextInt(shuffledCards.length)];
        final isReversed = allowReversed && _random.nextBool();
        drawnCards.add(card.copyWith(isReversed: isReversed));
      }
    } else {
      // No duplicates - each card can only be drawn once
      for (int i = 0; i < count; i++) {
        final card = shuffledCards[i];
        final isReversed = allowReversed && _random.nextBool();
        drawnCards.add(card.copyWith(isReversed: isReversed));
      }
    }

    return drawnCards;
  }

  /// Shuffle cards using Fisher-Yates algorithm
  List<TarotCard> _shuffleCards(List<TarotCard> cards) {
    final shuffled = List<TarotCard>.from(cards);

    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return shuffled;
  }

  /// Get a random card of the day
  Future<TarotCard> getCardOfTheDay({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();

    // Use date as seed for consistent "card of the day"
    final daysSinceEpoch = targetDate.difference(DateTime(1970, 1, 1)).inDays;
    final seededRandom = Random(daysSinceEpoch);

    final cards = await getAllCards();
    final cardIndex = seededRandom.nextInt(cards.length);
    final isReversed = seededRandom.nextBool();

    return cards[cardIndex].copyWith(isReversed: isReversed);
  }

  /// Search cards by name or keywords
  Future<List<TarotCard>> searchCards(String query) async {
    if (query.isEmpty) {
      return getAllCards();
    }

    final cards = await getAllCards();
    final lowercaseQuery = query.toLowerCase();

    return cards.where((card) {
      return card.name.toLowerCase().contains(lowercaseQuery) ||
          card.keywords.any(
            (keyword) => keyword.toLowerCase().contains(lowercaseQuery),
          ) ||
          card.uprightMeaning.toLowerCase().contains(lowercaseQuery) ||
          card.reversedMeaning.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get cards filtered by multiple criteria
  Future<List<TarotCard>> getFilteredCards({
    TarotSuit? suit,
    bool? isMajorArcana,
    bool? isCourtCard,
    List<String>? keywords,
  }) async {
    final cards = await getAllCards();

    return cards.where((card) {
      if (suit != null && card.suit != suit) return false;
      if (isMajorArcana != null && card.isMajorArcana != isMajorArcana) {
        return false;
      }
      if (isCourtCard != null && card.isCourtCard != isCourtCard) return false;
      if (keywords != null && keywords.isNotEmpty) {
        final hasKeyword = keywords.any(
          (keyword) => card.keywords.any(
            (cardKeyword) =>
                cardKeyword.toLowerCase().contains(keyword.toLowerCase()),
          ),
        );
        if (!hasKeyword) return false;
      }
      return true;
    }).toList();
  }

  /// Get random cards for testing purposes
  Future<List<TarotCard>> getRandomCards(int count) async {
    return drawCards(count, allowReversed: true, allowDuplicates: false);
  }

  /// Get a localized version of a specific card by ID
  Future<TarotCard?> getLocalizedCardById(String id, Locale locale) async {
    final card = await getCardById(id);
    if (card == null) return null;

    return await _localizeCard(card, locale);
  }

  /// Get all cards with localization for the specified locale
  Future<List<TarotCard>> getLocalizedCards(Locale locale) async {
    final cards = await getAllCards();
    final localizedCards = <TarotCard>[];

    for (final card in cards) {
      final localizedCard = await _localizeCard(card, locale);
      localizedCards.add(localizedCard);
    }

    return localizedCards;
  }

  /// Draw a single localized card
  Future<TarotCard> drawLocalizedSingleCard(
    Locale locale, {
    bool allowReversed = true,
  }) async {
    final card = await drawSingleCard(allowReversed: allowReversed);
    return await _localizeCard(card, locale);
  }

  /// Draw multiple localized cards
  Future<List<TarotCard>> drawLocalizedCards(
    int count,
    Locale locale, {
    bool allowReversed = true,
    bool allowDuplicates = false,
  }) async {
    final cards = await drawCards(
      count,
      allowReversed: allowReversed,
      allowDuplicates: allowDuplicates,
    );

    final localizedCards = <TarotCard>[];
    for (final card in cards) {
      final localizedCard = await _localizeCard(card, locale);
      localizedCards.add(localizedCard);
    }

    return localizedCards;
  }

  /// Get a localized card of the day
  Future<TarotCard> getLocalizedCardOfTheDay(
    Locale locale, {
    DateTime? date,
  }) async {
    final card = await getCardOfTheDay(date: date);
    return await _localizeCard(card, locale);
  }

  /// Search cards with localized content
  Future<List<TarotCard>> searchLocalizedCards(
    String query,
    Locale locale,
  ) async {
    if (query.isEmpty) {
      return getLocalizedCards(locale);
    }

    final cards = await getAllCards();
    final lowercaseQuery = query.toLowerCase();
    final matchingCards = <TarotCard>[];

    for (final card in cards) {
      final localizedCard = await _localizeCard(card, locale);

      // Search in both original and localized content
      final searchableContent = [
        card.name.toLowerCase(),
        localizedCard.effectiveName.toLowerCase(),
        ...card.keywords.map((k) => k.toLowerCase()),
        ...localizedCard.effectiveKeywords.map((k) => k.toLowerCase()),
        card.uprightMeaning.toLowerCase(),
        localizedCard.effectiveUprightMeaning.toLowerCase(),
        card.reversedMeaning.toLowerCase(),
        localizedCard.effectiveReversedMeaning.toLowerCase(),
      ];

      if (searchableContent.any(
        (content) => content.contains(lowercaseQuery),
      )) {
        matchingCards.add(localizedCard);
      }
    }

    return matchingCards;
  }

  /// Helper method to localize a single card
  Future<TarotCard> _localizeCard(TarotCard card, Locale locale) async {
    try {
      // If it's English or already localized, return as is
      if (locale.languageCode == 'en' || card.hasLocalization) {
        return card;
      }

      // Get localized content
      final localizedName = await _localizations.getCardName(card.id, locale);
      final localizedKeywords = await _localizations.getKeywords(
        card.id,
        locale,
      );
      final localizedUprightMeaning = await _localizations.getUprightMeaning(
        card.id,
        locale,
      );
      final localizedReversedMeaning = await _localizations.getReversedMeaning(
        card.id,
        locale,
      );

      return card.withLocalization(
        localizedName: localizedName,
        localizedKeywords: localizedKeywords,
        localizedUprightMeaning: localizedUprightMeaning,
        localizedReversedMeaning: localizedReversedMeaning,
      );
    } catch (e) {
      // If localization fails, return the original card
      return card;
    }
  }

  /// Validate that all cards are properly loaded
  Future<bool> validateCardData() async {
    try {
      final cards = await getAllCards();

      // Check total count
      if (cards.length != 78) return false;

      // Check that all cards are valid
      if (!cards.every((card) => card.isValid)) return false;

      // Check Major Arcana count (22 cards)
      final majorArcana = cards.where((card) => card.isMajorArcana).length;
      if (majorArcana != 22) return false;

      // Check Minor Arcana count (56 cards)
      final minorArcana = cards.where((card) => !card.isMajorArcana).length;
      if (minorArcana != 56) return false;

      // Check each suit has 14 cards (Ace through King)
      for (final suit in [
        TarotSuit.cups,
        TarotSuit.wands,
        TarotSuit.swords,
        TarotSuit.pentacles,
      ]) {
        final suitCards = cards.where((card) => card.suit == suit).length;
        if (suitCards != 14) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear cached cards (useful for testing)
  void clearCache() {
    _allCards = null;
    _localizations.clearCache();
  }

  /// Get card statistics
  Future<Map<String, dynamic>> getCardStatistics() async {
    final cards = await getAllCards();

    final majorArcanaCount = cards.where((card) => card.isMajorArcana).length;
    final minorArcanaCount = cards.length - majorArcanaCount;
    final courtCardCount = cards.where((card) => card.isCourtCard).length;

    final suitCounts = <String, int>{};
    for (final suit in TarotSuit.values) {
      suitCounts[suit.name] = cards.where((card) => card.suit == suit).length;
    }

    return {
      'totalCards': cards.length,
      'majorArcanaCount': majorArcanaCount,
      'minorArcanaCount': minorArcanaCount,
      'courtCardCount': courtCardCount,
      'suitCounts': suitCounts,
    };
  }
}
