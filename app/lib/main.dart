import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'utils/app_router.dart';
import 'utils/date_time_localizations.dart';
import 'providers/providers.dart';
import 'services/image_cache_service.dart';
import 'widgets/image_preloader_widget.dart';
import 'widgets/loading_animations.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date/time locale data
  await DateTimeLocalizations.initializeLocaleData();

  // Initialize image cache service
  ImageCacheService().initialize();

  runApp(
    ProviderScope(
      observers: [
        if (ProviderScopeConfig.getProviderObserver() != null)
          ProviderScopeConfig.getProviderObserver()!,
      ],
      overrides: ProviderScopeConfig.getOverrides(),
      child: const LunanulApp(),
    ),
  );
}

class LunanulApp extends ConsumerWidget {
  const LunanulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider for dynamic theme switching
    final themeMode = ref.watch(themeProvider);

    // Watch current language for locale updates
    final currentLocale = ref.watch(languageProvider);

    // Initialize language on app start
    ref.listen(languageInitializationProvider, (previous, next) {
      // Language initialization is handled automatically by the provider
    });

    // Initialize subscription system
    ref.listen(subscriptionProvider, (previous, next) {
      // Subscription status changes are handled automatically
    });

    // Initialize subscription onboarding
    ref.listen(subscriptionOnboardingProvider, (previous, next) {
      // Onboarding state changes are handled automatically
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeMode),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,

      // Localization configuration
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: currentLocale,
      localeResolutionCallback: _resolveLocale,

      builder: (context, child) {
        return ImagePreloaderWidget(
          preloadEssentials: true,
          child: AppWrapper(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }

  /// Convert string theme mode to ThemeMode enum
  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'auto':
      default:
        return ThemeMode.system;
    }
  }

  /// Resolve locale with proper fallback handling
  Locale? _resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    // If no locale is provided, return null to use system default
    if (locale == null) {
      return null;
    }

    // Check if the exact locale is supported
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }

    // Check if the language code is supported (ignore country code)
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    // Fallback to English if the locale is not supported
    return const Locale('en');
  }
}

/// Wrapper widget that handles global app state and error handling
class AppWrapper extends ConsumerWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for global app errors
    final appError = ref.watch(appErrorProvider);
    final isLoading = ref.watch(appLoadingProvider);

    return Stack(
      children: [
        // Main app content
        child,

        // Global loading overlay
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CalmingLoadingAnimation(size: 64, message: 'Loading...'),
            ),
          ),

        // Global error snackbar
        if (appError != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(appStateProvider.notifier).clearError(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
