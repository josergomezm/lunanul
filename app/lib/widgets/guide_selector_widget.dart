import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/tarot_guide.dart';
import '../services/guide_service.dart';
import '../providers/guide_provider.dart';
import '../providers/feature_gate_provider.dart';
import '../utils/app_theme.dart';
import '../utils/guide_theme.dart';
import '../utils/app_router.dart';

import '../l10n/generated/app_localizations.dart';

/// A beautiful widget for selecting tarot guides with animated cards and expandable descriptions
class GuideSelectorWidget extends ConsumerStatefulWidget {
  final GuideType? selectedGuide;
  final Function(GuideType?) onGuideSelected;
  final ReadingTopic? currentTopic;
  final EdgeInsets padding;
  final bool showRecommendations;
  final bool allowDeselection;

  const GuideSelectorWidget({
    super.key,
    this.selectedGuide,
    required this.onGuideSelected,
    this.currentTopic,
    this.padding = const EdgeInsets.all(16),
    this.showRecommendations = true,
    this.allowDeselection = false,
  });

  @override
  ConsumerState<GuideSelectorWidget> createState() =>
      _GuideSelectorWidgetState();
}

class _GuideSelectorWidgetState extends ConsumerState<GuideSelectorWidget> {
  GuideType? _expandedGuide;
  final GuideService _guideService = GuideService();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Get all guides for display (including locked ones)
    final allGuides = ref.read(
      localizedGuidesWithLocalizationsProvider(localizations),
    );
    final recommendedGuides = widget.currentTopic != null
        ? _guideService.getRecommendedGuides(widget.currentTopic!)
        : <GuideType>[];

    return SingleChildScrollView(
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppTheme.spacingL),
            if (widget.showRecommendations && recommendedGuides.isNotEmpty) ...[
              _buildRecommendationBanner(context, recommendedGuides),
              const SizedBox(height: AppTheme.spacingM),
            ],
            _buildGuideGrid(context, allGuides, recommendedGuides),
            if (widget.allowDeselection) ...[
              const SizedBox(height: AppTheme.spacingM),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Guide',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Select a guide whose wisdom resonates with your current needs',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationBanner(
    BuildContext context,
    List<GuideType> recommendedGuides,
  ) {
    if (widget.currentTopic == null) return const SizedBox.shrink();

    return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withValues(alpha: 0.1),
            borderRadius: AppTheme.cardRadius,
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  'Recommended for ${widget.currentTopic!.displayName}: ${recommendedGuides.map((g) => g.guideName).join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: AppTheme.mediumAnimation)
        .slideY(begin: -0.2, end: 0, duration: AppTheme.mediumAnimation);
  }

  Widget _buildGuideGrid(
    BuildContext context,
    List<TarotGuide> guides,
    List<GuideType> recommendedGuides,
  ) {
    // Calculate responsive grid parameters
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600
        ? 2
        : 2; // Keep 2 columns for consistency
    final childAspectRatio = screenWidth > 600
        ? 0.8
        : 0.75; // Slightly taller on smaller screens

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];
        final isRecommended = recommendedGuides.contains(guide.type);
        final isSelected = widget.selectedGuide == guide.type;
        final isExpanded = _expandedGuide == guide.type;

        return _buildGuideCard(
          context,
          guide,
          isSelected,
          isRecommended,
          isExpanded,
          index,
        );
      },
    );
  }

  Widget _buildGuideCard(
    BuildContext context,
    TarotGuide guide,
    bool isSelected,
    bool isRecommended,
    bool isExpanded,
    int index,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final isGuideAvailable = ref.watch(
          isGuideAvailableProvider(guide.type),
        );

        // Build the guide card content
        final guideCardContent = GestureDetector(
          onTap: () =>
              _handleGuideSelection(guide.type, isGuideAvailable, context, ref),
          onLongPress: () => _toggleExpansion(guide.type),
          child: AnimatedContainer(
            duration: GuideAnimations.selectionDuration,
            curve: GuideAnimations.selectionCurve,
            child: Material(
              elevation: isSelected
                  ? GuideElevations.selectedCard
                  : GuideElevations.card,
              borderRadius: GuideBorderRadius.card,
              child: Container(
                decoration: GuideTheme.getCardDecoration(
                  guide.type,
                  isSelected: isSelected,
                  isRecommended: isRecommended,
                  isLocked: false, // Remove locked styling
                ),
                child: ClipRRect(
                  borderRadius: GuideBorderRadius.card,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildGuideBackground(
                        guide,
                        isSelected,
                        false, // Remove locked styling
                      ),
                      _buildGuideContent(
                        context,
                        guide,
                        isSelected,
                        isRecommended,
                        isExpanded,
                        false, // Remove locked styling
                      ),
                      if (isSelected) _buildSelectionIndicator(guide),
                      if (isRecommended && !isSelected && isGuideAvailable)
                        _buildRecommendationBadge(),
                      if (!isGuideAvailable)
                        _buildPremiumIndicator(context, guide),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        return guideCardContent
            .animate()
            .fadeIn(duration: AppTheme.mediumAnimation, delay: (index * 100).ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: AppTheme.mediumAnimation,
              delay: (index * 100).ms,
              curve: Curves.elasticOut,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              duration: AppTheme.mediumAnimation,
              delay: (index * 100).ms,
              curve: Curves.easeOutBack,
            );
      },
    );
  }

  Widget _buildGuideBackground(
    TarotGuide guide,
    bool isSelected,
    bool isLocked,
  ) {
    return Stack(
      children: [
        // Guide image as background
        Positioned.fill(
          child: ClipRRect(
            borderRadius: GuideBorderRadius.card,
            child: Image.asset(
              guide.iconPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient background if image fails to load
                return Container(
                  decoration: BoxDecoration(
                    gradient: GuideTheme.getGradient(guide.type),
                  ),
                );
              },
            ),
          ),
        ),
        // Overlay gradient for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        // Enhanced selection overlay with guide-specific color
        if (isSelected)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GuideTheme.getPrimaryColor(guide.type).withValues(alpha: 0.2),
                  GuideTheme.getPrimaryColor(guide.type).withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuideContent(
    BuildContext context,
    TarotGuide guide,
    bool isSelected,
    bool isRecommended,
    bool isExpanded,
    bool isLocked,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: GuideAnimations.selectionDuration,
        padding: const EdgeInsets.all(GuideSpacing.cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
              GuideTheme.getPrimaryColor(guide.type).withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              guide.effectiveName,
              style:
                  GuideTheme.getGuideTextStyle(
                    context,
                    guide.type,
                    baseStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    isTitle: true,
                  ).copyWith(
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        color: GuideTheme.getShadowColor(guide.type),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              guide.effectiveTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GuideTheme.getAccentColor(guide.type),
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                guide.effectiveDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.3,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GuideTheme.getPrimaryColor(guide.type),
                      GuideTheme.getAccentColor(guide.type),
                    ],
                  ),
                  borderRadius: GuideBorderRadius.badge,
                  boxShadow: [
                    BoxShadow(
                      color: GuideTheme.getShadowColor(guide.type),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Expertise: ${guide.effectiveExpertise}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(TarotGuide guide) {
    return Positioned(
          top: AppTheme.spacingS,
          right: AppTheme.spacingS,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GuideTheme.getPrimaryColor(guide.type),
                  GuideTheme.getAccentColor(guide.type),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: GuideTheme.getShadowColor(guide.type),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.white,
              size: GuideSpacing.badgeSize,
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: GuideAnimations.selectionDuration,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          duration: GuideAnimations.glowPulseDuration,
          color: GuideTheme.getAccentColor(guide.type),
        );
  }

  Widget _buildRecommendationBadge() {
    return Positioned(
          top: AppTheme.spacingS,
          right: AppTheme.spacingS,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.stardustGold,
              borderRadius: AppTheme.chipRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              'Recommended',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: AppTheme.mediumAnimation, delay: 200.ms)
        .slideX(
          begin: 0.5,
          end: 0,
          duration: AppTheme.mediumAnimation,
          delay: 200.ms,
        );
  }

  void _handleGuideSelection(
    GuideType guideType,
    bool isAvailable,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (!isAvailable) {
      // Show upgrade modal for locked guides
      _showUpgradeModal(context, ref, guideType);
      return;
    }

    // If deselection is allowed and the same guide is tapped, deselect it
    if (widget.allowDeselection && widget.selectedGuide == guideType) {
      widget.onGuideSelected(null);
    } else {
      widget.onGuideSelected(guideType);
    }

    // Provide haptic feedback
    // HapticFeedback.selectionClick(); // Uncomment if haptic feedback is desired
  }

  void _toggleExpansion(GuideType guideType) {
    setState(() {
      _expandedGuide = _expandedGuide == guideType ? null : guideType;
    });
  }

  Widget _buildPremiumIndicator(BuildContext context, TarotGuide guide) {
    return Positioned(
          top: AppTheme.spacingS,
          left: AppTheme.spacingS,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.stardustGold, AppTheme.softGold],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.star, color: Colors.white, size: 16),
          ),
        )
        .animate()
        .fadeIn(duration: AppTheme.mediumAnimation, delay: 300.ms)
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: AppTheme.mediumAnimation,
          delay: 300.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          duration: 2000.ms,
          color: AppTheme.stardustGold.withValues(alpha: 0.5),
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showGuidePreview(context, ref, guide.type);
                  },
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
                    'Preview',
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
                    _handleUpgradeRequest(context, ref, requiredTier);
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

  void _showUpgradeModal(
    BuildContext context,
    WidgetRef ref,
    GuideType guideType,
  ) {
    final guide = _guideService.getGuideByType(guideType);
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

  void _showGuidePreview(
    BuildContext context,
    WidgetRef ref,
    GuideType guideType,
  ) {
    final guide = _guideService.getGuideByType(guideType);
    if (guide == null) return;

    showDialog(
      context: context,
      builder: (context) => _GuidePreviewDialog(guide: guide),
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

  void _handleUpgradeRequest(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier,
  ) {
    // Navigate to subscription management page
    context.goSubscriptionManagement();
  }
}

/// Dialog for previewing locked guides
class _GuidePreviewDialog extends StatelessWidget {
  final TarotGuide guide;

  const _GuidePreviewDialog({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GuideTheme.getPrimaryColor(guide.type).withValues(alpha: 0.1),
              GuideTheme.getAccentColor(guide.type).withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: GuideTheme.getPrimaryColor(
              guide.type,
            ).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Guide Preview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GuideTheme.getPrimaryColor(guide.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: GuideTheme.getPrimaryColor(guide.type),
                    ),
                  ),
                ],
              ),
            ),

            // Guide content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  children: [
                    // Guide image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GuideTheme.getPrimaryColor(guide.type),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          guide.iconPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: GuideTheme.getGradient(guide.type),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                guide.iconData,
                                size: 48,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Guide name and title
                    Text(
                      guide.effectiveName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: GuideTheme.getPrimaryColor(guide.type),
                            fontWeight: FontWeight.w700,
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

                    // Description
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: GuideTheme.getPrimaryColor(
                          guide.type,
                        ).withValues(alpha: 0.05),
                        borderRadius: AppTheme.cardRadius,
                        border: Border.all(
                          color: GuideTheme.getPrimaryColor(
                            guide.type,
                          ).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        guide.effectiveDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.darkGray.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Expertise
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
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
                        borderRadius: AppTheme.cardRadius,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Expertise',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: GuideTheme.getPrimaryColor(guide.type),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            guide.effectiveExpertise,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.darkGray.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Best for topics
                    if (guide.bestForTopics.isNotEmpty) ...[
                      Text(
                        'Best for',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: GuideTheme.getPrimaryColor(guide.type),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Wrap(
                        spacing: AppTheme.spacingS,
                        runSpacing: AppTheme.spacingXS,
                        children: guide.bestForTopics.map((topic) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: GuideTheme.getAccentColor(
                                guide.type,
                              ).withValues(alpha: 0.2),
                              borderRadius: AppTheme.chipRadius,
                              border: Border.all(
                                color: GuideTheme.getAccentColor(
                                  guide.type,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              topic.displayName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: GuideTheme.getPrimaryColor(
                                      guide.type,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer with upgrade button
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: GuideTheme.getPrimaryColor(
                  guide.type,
                ).withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: GuideTheme.getAccentColor(
                        guide.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                        color: GuideTheme.getAccentColor(
                          guide.type,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: GuideTheme.getPrimaryColor(guide.type),
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            'Unlock ${guide.effectiveName} with Mystic subscription',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: GuideTheme.getPrimaryColor(guide.type),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).pushNamed('/subscription-management');
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
                          const Icon(Icons.auto_awesome, size: 20),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Upgrade to Mystic',
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
            ),
          ],
        ),
      ),
    );
  }
}
