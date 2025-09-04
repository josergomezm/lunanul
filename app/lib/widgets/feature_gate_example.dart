import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../services/subscription_feature_gate_service.dart';

/// Example widget demonstrating how to use the FeatureGateService
class FeatureGateExample extends ConsumerWidget {
  const FeatureGateExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Gate Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Access Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Spread Access Example
            _buildFeatureSection('Spread Access', [
              _SpreadAccessTile(SpreadType.singleCard),
              _SpreadAccessTile(SpreadType.threeCard),
              _SpreadAccessTile(SpreadType.celtic),
              _SpreadAccessTile(SpreadType.career),
            ]),

            const SizedBox(height: 16),

            // Guide Access Example
            _buildFeatureSection('Guide Access', [
              _GuideAccessTile(GuideType.healer),
              _GuideAccessTile(GuideType.mentor),
              _GuideAccessTile(GuideType.sage),
              _GuideAccessTile(GuideType.visionary),
            ]),

            const SizedBox(height: 16),

            // Usage-based Features
            _buildFeatureSection('Usage-based Features', [
              const _UsageFeatureTile(
                'Manual Interpretations',
                'manual_interpretations',
              ),
              const _UsageFeatureTile('Readings', 'readings'),
            ]),

            const SizedBox(height: 16),

            // Premium Features
            _buildFeatureSection('Premium Features', [
              const _PremiumFeatureTile(
                'Audio Readings',
                SubscriptionFeatureGateService.audioReadingFeature,
              ),
              const _PremiumFeatureTile(
                'Customization',
                SubscriptionFeatureGateService.customizationFeature,
              ),
              const _PremiumFeatureTile(
                'Early Access',
                SubscriptionFeatureGateService.earlyAccessFeature,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _SpreadAccessTile extends ConsumerWidget {
  const _SpreadAccessTile(this.spread);

  final SpreadType spread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, you would get the FeatureGateService from a provider
    // For this example, we'll create a mock service
    return FutureBuilder<bool>(
      future: _checkSpreadAccess(),
      builder: (context, snapshot) {
        final hasAccess = snapshot.data ?? false;
        return ListTile(
          leading: Icon(
            hasAccess ? Icons.check_circle : Icons.lock,
            color: hasAccess ? Colors.green : Colors.grey,
          ),
          title: Text(spread.displayName),
          subtitle: Text('${spread.cardCount} cards - ${spread.description}'),
          trailing: hasAccess
              ? null
              : TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  child: const Text('Upgrade'),
                ),
        );
      },
    );
  }

  Future<bool> _checkSpreadAccess() async {
    // Mock implementation - in real app, use actual FeatureGateService
    switch (spread) {
      case SpreadType.singleCard:
      case SpreadType.threeCard:
        return true;
      default:
        return false;
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Required'),
        content: Text(
          '${spread.displayName} requires a Mystic or Oracle subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription page
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _GuideAccessTile extends ConsumerWidget {
  const _GuideAccessTile(this.guide);

  final GuideType guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkGuideAccess(),
      builder: (context, snapshot) {
        final hasAccess = snapshot.data ?? false;
        return ListTile(
          leading: Icon(
            hasAccess ? Icons.check_circle : Icons.lock,
            color: hasAccess ? Colors.green : Colors.grey,
          ),
          title: Text('${guide.guideName} - ${guide.title}'),
          subtitle: Text(guide.expertise),
          trailing: hasAccess
              ? null
              : TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  child: const Text('Upgrade'),
                ),
        );
      },
    );
  }

  Future<bool> _checkGuideAccess() async {
    // Mock implementation - in real app, use actual FeatureGateService
    switch (guide) {
      case GuideType.healer:
      case GuideType.mentor:
        return true;
      default:
        return false;
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Required'),
        content: Text(
          '${guide.guideName} requires a Mystic or Oracle subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription page
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _UsageFeatureTile extends ConsumerWidget {
  const _UsageFeatureTile(this.featureName, this.usageKey);

  final String featureName;
  final String usageKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUsageInfo(),
      builder: (context, snapshot) {
        final usageInfo = snapshot.data;
        if (usageInfo == null) {
          return ListTile(
            leading: const CircularProgressIndicator(),
            title: Text(featureName),
          );
        }

        final current = usageInfo['current'] as int;
        final limit = usageInfo['limit'] as int?;
        final unlimited = usageInfo['unlimited'] as bool;
        final reachedLimit = usageInfo['reached_limit'] as bool;

        return ListTile(
          leading: Icon(
            reachedLimit ? Icons.warning : Icons.info,
            color: reachedLimit ? Colors.orange : Colors.blue,
          ),
          title: Text(featureName),
          subtitle: unlimited
              ? const Text('Unlimited usage')
              : Text('$current / $limit used this month'),
          trailing: reachedLimit
              ? TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  child: const Text('Upgrade'),
                )
              : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUsageInfo() async {
    // Mock implementation - in real app, use actual FeatureGateService
    if (usageKey == 'manual_interpretations') {
      return {
        'current': 3,
        'limit': 5,
        'unlimited': false,
        'reached_limit': false,
      };
    } else {
      return {
        'current': 1,
        'limit': 3,
        'unlimited': false,
        'reached_limit': false,
      };
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usage Limit Reached'),
        content: Text(
          'You\'ve reached your monthly limit for $featureName. Upgrade to get unlimited access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription page
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureTile extends ConsumerWidget {
  const _PremiumFeatureTile(this.featureName, this.featureKey);

  final String featureName;
  final String featureKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkFeatureAccess(),
      builder: (context, snapshot) {
        final hasAccess = snapshot.data ?? false;
        return ListTile(
          leading: Icon(
            hasAccess ? Icons.check_circle : Icons.lock,
            color: hasAccess ? Colors.green : Colors.grey,
          ),
          title: Text(featureName),
          subtitle: hasAccess
              ? const Text('Available')
              : const Text('Requires Oracle subscription'),
          trailing: hasAccess
              ? null
              : TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  child: const Text('Upgrade'),
                ),
        );
      },
    );
  }

  Future<bool> _checkFeatureAccess() async {
    // Mock implementation - in real app, use actual FeatureGateService
    return false; // Assume free tier for demo
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text('$featureName is available with an Oracle subscription.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription page
            },
            child: const Text('Upgrade to Oracle'),
          ),
        ],
      ),
    );
  }
}
