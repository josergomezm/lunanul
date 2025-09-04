import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../utils/app_theme.dart';
import 'subscription_gate.dart';

/// Example widget demonstrating various uses of SubscriptionGate
class SubscriptionGateExample extends ConsumerWidget {
  const SubscriptionGateExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Gate Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(context, 'Feature Gates'),
            const SizedBox(height: AppTheme.spacingM),

            // Audio readings feature gate
            SubscriptionGate(
              featureKey: 'audio_reading',
              requiredTier: SubscriptionTier.oracle,
              child: _buildFeatureCard(
                context,
                'Audio Readings',
                'Listen to AI-generated interpretations',
                Icons.volume_up,
                AppTheme.softGold,
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Customization feature gate
            SubscriptionGate(
              featureKey: 'customization',
              requiredTier: SubscriptionTier.oracle,
              child: _buildFeatureCard(
                context,
                'Customization',
                'Personalize themes and card backs',
                Icons.palette,
                AppTheme.mysticPurple,
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),
            _buildSectionTitle(context, 'Spread Gates'),
            const SizedBox(height: AppTheme.spacingM),

            // Celtic Cross spread gate
            SubscriptionGate(
              featureKey: 'spread_access',
              gateType: GateType.spread,
              spreadType: SpreadType.celtic,
              child: _buildSpreadCard(context, SpreadType.celtic),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Career spread gate
            SubscriptionGate(
              featureKey: 'spread_access',
              gateType: GateType.spread,
              spreadType: SpreadType.career,
              child: _buildSpreadCard(context, SpreadType.career),
            ),

            const SizedBox(height: AppTheme.spacingL),
            _buildSectionTitle(context, 'Guide Gates'),
            const SizedBox(height: AppTheme.spacingM),

            // Sage guide gate
            SubscriptionGate(
              featureKey: 'guide_access',
              gateType: GateType.guide,
              guideType: GuideType.sage,
              child: _buildGuideCard(context, GuideType.sage),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Visionary guide gate
            SubscriptionGate(
              featureKey: 'guide_access',
              gateType: GateType.guide,
              guideType: GuideType.visionary,
              child: _buildGuideCard(context, GuideType.visionary),
            ),

            const SizedBox(height: AppTheme.spacingL),
            _buildSectionTitle(context, 'Action Gates'),
            const SizedBox(height: AppTheme.spacingM),

            // Manual interpretation action gate
            SubscriptionGate(
              featureKey: 'manual_interpretations',
              gateType: GateType.action,
              child: _buildActionCard(
                context,
                'Manual Interpretation',
                'Look up card meanings yourself',
                Icons.search,
                AppTheme.primaryPurple,
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Reading action gate
            SubscriptionGate(
              featureKey: 'readings',
              gateType: GateType.action,
              child: _buildActionCard(
                context,
                'Save to Journal',
                'Keep this reading for later',
                Icons.bookmark,
                AppTheme.serenityGreen,
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),
            _buildSectionTitle(context, 'Custom Upgrade Prompt'),
            const SizedBox(height: AppTheme.spacingM),

            // Custom upgrade prompt example
            SubscriptionGate(
              featureKey: 'early_access',
              upgradePrompt: _buildCustomUpgradePrompt(context),
              child: _buildFeatureCard(
                context,
                'Early Access Features',
                'Try new features before everyone else',
                Icons.rocket_launch,
                AppTheme.stardustGold,
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppTheme.primaryPurple,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadCard(BuildContext context, SpreadType spread) {
    return Card(
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${spread.cardCount}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    spread.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              spread.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkGray.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, GuideType guide) {
    return Card(
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
              child: Text(
                guide.guideName[0],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${guide.guideName} - ${guide.title}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    guide.expertise,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: InkWell(
        borderRadius: AppTheme.cardRadius,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title action performed'),
              backgroundColor: color,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.darkGray.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomUpgradePrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.stardustGold.withValues(alpha: 0.2),
            AppTheme.softGold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.stardustGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.rocket_launch, size: 48, color: AppTheme.stardustGold),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Become an Oracle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.stardustGold,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Join the Oracle tier to access exclusive early features and shape the future of Lunanul.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGray.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom upgrade flow initiated'),
                    backgroundColor: AppTheme.stardustGold,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stardustGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingM,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond, size: 20),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Unlock Oracle Powers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Primary',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
