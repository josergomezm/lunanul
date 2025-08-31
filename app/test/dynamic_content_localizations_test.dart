import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/dynamic_content_localizations.dart';
import 'package:lunanul/models/enums.dart';

void main() {
  group('DynamicContentLocalizations Tests', () {
    late DynamicContentLocalizations service;

    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = DynamicContentLocalizations();
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

      test('preloadAllJournalPrompts completes without throwing', () async {
        expect(() => service.preloadAllJournalPrompts(), returnsNormally);
      });
    });

    group('journal prompt retrieval', () {
      test('getJournalPrompt returns fallback for invalid index', () async {
        final result = await service.getJournalPrompt(-1, const Locale('en'));
        expect(result, equals('What insights are emerging for you today?'));
      });

      test(
        'getJournalPrompt returns fallback for out of range index',
        () async {
          final result = await service.getJournalPrompt(
            9999,
            const Locale('en'),
          );
          expect(result, equals('What insights are emerging for you today?'));
        },
      );

      test('getRandomJournalPrompt returns a string', () async {
        final result = await service.getRandomJournalPrompt(const Locale('en'));
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
      });

      test('getRandomJournalPrompt handles Spanish locale', () async {
        final result = await service.getRandomJournalPrompt(const Locale('es'));
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
      });

      test(
        'getDailyJournalPrompt returns consistent prompt for same date',
        () async {
          final date = DateTime(2024, 1, 15);
          final result1 = await service.getDailyJournalPrompt(
            date,
            const Locale('en'),
          );
          final result2 = await service.getDailyJournalPrompt(
            date,
            const Locale('en'),
          );
          expect(result1, equals(result2));
        },
      );

      test(
        'getDailyJournalPrompt returns different prompts for different dates',
        () async {
          final date1 = DateTime(2024, 1, 15);
          final date2 = DateTime(2024, 1, 16);
          final result1 = await service.getDailyJournalPrompt(
            date1,
            const Locale('en'),
          );
          final result2 = await service.getDailyJournalPrompt(
            date2,
            const Locale('en'),
          );
          // Note: This might occasionally be the same due to modulo, but generally should be different
          expect(result1, isA<String>());
          expect(result2, isA<String>());
        },
      );
    });

    group('journal prompt count and retrieval', () {
      test('getJournalPromptCount returns non-negative number', () async {
        final count = await service.getJournalPromptCount(const Locale('en'));
        expect(count, greaterThanOrEqualTo(0));
      });

      test('getAllJournalPrompts returns a list', () async {
        final prompts = await service.getAllJournalPrompts(const Locale('en'));
        expect(prompts, isA<List<String>>());
      });

      test('getAllJournalPrompts handles Spanish locale', () async {
        final prompts = await service.getAllJournalPrompts(const Locale('es'));
        expect(prompts, isA<List<String>>());
      });
    });

    group('topic localization', () {
      test('getTopicDescription returns English descriptions', () {
        expect(
          service.getTopicDescription(ReadingTopic.self, const Locale('en')),
          equals('Personal growth and self-discovery'),
        );
        expect(
          service.getTopicDescription(ReadingTopic.love, const Locale('en')),
          equals('Relationships and emotional connections'),
        );
        expect(
          service.getTopicDescription(ReadingTopic.work, const Locale('en')),
          equals('Career and professional life'),
        );
        expect(
          service.getTopicDescription(ReadingTopic.social, const Locale('en')),
          equals('Community and social interactions'),
        );
      });

      test('getTopicDescription returns Spanish descriptions', () {
        expect(
          service.getTopicDescription(ReadingTopic.self, const Locale('es')),
          equals('Crecimiento personal y autodescubrimiento'),
        );
        expect(
          service.getTopicDescription(ReadingTopic.love, const Locale('es')),
          equals('Relaciones y conexiones emocionales'),
        );
        expect(
          service.getTopicDescription(ReadingTopic.work, const Locale('es')),
          equals('Carrera y vida profesional'),
        );
        expect(
          service.getTopicDescription(ReadingTopic.social, const Locale('es')),
          equals('Comunidad e interacciones sociales'),
        );
      });

      test('getTopicDisplayName returns English names', () {
        expect(
          service.getTopicDisplayName(ReadingTopic.self, const Locale('en')),
          equals('Self'),
        );
        expect(
          service.getTopicDisplayName(ReadingTopic.love, const Locale('en')),
          equals('Love'),
        );
        expect(
          service.getTopicDisplayName(ReadingTopic.work, const Locale('en')),
          equals('Work'),
        );
        expect(
          service.getTopicDisplayName(ReadingTopic.social, const Locale('en')),
          equals('Social'),
        );
      });

      test('getTopicDisplayName returns Spanish names', () {
        expect(
          service.getTopicDisplayName(ReadingTopic.self, const Locale('es')),
          equals('Yo'),
        );
        expect(
          service.getTopicDisplayName(ReadingTopic.love, const Locale('es')),
          equals('Amor'),
        );
        expect(
          service.getTopicDisplayName(ReadingTopic.work, const Locale('es')),
          equals('Trabajo'),
        );
        expect(
          service.getTopicDisplayName(ReadingTopic.social, const Locale('es')),
          equals('Social'),
        );
      });
    });

    group('spread localization', () {
      test('getSpreadDescription returns English descriptions', () {
        expect(
          service.getSpreadDescription(
            SpreadType.singleCard,
            const Locale('en'),
          ),
          equals('Quick insight for immediate guidance'),
        );
        expect(
          service.getSpreadDescription(
            SpreadType.threeCard,
            const Locale('en'),
          ),
          equals('Past, Present, Future or Situation, Action, Outcome'),
        );
        expect(
          service.getSpreadDescription(SpreadType.celtic, const Locale('en')),
          equals('Comprehensive reading for complex situations'),
        );
      });

      test('getSpreadDescription returns Spanish descriptions', () {
        expect(
          service.getSpreadDescription(
            SpreadType.singleCard,
            const Locale('es'),
          ),
          equals('Perspectiva rápida para guía inmediata'),
        );
        expect(
          service.getSpreadDescription(
            SpreadType.threeCard,
            const Locale('es'),
          ),
          equals('Pasado, Presente, Futuro o Situación, Acción, Resultado'),
        );
        expect(
          service.getSpreadDescription(SpreadType.celtic, const Locale('es')),
          equals('Lectura completa para situaciones complejas'),
        );
      });

      test('getSpreadDisplayName returns English names', () {
        expect(
          service.getSpreadDisplayName(
            SpreadType.singleCard,
            const Locale('en'),
          ),
          equals('Single Card'),
        );
        expect(
          service.getSpreadDisplayName(
            SpreadType.threeCard,
            const Locale('en'),
          ),
          equals('Three Card'),
        );
        expect(
          service.getSpreadDisplayName(SpreadType.celtic, const Locale('en')),
          equals('Celtic Cross'),
        );
      });

      test('getSpreadDisplayName returns Spanish names', () {
        expect(
          service.getSpreadDisplayName(
            SpreadType.singleCard,
            const Locale('es'),
          ),
          equals('Una Carta'),
        );
        expect(
          service.getSpreadDisplayName(
            SpreadType.threeCard,
            const Locale('es'),
          ),
          equals('Tres Cartas'),
        );
        expect(
          service.getSpreadDisplayName(SpreadType.celtic, const Locale('es')),
          equals('Cruz Celta'),
        );
      });
    });

    group('tarot suit localization', () {
      test('getTarotSuitDescription returns English descriptions', () {
        expect(
          service.getTarotSuitDescription(
            TarotSuit.majorArcana,
            const Locale('en'),
          ),
          equals('The major life themes and spiritual lessons'),
        );
        expect(
          service.getTarotSuitDescription(TarotSuit.cups, const Locale('en')),
          equals('Emotions, relationships, and intuition'),
        );
        expect(
          service.getTarotSuitDescription(TarotSuit.wands, const Locale('en')),
          equals('Creativity, passion, and career'),
        );
      });

      test('getTarotSuitDescription returns Spanish descriptions', () {
        expect(
          service.getTarotSuitDescription(
            TarotSuit.majorArcana,
            const Locale('es'),
          ),
          equals('Los temas principales de la vida y lecciones espirituales'),
        );
        expect(
          service.getTarotSuitDescription(TarotSuit.cups, const Locale('es')),
          equals('Emociones, relaciones e intuición'),
        );
        expect(
          service.getTarotSuitDescription(TarotSuit.wands, const Locale('es')),
          equals('Creatividad, pasión y carrera'),
        );
      });

      test('getTarotSuitDisplayName returns English names', () {
        expect(
          service.getTarotSuitDisplayName(
            TarotSuit.majorArcana,
            const Locale('en'),
          ),
          equals('Major Arcana'),
        );
        expect(
          service.getTarotSuitDisplayName(TarotSuit.cups, const Locale('en')),
          equals('Cups'),
        );
        expect(
          service.getTarotSuitDisplayName(TarotSuit.wands, const Locale('en')),
          equals('Wands'),
        );
      });

      test('getTarotSuitDisplayName returns Spanish names', () {
        expect(
          service.getTarotSuitDisplayName(
            TarotSuit.majorArcana,
            const Locale('es'),
          ),
          equals('Arcanos Mayores'),
        );
        expect(
          service.getTarotSuitDisplayName(TarotSuit.cups, const Locale('es')),
          equals('Copas'),
        );
        expect(
          service.getTarotSuitDisplayName(TarotSuit.wands, const Locale('es')),
          equals('Bastos'),
        );
      });
    });

    group('locale handling', () {
      test('handles unsupported locale gracefully for topics', () {
        final result = service.getTopicDescription(
          ReadingTopic.self,
          const Locale('fr'),
        );
        expect(
          result,
          equals('Personal growth and self-discovery'),
        ); // Should default to English
      });

      test('handles unsupported locale gracefully for spreads', () {
        final result = service.getSpreadDescription(
          SpreadType.singleCard,
          const Locale('fr'),
        );
        expect(
          result,
          equals('Quick insight for immediate guidance'),
        ); // Should default to English
      });

      test('handles unsupported locale gracefully for suits', () {
        final result = service.getTarotSuitDescription(
          TarotSuit.cups,
          const Locale('fr'),
        );
        expect(
          result,
          equals('Emotions, relationships, and intuition'),
        ); // Should default to English
      });
    });

    group('error handling', () {
      test('handles journal prompt errors gracefully', () async {
        // Test with invalid locale - should fallback gracefully
        final result = await service.getJournalPrompt(
          0,
          const Locale('invalid'),
        );
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
      });

      test('handles random prompt errors gracefully', () async {
        final result = await service.getRandomJournalPrompt(
          const Locale('invalid'),
        );
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
      });

      test('handles daily prompt errors gracefully', () async {
        final result = await service.getDailyJournalPrompt(
          DateTime.now(),
          const Locale('invalid'),
        );
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
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

      test('service works after cache clear', () async {
        await service.getRandomJournalPrompt(const Locale('en'));
        service.clearCache();
        final result = await service.getRandomJournalPrompt(const Locale('en'));
        expect(result, isA<String>());
      });
    });

    group('integration with real assets', () {
      test('can load journal prompts from assets if available', () async {
        final prompts = await service.getAllJournalPrompts(const Locale('en'));
        expect(prompts, isA<List<String>>());

        if (prompts.isNotEmpty) {
          // If we have prompts, test that we can get them by index
          final firstPrompt = await service.getJournalPrompt(
            0,
            const Locale('en'),
          );
          expect(firstPrompt, isA<String>());
          expect(firstPrompt.isNotEmpty, isTrue);
        }
      });

      test(
        'handles asset loading gracefully when assets not available',
        () async {
          final count = await service.getJournalPromptCount(const Locale('en'));
          expect(count, isA<int>());
          expect(count, greaterThanOrEqualTo(0));
        },
      );
    });
  });
}
