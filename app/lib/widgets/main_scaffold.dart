import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../l10n/generated/app_localizations.dart';
import 'custom_icon.dart';

/// Main scaffold with bottom navigation bar
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const BottomNavBar());
  }
}

/// Custom bottom navigation bar with large icons and overlaid text
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final currentLocation = GoRouterState.of(context).uri.path;
    final currentIndex = _getSelectedIndex(currentLocation);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            isSelected: currentIndex == 0,
            iconPath: currentIndex == 0
                ? NavIcons.homeFilled
                : NavIcons.homeOutlined,
            label: localizations.navigationHome,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            isSelected: currentIndex == 1,
            iconPath: currentIndex == 1
                ? NavIcons.readingsFilled
                : NavIcons.readingsOutlined,
            label: localizations.navigationReadings,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            isSelected: currentIndex == 2,
            iconPath: currentIndex == 2
                ? NavIcons.manualFilled
                : NavIcons.manualOutlined,
            label: localizations.navigationManual,
          ),
          _buildNavItem(
            context: context,
            index: 3,
            isSelected: currentIndex == 3,
            iconPath: currentIndex == 3
                ? NavIcons.yourselfFilled
                : NavIcons.yourselfOutlined,
            label: localizations.navigationYourself,
          ),
          _buildNavItem(
            context: context,
            index: 4,
            isSelected: currentIndex == 4,
            iconPath: currentIndex == 4
                ? NavIcons.friendsFilled
                : NavIcons.friendsOutlined,
            label: localizations.navigationFriends,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required bool isSelected,
    required String iconPath,
    required String label,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Large background icon
              CustomIcon(
                assetPath: iconPath,
                size: 100,
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3)
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
              ),
              // Overlaid text
              Text(
                label,
                style: isSelected
                    ? Theme.of(
                        context,
                      ).bottomNavigationBarTheme.selectedLabelStyle
                    : Theme.of(
                        context,
                      ).bottomNavigationBarTheme.unselectedLabelStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the selected index based on current route
  int _getSelectedIndex(String location) {
    switch (location) {
      case AppConstants.homeRoute:
        return 0;
      case AppConstants.readingsRoute:
        return 1;
      case AppConstants.interpretationsRoute:
        return 2;
      case AppConstants.yourselfRoute:
        return 3;
      case AppConstants.friendsRoute:
        return 4;
      default:
        return 0;
    }
  }

  /// Handle navigation bar item tap
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.homeRoute);
        break;
      case 1:
        context.go(AppConstants.readingsRoute);
        break;
      case 2:
        context.go(AppConstants.interpretationsRoute);
        break;
      case 3:
        context.go(AppConstants.yourselfRoute);
        break;
      case 4:
        context.go(AppConstants.friendsRoute);
        break;
    }
  }
}
