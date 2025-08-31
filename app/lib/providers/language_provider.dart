import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';
import '../services/tarot_card_localizations.dart';
import '../services/dynamic_content_localizations.dart';

/// State notifier for language management
class LanguageNotifier extends StateNotifier<Locale> {
  final LanguageService _languageService;

  LanguageNotifier(this._languageService) : super(const Locale('en'));

  /// Initialize language from saved preferences or device locale
  Future<void> initialize() async {
    try {
      final savedLanguage = await _languageService.getSavedLanguage();
      state = savedLanguage;
    } catch (e) {
      // If initialization fails, keep default English
      state = const Locale('en');
    }
  }

  /// Change the current language and persist the choice
  Future<void> changeLanguage(Locale newLocale) async {
    if (!_languageService.isSupported(newLocale)) {
      throw ArgumentError('Unsupported locale: ${newLocale.languageCode}');
    }

    try {
      await _languageService.saveLanguage(newLocale);
      state = newLocale;
    } catch (e) {
      throw Exception('Failed to change language: $e');
    }
  }

  /// Get the list of supported locales
  List<Locale> getSupportedLocales() {
    return _languageService.getSupportedLocales();
  }

  /// Check if a locale is supported
  bool isSupported(Locale locale) {
    return _languageService.isSupported(locale);
  }

  /// Reset to device locale
  Future<void> resetToDeviceLocale() async {
    try {
      final deviceLocale = _languageService.getDeviceLocale();
      if (_languageService.isSupported(deviceLocale)) {
        await changeLanguage(deviceLocale);
      } else {
        await changeLanguage(const Locale('en'));
      }
    } catch (e) {
      throw Exception('Failed to reset to device locale: $e');
    }
  }

  /// Clear saved language preference
  Future<void> clearSavedLanguage() async {
    try {
      await _languageService.clearSavedLanguage();
      final deviceLocale = _languageService.getDeviceLocale();
      if (_languageService.isSupported(deviceLocale)) {
        state = deviceLocale;
      } else {
        state = const Locale('en');
      }
    } catch (e) {
      throw Exception('Failed to clear saved language: $e');
    }
  }
}

/// Provider for the LanguageService
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

/// Provider for language state management
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final languageService = ref.read(languageServiceProvider);
  return LanguageNotifier(languageService);
});

/// Provider for TarotCardLocalizations service
final tarotCardLocalizationsProvider = Provider<TarotCardLocalizations>((ref) {
  return TarotCardLocalizations();
});

/// Provider for DynamicContentLocalizations service
final dynamicContentLocalizationsProvider =
    Provider<DynamicContentLocalizations>((ref) {
      return DynamicContentLocalizations();
    });

/// Provider for current language code as a string
final currentLanguageCodeProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).languageCode;
});

/// Provider for checking if current language is Spanish
final isSpanishProvider = Provider<bool>((ref) {
  return ref.watch(languageProvider).languageCode == 'es';
});

/// Provider for checking if current language is English
final isEnglishProvider = Provider<bool>((ref) {
  return ref.watch(languageProvider).languageCode == 'en';
});

/// Provider for supported locales list
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return LanguageService.supportedLocales;
});

/// Provider for language initialization status
final languageInitializationProvider = FutureProvider<void>((ref) async {
  final languageNotifier = ref.read(languageProvider.notifier);
  await languageNotifier.initialize();
});

/// Provider for getting localized tarot card name
final localizedCardNameProvider = FutureProvider.family<String, String>((
  ref,
  cardId,
) async {
  final locale = ref.watch(languageProvider);
  final tarotLocalizations = ref.read(tarotCardLocalizationsProvider);
  return await tarotLocalizations.getCardName(cardId, locale);
});

/// Provider for getting localized tarot card upright meaning
final localizedCardUprightMeaningProvider =
    FutureProvider.family<String, String>((ref, cardId) async {
      final locale = ref.watch(languageProvider);
      final tarotLocalizations = ref.read(tarotCardLocalizationsProvider);
      return await tarotLocalizations.getUprightMeaning(cardId, locale);
    });

/// Provider for getting localized tarot card reversed meaning
final localizedCardReversedMeaningProvider =
    FutureProvider.family<String, String>((ref, cardId) async {
      final locale = ref.watch(languageProvider);
      final tarotLocalizations = ref.read(tarotCardLocalizationsProvider);
      return await tarotLocalizations.getReversedMeaning(cardId, locale);
    });

/// Provider for getting localized tarot card keywords
final localizedCardKeywordsProvider =
    FutureProvider.family<List<String>, String>((ref, cardId) async {
      final locale = ref.watch(languageProvider);
      final tarotLocalizations = ref.read(tarotCardLocalizationsProvider);
      return await tarotLocalizations.getKeywords(cardId, locale);
    });

/// Provider for getting localized journal prompt
final localizedJournalPromptProvider = FutureProvider.family<String, int>((
  ref,
  index,
) async {
  final locale = ref.watch(languageProvider);
  final dynamicLocalizations = ref.read(dynamicContentLocalizationsProvider);
  return await dynamicLocalizations.getJournalPrompt(index, locale);
});
