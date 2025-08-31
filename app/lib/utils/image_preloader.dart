import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/card_service.dart';
import '../providers/image_cache_provider.dart';
import '../models/enums.dart';

/// Utility class for preloading images to improve performance
class ImagePreloader {
  static final ImagePreloader _instance = ImagePreloader._internal();
  factory ImagePreloader() => _instance;
  ImagePreloader._internal();

  bool _isPreloading = false;
  bool _hasPreloaded = false;

  /// Preload essential card images (Major Arcana and commonly used cards)
  Future<void> preloadEssentialCards(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (_isPreloading || _hasPreloaded) return;

    _isPreloading = true;

    try {
      final cardService = CardService.instance;
      final cacheManager = ref.read(cacheManagerProvider);

      // Get all cards
      final allCards = await cardService.getAllCards();

      // Prioritize Major Arcana cards (most commonly used)
      final majorArcana = allCards
          .where((card) => card.suit == TarotSuit.majorArcana)
          .toList();
      final majorArcanaUrls = majorArcana.map((card) => card.imageUrl).toList();

      // Preload Major Arcana first
      if (context.mounted) {
        await cacheManager.preloadImages(majorArcanaUrls, context);
      }

      // Then preload a selection of Minor Arcana (Aces and Court cards)
      final importantMinorArcana = allCards.where((card) {
        return card.suit != TarotSuit.majorArcana &&
            (card.name.toLowerCase().contains('ace') ||
                card.name.toLowerCase().contains('king') ||
                card.name.toLowerCase().contains('queen') ||
                card.name.toLowerCase().contains('knight') ||
                card.name.toLowerCase().contains('page'));
      }).toList();

      final minorArcanaUrls = importantMinorArcana
          .map((card) => card.imageUrl)
          .toList();
      if (context.mounted) {
        await cacheManager.preloadImages(minorArcanaUrls, context);
      }

      _hasPreloaded = true;
      debugPrint('Essential cards preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading essential cards: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Preload all card images (use sparingly, only when user has good connection)
  Future<void> preloadAllCards(BuildContext context, WidgetRef ref) async {
    if (_isPreloading) return;

    _isPreloading = true;

    try {
      final cardService = CardService.instance;
      final cacheManager = ref.read(cacheManagerProvider);

      final allCards = await cardService.getAllCards();
      final allUrls = allCards.map((card) => card.imageUrl).toList();

      // Preload in batches to avoid overwhelming the system
      const batchSize = 10;
      for (int i = 0; i < allUrls.length; i += batchSize) {
        final batch = allUrls.skip(i).take(batchSize).toList();
        if (context.mounted) {
          await cacheManager.preloadImages(batch, context);
        }

        // Small delay between batches to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _hasPreloaded = true;
      debugPrint('All cards preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading all cards: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Preload specific cards for a reading
  Future<void> preloadReadingCards(
    List<String> cardIds,
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final cardService = CardService.instance;
      final cacheManager = ref.read(cacheManagerProvider);

      final urls = <String>[];
      for (final cardId in cardIds) {
        final card = await cardService.getCardById(cardId);
        if (card != null) {
          urls.add(card.imageUrl);
        }
      }

      if (urls.isNotEmpty) {
        if (context.mounted) {
          await cacheManager.preloadImages(urls, context);
        }
        debugPrint('Reading cards preloaded: ${urls.length} images');
      }
    } catch (e) {
      debugPrint('Error preloading reading cards: $e');
    }
  }

  /// Check if essential cards have been preloaded
  bool get hasPreloadedEssentials => _hasPreloaded;

  /// Check if currently preloading
  bool get isPreloading => _isPreloading;

  /// Reset preloading state (useful for testing or cache clearing)
  void reset() {
    _hasPreloaded = false;
    _isPreloading = false;
  }
}

/// Provider for the image preloader
final imagePreloaderProvider = Provider<ImagePreloader>((ref) {
  return ImagePreloader();
});
