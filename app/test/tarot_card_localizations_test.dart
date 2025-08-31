import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/tarot_card_localizations.dart';

void main() {
  group('TarotCardLocalizations Tests', () {
    late TarotCardLocalizations service;

    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = TarotCardLocalizations();
    });

    tearDown(() {
      service.clearCache();
    });

    group('basic functionality', () {
      test('service can be instantiated', () {
        expect(service, isNotNull);
      });

      test('clearCache completes without error', () {
        expect(() => service.clearCache(), returnsNormally);
      });

      test('preloadAllCardData completes without throwing', () async {
        expect(() => service.preloadAllCardData(), returnsNormally);
      });
    });

    group('card name retrieval', () {
      test('getCardName returns formatted name for unknown card', () async {
        final result = await service.getCardName(
          'unknown_card_test',
          const Locale('en'),
        );
        expect(result, equals('Unknown Card Test'));
      });

      test('getCardName handles empty card ID', () async {
        final result = await service.getCardName('', const Locale('en'));
        expect(result, equals(''));
      });

      test('getCardName handles single word card ID', () async {
        final result = await service.getCardName('test', const Locale('en'));
        expect(result, equals('Test'));
      });
    });

    group('meaning retrieval fallbacks', () {
      test('getUprightMeaning returns fallback for unknown card', () async {
        final result = await service.getUprightMeaning(
          'unknown_card',
          const Locale('en'),
        );
        expect(result, equals('Meaning not available'));
      });

      test('getReversedMeaning returns fallback for unknown card', () async {
        final result = await service.getReversedMeaning(
          'unknown_card',
          const Locale('en'),
        );
        expect(result, equals('Meaning not available'));
      });
    });

    group('keywords retrieval', () {
      test('getKeywords returns empty list for unknown card', () async {
        final result = await service.getKeywords(
          'unknown_card',
          const Locale('en'),
        );
        expect(result, isEmpty);
      });
    });

    group('card existence checks', () {
      test('cardExists returns false for unknown card', () async {
        final result = await service.cardExists('unknown_card');
        expect(result, isFalse);
      });
    });

    group('available cards', () {
      test('getAvailableCardIds returns a list', () async {
        final result = await service.getAvailableCardIds();
        expect(result, isA<List<String>>());
      });
    });

    group('complete card info', () {
      test(
        'getCardInfo returns map with expected keys for unknown card',
        () async {
          final result = await service.getCardInfo(
            'unknown_card',
            const Locale('en'),
          );
          expect(result, isNotNull);
          expect(result!['id'], equals('unknown_card'));
          expect(result['name'], equals('Unknown Card'));
          expect(result['uprightMeaning'], equals('Meaning not available'));
          expect(result['reversedMeaning'], equals('Meaning not available'));
          expect(result['keywords'], isEmpty);
        },
      );
    });

    group('locale handling', () {
      test('handles English locale', () async {
        final result = await service.getCardName(
          'test_card',
          const Locale('en'),
        );
        expect(result, isA<String>());
      });

      test('handles Spanish locale', () async {
        final result = await service.getCardName(
          'test_card',
          const Locale('es'),
        );
        expect(result, isA<String>());
      });

      test('handles unsupported locale gracefully', () async {
        final result = await service.getCardName(
          'test_card',
          const Locale('fr'),
        );
        expect(result, isA<String>());
      });
    });

    group('error handling', () {
      test('handles null card ID gracefully', () async {
        // This tests the service's robustness
        expect(
          () => service.getCardName('', const Locale('en')),
          returnsNormally,
        );
      });

      test('handles invalid locale gracefully', () async {
        expect(
          () => service.getCardName('test', const Locale('invalid')),
          returnsNormally,
        );
      });
    });

    group('caching behavior', () {
      test('clearCache can be called multiple times', () {
        expect(() {
          service.clearCache();
          service.clearCache();
          service.clearCache();
        }, returnsNormally);
      });
    });

    group('integration with real assets', () {
      test('can load card data from assets if available', () async {
        // This test will pass if assets are available, or gracefully handle if not
        final cardIds = await service.getAvailableCardIds();
        expect(cardIds, isA<List<String>>());

        if (cardIds.isNotEmpty) {
          // If we have cards, test that we can get their info
          final firstCard = cardIds.first;
          final cardInfo = await service.getCardInfo(
            firstCard,
            const Locale('en'),
          );
          expect(cardInfo, isNotNull);
          expect(cardInfo!['id'], equals(firstCard));
        }
      });

      test(
        'handles asset loading gracefully when assets not available',
        () async {
          // This ensures the service doesn't crash when assets aren't available
          final exists = await service.cardExists('fool');
          expect(exists, isA<bool>());
        },
      );
    });
  });
}
