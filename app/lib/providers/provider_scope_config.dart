import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/card_service.dart';
import '../services/mock_reading_service.dart';
import '../services/mock_user_service.dart';
import '../services/mock_subscription_service.dart';
import '../services/mock_ad_service.dart';
import '../services/shared_preferences_usage_tracking_service.dart';
import 'providers.dart';

/// Configuration for provider overrides and dependency injection
class ProviderScopeConfig {
  /// Get provider overrides for testing or different environments
  static List<Override> getOverrides({
    CardService? cardService,
    MockReadingService? readingService,
    MockUserService? userService,
    MockSubscriptionService? subscriptionService,
    MockAdService? adService,
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

    // Subscription service overrides
    if (subscriptionService != null) {
      overrides.add(
        subscriptionServiceProvider.overrideWithValue(subscriptionService),
      );
    }

    if (adService != null) {
      overrides.add(adServiceProvider.overrideWithValue(adService));
    }

    return overrides;
  }

  /// Provider observer for logging provider changes in debug mode
  static ProviderObserver? getProviderObserver() {
    return ProviderLogger();
  }
}

/// Logger for provider state changes (debug mode only)
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider updated: ${provider.name ?? provider.runtimeType}',
      name: 'ProviderLogger',
    );
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider added: ${provider.name ?? provider.runtimeType}',
      name: 'ProviderLogger',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider disposed: ${provider.name ?? provider.runtimeType}',
      name: 'ProviderLogger',
    );
  }

  /// Get provider overrides for testing with mock services
  static List<Override> getTestOverrides() {
    return [
      // Override with fresh instances for testing
      // cardServiceProvider.overrideWithValue(CardService.instance),
      // readingServiceProvider.overrideWithValue(MockReadingService.instance),
      // userServiceProvider.overrideWithValue(MockUserService.instance),

      // Subscription service overrides for testing
      // subscriptionServiceProvider.overrideWithValue(MockSubscriptionService()),
      // adServiceProvider.overrideWithValue(MockAdService()),
      // usageTrackingServiceProvider.overrideWithValue(
      //   SharedPreferencesUsageTrackingService(),
      // ),
      // featureGateServiceProvider.overrideWith(
      //   (ref) => SubscriptionFeatureGateService(
      //     usageTrackingService: ref.watch(usageTrackingServiceProvider),
      //   ),
      // ),
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

      // Initialize subscription system
      container.read(subscriptionProvider);

      // Initialize usage tracking
      container.read(usageTrackingNotifierProvider);

      // Initialize feature gate service
      container.read(featureGateServiceProvider);

      // Initialize subscription onboarding
      // container.read(subscriptionOnboardingNotifierProvider);
    } catch (e) {
      // Handle initialization errors gracefully
      developer.log(
        'Provider initialization warning: $e',
        name: 'ProviderScopeConfig',
      );
    }
  }

  /// Dispose of providers that need cleanup
  static void disposeProviders(ProviderContainer container) {
    // Clear card service cache
    CardService.instance.clearCache();

    // Clear user service data (for testing)
    MockUserService.instance.clearUserData();

    // Clear subscription service data (for testing)
    final subscriptionService = container.read(subscriptionServiceProvider);
    if (subscriptionService is MockSubscriptionService) {
      // Reset subscription service if it has a reset method
      // subscriptionService.reset();
    }

    // Clear usage tracking data (for testing)
    final usageService = container.read(usageTrackingServiceProvider);
    if (usageService is SharedPreferencesUsageTrackingService) {
      usageService.clearAllUsage();
    }
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
      subscriptionProvider,
      subscriptionProductsProvider,
      subscriptionHealthProvider,
    ]);
  }

  /// Refresh subscription-related providers
  void refreshSubscriptionData() {
    invalidateAll([
      subscriptionProvider,
      subscriptionProductsProvider,
      subscriptionHealthProvider,
      usageTrackingNotifierProvider,
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
