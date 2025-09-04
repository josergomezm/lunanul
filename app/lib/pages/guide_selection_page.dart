import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/enums.dart';
import '../models/tarot_guide.dart';
import '../providers/reading_provider.dart';
import '../providers/feature_gate_provider.dart';
import '../services/guide_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/app_router.dart';
import '../utils/guide_theme.dart';
import '../widgets/guide_selector_widget.dart';

/// Page for selecting a guide after choosing a topic
class GuideSelectionPage extends ConsumerWidget {
  final ReadingTopic topic;

  const GuideSelectionPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final readingFlow = ref.watch(readingFlowProvider);
    final selectedGuide = readingFlow.selectedGuide;

    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.displayName} ${localizations.readings}'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.goReadings(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Topic Selection',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic confirmation
              _buildTopicHeader(context),

              const SizedBox(height: 32),

              // Guide selector widget
              GuideSelectorWidget(
                selectedGuide: selectedGuide,
                currentTopic: topic,
                onGuideSelected: (guide) {
                  ref
                      .read(readingFlowProvider.notifier)
                      .setSelectedGuide(guide);
                },
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedGuide != null
                      ? () => _continueToSpreadSelection(context, ref)
                      : null,
                  child: Text(
                    selectedGuide != null
                        ? 'Continue with ${selectedGuide.guideName}'
                        : 'Select a Guide to Continue',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip guide selection option
              // SizedBox(
              //   width: double.infinity,
              //   child: TextButton(
              //     onPressed: () => _skipGuideSelection(context, ref),
              //     child: const Text('Skip Guide Selection'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(_getTopicIcon(topic), size: 32, color: AppTheme.primaryPurple),
          const SizedBox(height: 8),
          Text(
            topic.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            topic.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTopicIcon(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return Icons.self_improvement;
      case ReadingTopic.love:
        return Icons.favorite;
      case ReadingTopic.work:
        return Icons.work;
      case ReadingTopic.social:
        return Icons.people;
    }
  }

  void _continueToSpreadSelection(BuildContext context, WidgetRef ref) {
    final selectedGuide = ref.read(readingFlowProvider).selectedGuide;

    if (selectedGuide != null) {
      // Check if the selected guide is available
      final isAvailable = ref.read(isGuideAvailableProvider(selectedGuide));

      if (!isAvailable) {
        // Show upgrade modal if guide is not available
        _showGuideUpgradeModal(context, ref, selectedGuide);
        return;
      }
    }

    context.goSpreadSelection(topic, selectedGuide: selectedGuide);
  }

  void _showGuideUpgradeModal(
    BuildContext context,
    WidgetRef ref,
    GuideType guideType,
  ) {
    final guideService = GuideService();
    final guide = guideService.getGuideByType(guideType);
    if (guide == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
        child: _buildGuideUpgradeModal(context, ref, guide),
      ),
    );
  }

  Widget _buildGuideUpgradeModal(
    BuildContext context,
    WidgetRef ref,
    TarotGuide guide,
  ) {
    final requiredTier = _getRequiredTierForGuide(guide.type);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                iconSize: 20,
                color: AppTheme.darkGray.withValues(alpha: 0.6),
              ),
            ],
          ),

          // Guide icon with premium indicator
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GuideTheme.getPrimaryColor(
                        guide.type,
                      ).withValues(alpha: 0.1),
                      GuideTheme.getAccentColor(
                        guide.type,
                      ).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GuideTheme.getPrimaryColor(
                      guide.type,
                    ).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  guide.iconData,
                  size: 40,
                  color: GuideTheme.getPrimaryColor(guide.type),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.stardustGold, AppTheme.softGold],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Guide name and title
          Text(
            guide.effectiveName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: GuideTheme.getPrimaryColor(guide.type),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            guide.effectiveTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: GuideTheme.getAccentColor(guide.type),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Premium feature message
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.stardustGold.withValues(alpha: 0.1),
              borderRadius: AppTheme.cardRadius,
              border: Border.all(
                color: AppTheme.stardustGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: AppTheme.stardustGold, size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'Premium Guide',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.stardustGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Guide description
          Text(
            guide.effectiveDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGray.withValues(alpha: 0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Upgrade message
          Text(
            'Unlock ${guide.effectiveName}\'s wisdom and enhance your spiritual journey with ${requiredTier.displayName}.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.darkGray.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: GuideTheme.getPrimaryColor(
                        guide.type,
                      ).withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: GuideTheme.getPrimaryColor(guide.type),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goSubscriptionManagement();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GuideTheme.getPrimaryColor(guide.type),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.buttonRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getTierIcon(requiredTier), size: 18),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Upgrade',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SubscriptionTier _getRequiredTierForGuide(GuideType guide) {
    // Based on subscription config, Sage and Visionary require Mystic tier
    switch (guide) {
      case GuideType.healer:
      case GuideType.mentor:
        return SubscriptionTier.seeker; // Available in free tier
      case GuideType.sage:
      case GuideType.visionary:
        return SubscriptionTier.mystic; // Require paid tier
    }
  }

  IconData _getTierIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return Icons.explore;
      case SubscriptionTier.mystic:
        return Icons.auto_awesome;
      case SubscriptionTier.oracle:
        return Icons.diamond;
    }
  }
}
