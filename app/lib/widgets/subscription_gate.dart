import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/enums.dart';
import '../services/feature_gate_service.dart';
import '../services/subscription_feature_gate_service.dart';
import '../providers/feature_gate_provider.dart';
import '../utils/app_theme.dart';

/// Widget that wraps protected features and displays upgrade prompts when access is restricted
class SubscriptionGate extends ConsumerStatefulWidget {
  const SubscriptionGate({
    super.key,
    required this.child,
    required this.featureKey,
    this.upgradePrompt,
    this.requiredTier,
    this.onUpgradeRequested,
    this.showShimmer = true,
    this.animationDuration = AppTheme.mediumAnimation,
    this.gateType = GateType.feature,
    this.spreadType,
    this.guideType,
  });

  /// The widget to display when access is granted
  final Widget child;

  /// The feature key to check access for
  final String featureKey;

  /// Custom upgrade prompt widget (optional)
  final Widget? upgradePrompt;

  /// Required subscription tier for this feature (optional, will be determined automatically)
  final SubscriptionTier? requiredTier;

  /// Callback when user requests upgrade
  final VoidCallback? onUpgradeRequested;

  /// Whether to show shimmer effect while loading
  final bool showShimmer;

  /// Animation duration for gate state changes
  final Duration animationDuration;

  /// Type of gate behavior
  final GateType gateType;

  /// Specific spread type to check (for spread gates)
  final SpreadType? spreadType;

  /// Specific guide type to check (for guide gates)
  final GuideType? guideType;

  @override
  ConsumerState<SubscriptionGate> createState() => _SubscriptionGateState();
}

class _SubscriptionGateState extends ConsumerState<SubscriptionGate>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildGateContent();
  }

  Widget _buildGateContent() {
    switch (widget.gateType) {
      case GateType.feature:
        return _buildFeatureGate();
      case GateType.spread:
        return _buildSpreadGate();
      case GateType.guide:
        return _buildGuideGate();
      case GateType.action:
        return _buildActionGate();
    }
  }

  Widget _buildFeatureGate() {
    final canAccessAsync = ref.watch(
      canAccessFeatureProvider(widget.featureKey),
    );

    return canAccessAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (canAccess) {
        if (canAccess) {
          _fadeController.forward();
          _scaleController.forward();
          return AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: widget.child,
                ),
              );
            },
          );
        } else {
          return _buildUpgradePrompt();
        }
      },
    );
  }

  Widget _buildSpreadGate() {
    if (widget.spreadType == null) {
      return _buildErrorState('Spread type not specified');
    }

    final canAccessAsync = ref.watch(
      canAccessSpreadProvider(widget.spreadType!),
    );

    return canAccessAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (canAccess) {
        if (canAccess) {
          _fadeController.forward();
          _scaleController.forward();
          return AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: widget.child,
                ),
              );
            },
          );
        } else {
          return _buildSpreadUpgradePrompt();
        }
      },
    );
  }

  Widget _buildGuideGate() {
    if (widget.guideType == null) {
      return _buildErrorState('Guide type not specified');
    }

    final canAccessAsync = ref.watch(canAccessGuideProvider(widget.guideType!));

    return canAccessAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (canAccess) {
        if (canAccess) {
          _fadeController.forward();
          _scaleController.forward();
          return AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: widget.child,
                ),
              );
            },
          );
        } else {
          return _buildGuideUpgradePrompt();
        }
      },
    );
  }

  Widget _buildActionGate() {
    final canPerformAsync = ref.watch(
      canPerformActionProvider(widget.featureKey),
    );

    return canPerformAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (canPerform) {
        if (canPerform) {
          _fadeController.forward();
          _scaleController.forward();
          return AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: widget.child,
                ),
              );
            },
          );
        } else {
          return _buildUsageLimitPrompt();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    if (!widget.showShimmer) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: AppTheme.cardRadius,
          ),
          child: widget.child,
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: AppTheme.moonlightSilver.withValues(alpha: 0.3),
        );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor, size: 32),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Unable to check feature access',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.errorColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt() {
    if (widget.upgradePrompt != null) {
      return widget.upgradePrompt!;
    }

    final upgradeRequirementAsync = ref.watch(
      upgradeRequirementProvider(widget.featureKey),
    );

    return upgradeRequirementAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (requirement) {
        if (requirement == null) {
          // No upgrade required but access denied - show generic message
          return _buildGenericUpgradePrompt();
        }

        return _buildUpgradePromptCard(requirement);
      },
    );
  }

  Widget _buildSpreadUpgradePrompt() {
    return FutureBuilder<UpgradeRequirement?>(
      future: _getSpreadUpgradeRequirement(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error!);
        }

        final requirement = snapshot.data;
        if (requirement == null) {
          return _buildGenericUpgradePrompt();
        }

        return _buildUpgradePromptCard(requirement);
      },
    );
  }

  Widget _buildGuideUpgradePrompt() {
    return FutureBuilder<UpgradeRequirement?>(
      future: _getGuideUpgradeRequirement(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error!);
        }

        final requirement = snapshot.data;
        if (requirement == null) {
          return _buildGenericUpgradePrompt();
        }

        return _buildUpgradePromptCard(requirement);
      },
    );
  }

  Widget _buildUsageLimitPrompt() {
    final usageInfoAsync = ref.watch(
      featureUsageInfoProvider(widget.featureKey),
    );

    return usageInfoAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (usageInfo) {
        final isReachedLimit = usageInfo['reached_limit'] as bool? ?? false;
        final current = usageInfo['current'] as int? ?? 0;
        final limit = usageInfo['limit'] as int?;

        if (isReachedLimit && limit != null) {
          return _buildUsageLimitCard(current, limit);
        } else {
          return _buildGenericUpgradePrompt();
        }
      },
    );
  }

  Widget _buildUpgradePromptCard(UpgradeRequirement requirement) {
    return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryPurple.withValues(alpha: 0.1),
                AppTheme.mysticPurple.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: AppTheme.cardRadius,
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUpgradeIcon(requirement.requiredTier),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                _getUpgradeTitle(requirement),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                _getUpgradeMessage(requirement),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              if (requirement.isUsageBased) ...[
                const SizedBox(height: AppTheme.spacingM),
                _buildUsageIndicator(
                  requirement.currentUsage!,
                  requirement.usageLimit!,
                ),
              ],
              const SizedBox(height: AppTheme.spacingL),
              _buildUpgradeButton(requirement.requiredTier),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: widget.animationDuration)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: widget.animationDuration,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildUsageLimitCard(int current, int limit) {
    return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.warningColor.withValues(alpha: 0.1),
                AppTheme.stardustGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: AppTheme.cardRadius,
            border: Border.all(
              color: AppTheme.warningColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 48,
                color: AppTheme.warningColor,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Monthly Limit Reached',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'You\'ve used all $limit of your monthly allowance for this feature.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildUsageIndicator(current, limit),
              const SizedBox(height: AppTheme.spacingL),
              _buildUpgradeButton(SubscriptionTier.mystic),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: widget.animationDuration)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: widget.animationDuration,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildGenericUpgradePrompt() {
    final requiredTier = widget.requiredTier ?? SubscriptionTier.mystic;

    return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryPurple.withValues(alpha: 0.1),
                AppTheme.mysticPurple.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: AppTheme.cardRadius,
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUpgradeIcon(requiredTier),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Premium Feature',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Upgrade to ${requiredTier.displayName} to unlock this feature and enhance your spiritual journey.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildUpgradeButton(requiredTier),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: widget.animationDuration)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: widget.animationDuration,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildUpgradeIcon(SubscriptionTier tier) {
    IconData iconData;
    Color iconColor;

    switch (tier) {
      case SubscriptionTier.seeker:
        iconData = Icons.explore;
        iconColor = AppTheme.serenityGreen;
        break;
      case SubscriptionTier.mystic:
        iconData = Icons.auto_awesome;
        iconColor = AppTheme.primaryPurple;
        break;
      case SubscriptionTier.oracle:
        iconData = Icons.diamond;
        iconColor = AppTheme.softGold;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Icon(iconData, size: 32, color: iconColor),
    );
  }

  Widget _buildUsageIndicator(int current, int limit) {
    final percentage = (current / limit).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGray.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '$current / $limit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGray.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXS),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppTheme.moonlightSilver,
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 1.0 ? AppTheme.errorColor : AppTheme.warningColor,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(SubscriptionTier tier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            widget.onUpgradeRequested ?? () => _handleUpgradeRequest(tier),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTierColor(tier),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getTierIcon(tier), size: 20),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'Upgrade to ${tier.displayName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Primary',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUpgradeTitle(UpgradeRequirement requirement) {
    if (requirement.isUsageBased) {
      return 'Monthly Limit Reached';
    } else {
      return '${requirement.requiredTier.displayName} Feature';
    }
  }

  String _getUpgradeMessage(UpgradeRequirement requirement) {
    if (requirement.isUsageBased) {
      return 'You\'ve reached your monthly limit for ${requirement.featureName}. Upgrade to continue using this feature without restrictions.';
    } else {
      return 'Unlock ${requirement.featureName} and enhance your spiritual journey with ${requirement.requiredTier.displayName}.';
    }
  }

  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return AppTheme.serenityGreen;
      case SubscriptionTier.mystic:
        return AppTheme.primaryPurple;
      case SubscriptionTier.oracle:
        return AppTheme.softGold;
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

  Future<UpgradeRequirement?> _getSpreadUpgradeRequirement() async {
    if (widget.spreadType == null) return null;

    final service = ref.read(featureGateServiceProvider);
    if (service is SubscriptionFeatureGateService) {
      return service.getUpgradeRequirementForSpread(widget.spreadType!);
    }
    return null;
  }

  Future<UpgradeRequirement?> _getGuideUpgradeRequirement() async {
    if (widget.guideType == null) return null;

    final service = ref.read(featureGateServiceProvider);
    if (service is SubscriptionFeatureGateService) {
      return service.getUpgradeRequirementForGuide(widget.guideType!);
    }
    return null;
  }

  void _handleUpgradeRequest(SubscriptionTier tier) {
    // TODO: Navigate to subscription management screen
    // This will be implemented in task 8
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgrade to ${tier.displayName} requested'),
        backgroundColor: _getTierColor(tier),
      ),
    );
  }
}

/// Types of gate behaviors
enum GateType {
  /// Check general feature access
  feature,

  /// Check specific spread access
  spread,

  /// Check specific guide access
  guide,

  /// Check action with usage tracking
  action,
}
