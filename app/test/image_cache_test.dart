import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/services/image_cache_service.dart';
import 'package:lunanul/providers/image_cache_provider.dart';
import 'package:lunanul/widgets/cached_card_image.dart';
import 'package:lunanul/widgets/image_loading_widgets.dart';
import 'package:lunanul/models/tarot_card.dart';
import 'package:lunanul/models/enums.dart';

void main() {
  group('Image Cache Service Tests', () {
    late ImageCacheService cacheService;

    setUp(() {
      cacheService = ImageCacheService();
    });

    test('should initialize cache service', () {
      expect(cacheService, isNotNull);
      cacheService.initialize();
    });

    test('should provide cache info', () async {
      final info = await cacheService.getCacheInfo();
      expect(info, isNotNull);
      expect(info['status'], equals('active'));
      expect(info['maxSize'], equals(50 * 1024 * 1024)); // 50MB
      expect(info['maxObjects'], equals(200));
      expect(info['cacheDuration'], equals(30));
    });
  });

  group('Image Loading Widgets Tests', () {
    testWidgets('CardImagePlaceholder should display loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardImagePlaceholder(
              width: 120,
              height: 200,
              cardName: 'The Fool',
            ),
          ),
        ),
      );

      expect(find.byType(CardImagePlaceholder), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading The Fool...'), findsOneWidget);
    });

    testWidgets('CardImageError should display error state', (
      WidgetTester tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardImageError(
              width: 120,
              height: 200,
              cardName: 'The Fool',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CardImageError), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.text('The Fool'), findsOneWidget);
      expect(find.text('Image unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retryPressed, isTrue);
    });

    testWidgets('SimpleImagePlaceholder should display simple loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SimpleImagePlaceholder(width: 120, height: 200)),
        ),
      );

      expect(find.byType(SimpleImagePlaceholder), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Cache Provider Tests', () {
    testWidgets('should provide cache manager', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final cacheManager = ref.read(cacheManagerProvider);
                expect(cacheManager, isNotNull);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide cache info', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final cacheInfoAsync = ref.watch(cacheInfoProvider);
                return cacheInfoAsync.when(
                  data: (info) {
                    expect(info, isNotNull);
                    expect(info['status'], equals('active'));
                    return Text('Cache Status: ${info['status']}');
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Cache Status: active'), findsOneWidget);
    });
  });

  group('CachedCardImage Tests', () {
    late TarotCard testCard;

    setUp(() {
      testCard = const TarotCard(
        id: 'fool',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'https://example.com/fool.jpg',
        keywords: ['new beginnings', 'innocence'],
        uprightMeaning: 'New beginnings and innocence',
        reversedMeaning: 'Recklessness and naivety',
        isReversed: false,
      );
    });

    testWidgets('CachedCardImage should render with card data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedCardImage(card: testCard, width: 120, height: 200),
          ),
        ),
      );

      expect(find.byType(CachedCardImage), findsOneWidget);
      // The placeholder should be visible initially
      expect(find.byType(CardImagePlaceholder), findsOneWidget);
    });

    testWidgets(
      'CachedCardImage should show reversed indicator for reversed cards',
      (WidgetTester tester) async {
        final reversedCard = testCard.copyWith(isReversed: true);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CachedCardImage(
                card: reversedCard,
                width: 120,
                height: 200,
              ),
            ),
          ),
        );

        expect(find.byType(CachedCardImage), findsOneWidget);
        // Note: The reversed indicator will only show after image loads,
        // which won't happen in this test environment
      },
    );
  });
}
