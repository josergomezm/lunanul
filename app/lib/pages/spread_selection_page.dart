import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/enums.dart';
import '../providers/reading_provider.dart';
import '../providers/feature_gate_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';
import '../utils/constants.dart';
import 'reading_results_page.dart';

/// Page for selecting a spread type after choosing a topic
class SpreadSelectionPage extends ConsumerStatefulWidget {
  final ReadingTopic topic;
  final GuideType? selectedGuide;

  const SpreadSelectionPage({
    super.key,
    required this.topic,
    this.selectedGuide,
  });

  @override
  ConsumerState<SpreadSelectionPage> createState() =>
      _SpreadSelectionPageState();
}

class _SpreadSelectionPageState extends ConsumerState<SpreadSelectionPage> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Initialize reading flow with topic and guide if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final readingFlowNotifier = ref.read(readingFlowProvider.notifier);
      readingFlowNotifier.setTopic(widget.topic);
      if (widget.selectedGuide != null) {
        readingFlowNotifier.setSelectedGuide(widget.selectedGuide);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final availableSpreads = SpreadType.getSpreadsByTopic(widget.topic);
    final readingFlow = ref.watch(readingFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic.displayName} ${localizations.readings}'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.goGuideSelection(widget.topic),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Guide Selection',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic confirmation
              Container(
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
                    Icon(
                      _getTopicIcon(widget.topic),
                      size: 32,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.topic.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.topic.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Guide selection indicator
                    if (readingFlow.selectedGuide != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: AppTheme.primaryPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Guide: ${readingFlow.selectedGuide!.guideName}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _changeGuideSelection(context, ref),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Change Guide'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Spread selection title
              Text(
                localizations.chooseYourSpread,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.selectSpreadType,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),

              const SizedBox(height: 24),

              // Spread options
              ...availableSpreads.map(
                (spread) => _buildSpreadCard(
                  context,
                  ref,
                  spread,
                  readingFlow.spreadType == spread,
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      readingFlow.spreadType != null &&
                          !_isNavigating &&
                          ref.read(
                            isSpreadAvailableProvider(readingFlow.spreadType!),
                          )
                      ? () => _startReading(context, ref)
                      : null,
                  child: Text(
                    readingFlow.spreadType != null
                        ? localizations.startSpreadReading(
                            readingFlow.spreadType!.displayName,
                          )
                        : localizations.selectASpread,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpreadCard(
    BuildContext context,
    WidgetRef ref,
    SpreadType spread,
    bool isSelected,
  ) {
    final isAvailable = ref.watch(isSpreadAvailableProvider(spread));
    final isPremium = !isAvailable;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: isSelected ? 8 : 2,
        borderRadius: AppTheme.cardRadius,
        child: InkWell(
          onTap: () {
            if (isAvailable) {
              ref.read(readingFlowProvider.notifier).setSpreadType(spread);
            } else {
              _showSpreadUpgradeModal(context, ref, spread);
            }
          },
          borderRadius: AppTheme.cardRadius,
          child: AnimatedContainer(
            duration: AppTheme.shortAnimation,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: AppTheme.cardRadius,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryPurple
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? AppTheme.primaryPurple.withValues(alpha: 0.05)
                  : Theme.of(context).colorScheme.surface,
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Card count indicator
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryPurple
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${spread.cardCount}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Spread details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spread.displayName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.primaryPurple
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            spread.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${spread.cardCount} card${spread.cardCount > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? AppTheme.primaryPurple
                                      : Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                // Premium star indicator in top right corner
                if (isPremium)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
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
          ),
        ),
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

  void _showSpreadUpgradeModal(
    BuildContext context,
    WidgetRef ref,
    SpreadType spreadType,
  ) {
    final requiredTier = _getRequiredTierForSpread(spreadType);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
        child: _buildSpreadUpgradeModal(context, ref, spreadType, requiredTier),
      ),
    );
  }

  Widget _buildSpreadUpgradeModal(
    BuildContext context,
    WidgetRef ref,
    SpreadType spreadType,
    SubscriptionTier requiredTier,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),

          // Spread icon with premium indicator
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                      AppTheme.stardustGold.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.stardustGold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  '${spreadType.cardCount}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.stardustGold,
                  ),
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

          const SizedBox(height: 24),

          // Spread name and description
          Text(
            spreadType.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.stardustGold,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${spreadType.cardCount} Card Spread',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Premium feature message
          Container(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Premium Spread',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.stardustGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Spread description
          Text(
            spreadType.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Upgrade message
          Text(
            'Unlock the ${spreadType.displayName} spread and explore deeper insights with ${requiredTier.displayName}.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.stardustGold.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.stardustGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goSubscriptionManagement();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.stardustGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.buttonRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getTierIcon(requiredTier), size: 18),
                      const SizedBox(width: 8),
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

  SubscriptionTier _getRequiredTierForSpread(SpreadType spread) {
    // Based on feature access, only single card and three card are available for Seeker
    // All other spreads require Mystic tier
    switch (spread) {
      case SpreadType.singleCard:
      case SpreadType.threeCard:
        return SubscriptionTier.seeker; // Available in free tier
      case SpreadType.celtic:
      case SpreadType.celticCross:
      case SpreadType.horseshoe:
      case SpreadType.relationship:
      case SpreadType.career:
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

  void _changeGuideSelection(BuildContext context, WidgetRef ref) {
    context.goGuideSelection(widget.topic);
  }

  void _startReading(BuildContext context, WidgetRef ref) {
    if (_isNavigating) return; // Prevent multiple calls

    final readingFlow = ref.read(readingFlowProvider);
    if (readingFlow.topic != null && readingFlow.spreadType != null) {
      setState(() {
        _isNavigating = true;
      });

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => ReadingResultsPage(
                topic: readingFlow.topic!,
                spreadType: readingFlow.spreadType!,
                selectedGuide: readingFlow.selectedGuide,
              ),
            ),
          )
          .then((_) {
            // Reset navigation state when returning
            if (mounted) {
              setState(() {
                _isNavigating = false;
              });
            }
          });
    }
  }
}
