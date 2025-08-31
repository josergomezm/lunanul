import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunanul/providers/language_provider.dart';
import 'package:lunanul/services/language_service.dart';

void main() {
  group('LanguageNotifier', () {
    late ProviderContainer container;
    setUp(() {
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with English locale by default', () {
      final currentLocale = container.read(languageProvider);

      expect(currentLocale, equals(const Locale('en')));
    });

    test('should initialize with saved language preference', () async {
      // Set up SharedPreferences with Spanish preference
      SharedPreferences.setMockInitialValues({'selected_language': 'es'});

      final languageNotifier = container.read(languageProvider.notifier);
      await languageNotifier.initialize();

      final currentLocale = container.read(languageProvider);
      expect(currentLocale, equals(const Locale('es')));
    });

    test('should change language and persist choice', () async {
      final languageNotifier = container.read(languageProvider.notifier);

      await languageNotifier.changeLanguage(const Locale('es'));

      final currentLocale = container.read(languageProvider);
      expect(currentLocale, equals(const Locale('es')));

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), equals('es'));
    });

    test('should throw error for unsupported locale', () async {
      final languageNotifier = container.read(languageProvider.notifier);

      expect(
        () => languageNotifier.changeLanguage(const Locale('fr')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should return supported locales', () {
      final languageNotifier = container.read(languageProvider.notifier);
      final supportedLocales = languageNotifier.getSupportedLocales();

      expect(supportedLocales, contains(const Locale('en')));
      expect(supportedLocales, contains(const Locale('es')));
      expect(supportedLocales.length, equals(2));
    });

    test('should check if locale is supported', () {
      final languageNotifier = container.read(languageProvider.notifier);

      expect(languageNotifier.isSupported(const Locale('en')), isTrue);
      expect(languageNotifier.isSupported(const Locale('es')), isTrue);
      expect(languageNotifier.isSupported(const Locale('fr')), isFalse);
    });

    test('should reset to device locale', () async {
      final languageNotifier = container.read(languageProvider.notifier);

      // First change to Spanish
      await languageNotifier.changeLanguage(const Locale('es'));
      expect(container.read(languageProvider), equals(const Locale('es')));

      // Reset to device locale (should be English in test environment)
      await languageNotifier.resetToDeviceLocale();
      final currentLocale = container.read(languageProvider);
      expect(currentLocale, equals(const Locale('en')));
    });

    test('should clear saved language preference', () async {
      final languageNotifier = container.read(languageProvider.notifier);

      // Set Spanish preference
      await languageNotifier.changeLanguage(const Locale('es'));
      expect(container.read(languageProvider), equals(const Locale('es')));

      // Clear preference
      await languageNotifier.clearSavedLanguage();

      // Should reset to device locale (English in test)
      final currentLocale = container.read(languageProvider);
      expect(currentLocale, equals(const Locale('en')));

      // Verify preference is cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), isNull);
    });
  });

  group('Language Providers', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('languageServiceProvider should provide LanguageService instance', () {
      final languageService = container.read(languageServiceProvider);
      expect(languageService, isA<LanguageService>());
    });

    test('currentLanguageCodeProvider should return current language code', () {
      final languageCode = container.read(currentLanguageCodeProvider);
      expect(languageCode, equals('en'));
    });

    test('isSpanishProvider should return false for English', () {
      final isSpanish = container.read(isSpanishProvider);
      expect(isSpanish, isFalse);
    });

    test('isEnglishProvider should return true for English', () {
      final isEnglish = container.read(isEnglishProvider);
      expect(isEnglish, isTrue);
    });

    test(
      'isSpanishProvider should return true after changing to Spanish',
      () async {
        final languageNotifier = container.read(languageProvider.notifier);
        await languageNotifier.changeLanguage(const Locale('es'));

        final isSpanish = container.read(isSpanishProvider);
        final isEnglish = container.read(isEnglishProvider);

        expect(isSpanish, isTrue);
        expect(isEnglish, isFalse);
      },
    );

    test('supportedLocalesProvider should return supported locales', () {
      final supportedLocales = container.read(supportedLocalesProvider);

      expect(supportedLocales, contains(const Locale('en')));
      expect(supportedLocales, contains(const Locale('es')));
      expect(supportedLocales.length, equals(2));
    });

    test(
      'languageInitializationProvider should complete successfully',
      () async {
        final initializationFuture = container.read(
          languageInitializationProvider.future,
        );

        await expectLater(initializationFuture, completes);
      },
    );
  });

  group('Localization Providers', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('tarotCardLocalizationsProvider should provide service instance', () {
      final service = container.read(tarotCardLocalizationsProvider);
      expect(service, isNotNull);
    });

    test(
      'dynamicContentLocalizationsProvider should provide service instance',
      () {
        final service = container.read(dynamicContentLocalizationsProvider);
        expect(service, isNotNull);
      },
    );

    test(
      'localizedCardNameProvider should return card name for given ID',
      () async {
        final cardNameFuture = container.read(
          localizedCardNameProvider('fool').future,
        );
        final cardName = await cardNameFuture;
        expect(cardName, isNotNull);
        expect(cardName, isA<String>());
      },
    );

    test(
      'localizedCardUprightMeaningProvider should return upright meaning',
      () async {
        final meaningFuture = container.read(
          localizedCardUprightMeaningProvider('fool').future,
        );
        final meaning = await meaningFuture;
        expect(meaning, isNotNull);
        expect(meaning, isA<String>());
      },
    );

    test(
      'localizedCardReversedMeaningProvider should return reversed meaning',
      () async {
        final meaningFuture = container.read(
          localizedCardReversedMeaningProvider('fool').future,
        );
        final meaning = await meaningFuture;
        expect(meaning, isNotNull);
        expect(meaning, isA<String>());
      },
    );

    test('localizedCardKeywordsProvider should return keywords list', () async {
      final keywordsFuture = container.read(
        localizedCardKeywordsProvider('fool').future,
      );
      final keywords = await keywordsFuture;
      expect(keywords, isNotNull);
      expect(keywords, isA<List<String>>());
    });

    test(
      'localizedJournalPromptProvider should return journal prompt',
      () async {
        final promptFuture = container.read(
          localizedJournalPromptProvider(0).future,
        );
        final prompt = await promptFuture;
        expect(prompt, isNotNull);
        expect(prompt, isA<String>());
      },
    );
  });

  group('Language State Management Integration', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'should update all dependent providers when language changes',
      () async {
        final languageNotifier = container.read(languageProvider.notifier);

        // Initial state (English)
        expect(container.read(currentLanguageCodeProvider), equals('en'));
        expect(container.read(isEnglishProvider), isTrue);
        expect(container.read(isSpanishProvider), isFalse);

        // Change to Spanish
        await languageNotifier.changeLanguage(const Locale('es'));

        // Verify all providers updated
        expect(container.read(currentLanguageCodeProvider), equals('es'));
        expect(container.read(isEnglishProvider), isFalse);
        expect(container.read(isSpanishProvider), isTrue);
      },
    );

    test(
      'should maintain state consistency across provider rebuilds',
      () async {
        final languageNotifier = container.read(languageProvider.notifier);

        // Change language multiple times
        await languageNotifier.changeLanguage(const Locale('es'));
        await languageNotifier.changeLanguage(const Locale('en'));
        await languageNotifier.changeLanguage(const Locale('es'));

        // Verify final state is consistent
        expect(container.read(languageProvider), equals(const Locale('es')));
        expect(container.read(currentLanguageCodeProvider), equals('es'));
        expect(container.read(isSpanishProvider), isTrue);
      },
    );

    test(
      'should handle initialization with saved preference correctly',
      () async {
        // Set up with Spanish preference
        SharedPreferences.setMockInitialValues({'selected_language': 'es'});

        final newContainer = ProviderContainer();
        final languageNotifier = newContainer.read(languageProvider.notifier);

        // Initialize
        await languageNotifier.initialize();

        // Verify Spanish is loaded
        expect(newContainer.read(languageProvider), equals(const Locale('es')));
        expect(newContainer.read(isSpanishProvider), isTrue);

        newContainer.dispose();
      },
    );

    test('should handle errors gracefully during language changes', () async {
      final languageNotifier = container.read(languageProvider.notifier);

      // Try to change to unsupported language
      expect(
        () => languageNotifier.changeLanguage(const Locale('fr')),
        throwsA(isA<ArgumentError>()),
      );

      // Verify state remains unchanged
      expect(container.read(languageProvider), equals(const Locale('en')));
      expect(container.read(isEnglishProvider), isTrue);
    });
  });
}
