import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/card_service.dart';
import '../services/mock_reading_service.dart';
import '../services/mock_user_service.dart';
import 'providers.dart';

/// Configuration for provider overrides and dependency injection
class ProviderScopeConfig {
  /// Get provider overrides for testing or different environments
  static List<Override> getOverrides({
    CardService? cardService,
    MockReadingService? readingService,
    MockUserService? userService,
  }) {
    final overrides = <Override>[];

    // Override services if provided (useful for testing)
    if (cardService != null) {
      overrides.add(cardServiceProvider.overrideWithValue(cardService));
    }

    if (readingService != null) {
      overrides.add(readingServiceProvider.overrideWithValue(readingService));
    }

    if (userService != null) {
      overrides.add(userServiceProvider.overrideWithValue(userService));
    }

    return overrides;
  }

  /// Get provider overrides for testing with mock services
  static List<Override> getTestOverrides() {
    return [
      // Override with fresh instances for testing
      cardServiceProvider.overrideWithValue(CardService.instance),
      readingServiceProvider.overrideWithValue(MockReadingService.instance),
      userServiceProvider.overrideWithValue(MockUserService.instance),
    ];
  }

  /// Initialize providers that need setup
  static Future<void> initializeProviders(ProviderContainer container) async {
    // Pre-warm critical providers
    try {
      // Load card data early
      await container.read(allCardsProvider.future);

      // Initialize user data
      await container.read(currentUserProvider.future);

      // Load card of the day
      await container.read(cardOfTheDayProvider.future);
    } catch (e) {
      // Handle initialization errors gracefully
      print('Provider initialization warning: $e');
    }
  }

  /// Dispose of providers that need cleanup
  static void disposeProviders(ProviderContainer container) {
    // Clear card service cache
    CardService.instance.clearCache();

    // Clear user service data (for testing)
    MockUserService.instance.clearUserData();
  }
}

/// Provider observer for debugging and logging
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Log provider updates in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print(
        'Provider ${provider.name ?? provider.runtimeType} updated: $newValue',
      );
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    // Log provider disposal in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('Provider ${provider.name ?? provider.runtimeType} disposed');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Log provider errors
    print('Provider ${provider.name ?? provider.runtimeType} failed: $error');
  }
}

/// Extension to add convenience methods to WidgetRef
extension WidgetRefExtensions on WidgetRef {
  /// Safely read a provider and handle errors
  T? readSafely<T>(ProviderListenable<T> provider) {
    try {
      return read(provider);
    } catch (e) {
      return null;
    }
  }

  /// Watch a provider and provide a fallback value on error
  T watchWithFallback<T>(ProviderListenable<T> provider, T fallback) {
    try {
      return watch(provider);
    } catch (e) {
      return fallback;
    }
  }

  /// Invalidate multiple providers at once
  void invalidateAll(List<ProviderBase> providers) {
    for (final provider in providers) {
      invalidate(provider);
    }
  }

  /// Refresh all data providers
  void refreshAllData() {
    invalidateAll([
      allCardsProvider,
      cardOfTheDayProvider,
      currentUserProvider,
      savedReadingsProvider,
      recentReadingsProvider,
      userStatisticsProvider,
    ]);
  }
}

/// Extension to add convenience methods to Ref
extension RefExtensions on Ref {
  /// Listen to multiple providers and combine their states
  void listenToMultiple<T>(
    List<ProviderListenable<T>> providers,
    void Function(T? previous, T next) listener,
  ) {
    for (final provider in providers) {
      listen(provider, listener);
    }
  }

  /// Invalidate and refresh a provider
  Future<T> refreshProvider<T>(FutureProvider<T> provider) async {
    invalidate(provider);
    return await read(provider.future);
  }
}
