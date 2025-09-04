// Comprehensive subscription providers that combine all subscription-related functionality
//
// This file exports all subscription providers and provides additional derived providers
// for common subscription-related operations and state management.

export 'subscription_provider.dart';
export 'feature_gate_provider.dart';
export 'usage_tracking_provider.dart' hide usageCountsProvider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../models/feature_access.dart';
import '../models/subscription_product.dart';

import 'subscription_provider.dart' as sub_provider;
import 'feature_gate_provider.dart';
import 'usage_tracking_provider.dart' as usage_provider;

/// Provider for available subscription products
final subscriptionProductsProvider = FutureProvider<List<SubscriptionProduct>>((
  ref,
) async {
  final service = ref.watch(sub_provider.subscriptionServiceProvider);
  return service.getAvailableProducts();
});

/// Provider for specific subscription product
final subscriptionProductProvider =
    FutureProvider.family<SubscriptionProduct?, String>((ref, productId) async {
      final service = ref.watch(sub_provider.subscriptionServiceProvider);
      return service.getProductInfo(productId);
    });

/// Provider for checking if subscription management is available
final canManageSubscriptionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(sub_provider.subscriptionServiceProvider);
  return service.canManageSubscription();
});

/// Provider for subscription tier display information
final tierDisplayInfoProvider =
    Provider.family<TierDisplayInfo, SubscriptionTier>((ref, tier) {
      return TierDisplayInfo.forTier(tier);
    });

/// Provider for current tier display information
final currentTierDisplayInfoProvider = Provider<TierDisplayInfo>((ref) {
  final tier = ref.watch(sub_provider.currentTierProvider);
  return TierDisplayInfo.forTier(tier);
});

/// Provider for subscription status summary
final subscriptionSummaryProvider = Provider<SubscriptionSummary>((ref) {
  final subscriptionAsync = ref.watch(sub_provider.subscriptionProvider);
  final featureAccess = ref.watch(featureAccessProvider);
  final usageCountsAsync = ref.watch(
    usage_provider.usageTrackingNotifierProvider,
  );

  return subscriptionAsync.when(
    data: (status) => SubscriptionSummary(
      status: status,
      featureAccess: featureAccess,
      usageCounts: usageCountsAsync.when(
        data: (counts) => counts,
        loading: () => {},
        error: (error, stackTrace) => {},
      ),
    ),
    loading: () => SubscriptionSummary.loading(),
    error: (error, stackTrace) => SubscriptionSummary.error(),
  );
});

/// Provider for checking if user needs to upgrade for a specific tier
final needsUpgradeForTierProvider = Provider.family<bool, SubscriptionTier>((
  ref,
  targetTier,
) {
  final currentTier = ref.watch(sub_provider.currentTierProvider);

  const tierHierarchy = {
    SubscriptionTier.seeker: 0,
    SubscriptionTier.mystic: 1,
    SubscriptionTier.oracle: 2,
  };

  final currentLevel = tierHierarchy[currentTier] ?? 0;
  final targetLevel = tierHierarchy[targetTier] ?? 0;

  return currentLevel < targetLevel;
});

/// Provider for subscription benefits comparison
final subscriptionBenefitsProvider =
    Provider<Map<SubscriptionTier, List<String>>>((ref) {
      return {
        SubscriptionTier.seeker: [
          'Daily Card of the Day',
          '1-card and 3-card spreads',
          'Access to Healer and Mentor guides',
          '5 manual interpretations per month',
          '3 journal entries maximum',
        ],
        SubscriptionTier.mystic: [
          'All Seeker benefits',
          'Unlimited AI readings',
          'All spread types (7-card, 10-card)',
          'Access to all four guides',
          'Unlimited manual interpretations',
          'Unlimited journal storage',
          'Ad-free experience',
          'Reading statistics and insights',
        ],
        SubscriptionTier.oracle: [
          'All Mystic benefits',
          'AI-generated audio readings',
          'Personalized journal prompts',
          'Advanced specialized spreads',
          'Early access to new features',
          'Multiple card back designs',
          'Custom app themes',
          'Priority support',
        ],
      };
    });

/// Provider for tier upgrade recommendations
final tierUpgradeRecommendationProvider = Provider<TierUpgradeRecommendation?>((
  ref,
) {
  final currentTier = ref.watch(sub_provider.currentTierProvider);
  final usageCounts = ref.watch(sub_provider.usageCountsProvider);

  // Don't recommend upgrades for Oracle tier users
  if (currentTier == SubscriptionTier.oracle) {
    return null;
  }

  // Check usage patterns to recommend upgrades
  if (currentTier == SubscriptionTier.seeker) {
    final manualInterpretations = usageCounts['manual_interpretations'] ?? 0;
    final journalEntries = usageCounts['journal_entries'] ?? 0;

    // High usage suggests user would benefit from Mystic tier
    if (manualInterpretations >= 4 || journalEntries >= 3) {
      return TierUpgradeRecommendation(
        recommendedTier: SubscriptionTier.mystic,
        reason:
            'You\'re approaching your monthly limits. Upgrade for unlimited access!',
        benefits: [
          'Unlimited readings and interpretations',
          'Unlimited journal storage',
          'Access to all guides and spreads',
          'Ad-free experience',
        ],
      );
    }
  }

  // For Mystic users, recommend Oracle based on engagement
  if (currentTier == SubscriptionTier.mystic) {
    return TierUpgradeRecommendation(
      recommendedTier: SubscriptionTier.oracle,
      reason: 'Enhance your spiritual journey with premium Oracle features',
      benefits: [
        'AI-generated audio readings',
        'Personalized journal prompts',
        'Advanced spreads and customization',
        'Early access to new features',
      ],
    );
  }

  return null;
});

/// Provider for subscription health check
final subscriptionHealthProvider = FutureProvider<SubscriptionHealth>((
  ref,
) async {
  final subscriptionAsync = ref.watch(sub_provider.subscriptionProvider);

  return subscriptionAsync.when(
    data: (status) async {
      final now = DateTime.now();
      final isExpiringSoon =
          status.expirationDate != null &&
          status.expirationDate!.difference(now).inDays <= 7;

      final hasHighUsage =
          status.tier == SubscriptionTier.seeker &&
          (status.getUsageCount('manual_interpretations') >= 4 ||
              status.getUsageCount('journal_entries') >= 2);

      return SubscriptionHealth(
        isHealthy: status.isValid && !isExpiringSoon,
        isExpiringSoon: isExpiringSoon,
        hasHighUsage: hasHighUsage,
        needsAttention: isExpiringSoon || hasHighUsage || !status.isValid,
        lastChecked: now,
      );
    },
    loading: () async => SubscriptionHealth.loading(),
    error: (error, stackTrace) async => SubscriptionHealth.error(),
  );
});

/// Data classes for derived providers

class TierDisplayInfo {
  const TierDisplayInfo({
    required this.tier,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    required this.icon,
  });

  final SubscriptionTier tier;
  final String name;
  final String description;
  final String price;
  final int color; // Color value
  final String icon;

  factory TierDisplayInfo.forTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return const TierDisplayInfo(
          tier: SubscriptionTier.seeker,
          name: 'Seeker',
          description: 'Essential daily guidance',
          price: 'Free',
          color: 0xFF6B7280, // Gray
          icon: '🌱',
        );
      case SubscriptionTier.mystic:
        return const TierDisplayInfo(
          tier: SubscriptionTier.mystic,
          name: 'Mystic',
          description: 'Complete spiritual experience',
          price: '\$4.99/month',
          color: 0xFF8B5CF6, // Purple
          icon: '🔮',
        );
      case SubscriptionTier.oracle:
        return const TierDisplayInfo(
          tier: SubscriptionTier.oracle,
          name: 'Oracle',
          description: 'Premium insights & features',
          price: '\$9.99/month',
          color: 0xFFF59E0B, // Amber
          icon: '✨',
        );
    }
  }
}

class SubscriptionSummary {
  const SubscriptionSummary({
    required this.status,
    required this.featureAccess,
    required this.usageCounts,
    this.isLoading = false,
    this.hasError = false,
  });

  final SubscriptionStatus? status;
  final FeatureAccess? featureAccess;
  final Map<String, int> usageCounts;
  final bool isLoading;
  final bool hasError;

  factory SubscriptionSummary.loading() {
    return const SubscriptionSummary(
      status: null,
      featureAccess: null,
      usageCounts: {},
      isLoading: true,
    );
  }

  factory SubscriptionSummary.error() {
    return const SubscriptionSummary(
      status: null,
      featureAccess: null,
      usageCounts: {},
      hasError: true,
    );
  }

  bool get isValid => status?.isValid ?? false;
  SubscriptionTier get tier => status?.tier ?? SubscriptionTier.seeker;
  bool get isExpired => status?.isExpired ?? false;
  DateTime? get expirationDate => status?.expirationDate;
}

class TierUpgradeRecommendation {
  const TierUpgradeRecommendation({
    required this.recommendedTier,
    required this.reason,
    required this.benefits,
  });

  final SubscriptionTier recommendedTier;
  final String reason;
  final List<String> benefits;
}

class SubscriptionHealth {
  const SubscriptionHealth({
    required this.isHealthy,
    required this.isExpiringSoon,
    required this.hasHighUsage,
    required this.needsAttention,
    required this.lastChecked,
  });

  final bool isHealthy;
  final bool isExpiringSoon;
  final bool hasHighUsage;
  final bool needsAttention;
  final DateTime lastChecked;

  factory SubscriptionHealth.loading() {
    return SubscriptionHealth(
      isHealthy: false,
      isExpiringSoon: false,
      hasHighUsage: false,
      needsAttention: false,
      lastChecked: DateTime.now(),
    );
  }

  factory SubscriptionHealth.error() {
    return SubscriptionHealth(
      isHealthy: false,
      isExpiringSoon: false,
      hasHighUsage: false,
      needsAttention: true,
      lastChecked: DateTime.now(),
    );
  }
}

/// Extension methods for comprehensive subscription access
extension ComprehensiveSubscriptionRef on WidgetRef {
  /// Get subscription summary
  SubscriptionSummary get subscriptionSummary =>
      read(subscriptionSummaryProvider);

  /// Get current tier display info
  TierDisplayInfo get currentTierDisplayInfo =>
      read(currentTierDisplayInfoProvider);

  /// Get tier display info for specific tier
  TierDisplayInfo getTierDisplayInfo(SubscriptionTier tier) =>
      read(tierDisplayInfoProvider(tier));

  /// Check if needs upgrade for tier
  bool needsUpgradeForTier(SubscriptionTier tier) =>
      read(needsUpgradeForTierProvider(tier));

  /// Get subscription benefits
  Map<SubscriptionTier, List<String>> get subscriptionBenefits =>
      read(subscriptionBenefitsProvider);

  /// Get tier upgrade recommendation
  TierUpgradeRecommendation? get tierUpgradeRecommendation =>
      read(tierUpgradeRecommendationProvider);

  /// Get available subscription products
  AsyncValue<List<SubscriptionProduct>> get subscriptionProducts =>
      watch(subscriptionProductsProvider);

  /// Get specific subscription product
  AsyncValue<SubscriptionProduct?> getSubscriptionProduct(String productId) =>
      watch(subscriptionProductProvider(productId));

  /// Check if can manage subscription
  AsyncValue<bool> get canManageSubscription =>
      watch(canManageSubscriptionProvider);

  /// Get subscription health
  AsyncValue<SubscriptionHealth> get subscriptionHealth =>
      watch(subscriptionHealthProvider);

  /// Open subscription management
  Future<void> openSubscriptionManagement() async {
    final service = read(sub_provider.subscriptionServiceProvider);
    await service.openSubscriptionManagement();
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    final service = read(sub_provider.subscriptionServiceProvider);
    await service.cancelSubscription();
  }
}
