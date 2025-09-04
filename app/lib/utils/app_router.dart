import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/pages.dart';
import '../pages/subscription_management_page.dart';
import '../models/enums.dart';
import '../widgets/main_scaffold.dart';
import 'constants.dart';

/// App router configuration using go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.homeRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            name: 'home',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const HomePage()),
          ),
          GoRoute(
            path: AppConstants.readingsRoute,
            name: 'readings',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const ReadingsPage()),
          ),
          GoRoute(
            path: AppConstants.interpretationsRoute,
            name: 'interpretations',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const InterpretationsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.yourselfRoute,
            name: 'yourself',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const YourselfPage()),
          ),
          GoRoute(
            path: AppConstants.friendsRoute,
            name: 'friends',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const FriendsPage()),
          ),
          GoRoute(
            path: AppConstants.settingsRoute,
            name: 'settings',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const SettingsPage()),
          ),
          GoRoute(
            path: AppConstants.guideSelectionRoute,
            name: 'guide-selection',
            pageBuilder: (context, state) {
              final topicParam = state.uri.queryParameters['topic'];
              final topic = topicParam != null
                  ? ReadingTopic.fromString(topicParam)
                  : ReadingTopic.self;
              return _buildPageWithTransition(
                context,
                state,
                GuideSelectionPage(topic: topic),
              );
            },
          ),
          GoRoute(
            path: AppConstants.spreadSelectionRoute,
            name: 'spread-selection',
            pageBuilder: (context, state) {
              final topicParam = state.uri.queryParameters['topic'];
              final guideParam = state.uri.queryParameters['guide'];
              final topic = topicParam != null
                  ? ReadingTopic.fromString(topicParam)
                  : ReadingTopic.self;
              final guide = guideParam != null
                  ? GuideType.fromString(guideParam)
                  : null;
              return _buildPageWithTransition(
                context,
                state,
                SpreadSelectionPage(topic: topic, selectedGuide: guide),
              );
            },
          ),
          GoRoute(
            path: AppConstants.subscriptionManagementRoute,
            name: 'subscription-management',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const SubscriptionManagementPage(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Build page with smooth transition animation
  static Page<void> _buildPageWithTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(
        milliseconds: AppConstants.animationDurationMs,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth fade transition
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

/// Navigation helper methods
extension AppRouterExtension on BuildContext {
  /// Navigate to home page
  void goHome() => go(AppConstants.homeRoute);

  /// Navigate to readings page
  void goReadings() => go(AppConstants.readingsRoute);

  /// Navigate to guide selection page
  void goGuideSelection(ReadingTopic topic) =>
      go('${AppConstants.guideSelectionRoute}?topic=${topic.name}');

  /// Navigate to spread selection page
  void goSpreadSelection(ReadingTopic topic, {GuideType? selectedGuide}) {
    final uri = selectedGuide != null
        ? '${AppConstants.spreadSelectionRoute}?topic=${topic.name}&guide=${selectedGuide.name}'
        : '${AppConstants.spreadSelectionRoute}?topic=${topic.name}';
    go(uri);
  }

  /// Navigate to interpretations page
  void goInterpretations() => go(AppConstants.interpretationsRoute);

  /// Navigate to yourself page
  void goYourself() => go(AppConstants.yourselfRoute);

  /// Navigate to friends page
  void goFriends() => go(AppConstants.friendsRoute);

  /// Navigate to settings page
  void goSettings() => go(AppConstants.settingsRoute);

  /// Navigate to subscription management page
  void goSubscriptionManagement() =>
      go(AppConstants.subscriptionManagementRoute);

  /// Get current route path
  String get currentRoute => GoRouterState.of(this).uri.path;
}
