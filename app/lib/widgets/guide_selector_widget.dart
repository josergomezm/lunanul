import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/tarot_guide.dart';
import '../services/guide_service.dart';
import '../providers/guide_provider.dart';
import '../utils/app_theme.dart';
import '../utils/guide_theme.dart';

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
    final localizedGuides = ref.read(
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
            _buildGuideGrid(context, localizedGuides, recommendedGuides),
            if (widget.allowDeselection) ...[
              const SizedBox(height: AppTheme.spacingM),
              _buildNoGuideOption(context),
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
    return GestureDetector(
          onTap: () => _handleGuideSelection(guide.type),
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
                ),
                child: ClipRRect(
                  borderRadius: GuideBorderRadius.card,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildGuideBackground(guide, isSelected),
                      _buildGuideContent(
                        context,
                        guide,
                        isSelected,
                        isRecommended,
                        isExpanded,
                      ),
                      if (isSelected) _buildSelectionIndicator(guide),
                      if (isRecommended && !isSelected)
                        _buildRecommendationBadge(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
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
  }

  Widget _buildGuideBackground(TarotGuide guide, bool isSelected) {
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

  void _handleGuideSelection(GuideType guideType) {
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

  Widget _buildNoGuideOption(BuildContext context) {
    final isSelected = widget.selectedGuide == null;

    return GestureDetector(
      onTap: () => widget.onGuideSelected(null),
      child: AnimatedContainer(
        duration: AppTheme.mediumAnimation,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPurple
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryPurple.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                color: isSelected ? AppTheme.primaryPurple : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standard Reading',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryPurple : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use traditional card meanings without guide personalization',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryPurple, size: 24),
          ],
        ),
      ),
    );
  }
}
