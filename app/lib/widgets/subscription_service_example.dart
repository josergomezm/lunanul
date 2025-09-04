import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/subscription_service.dart';
import '../services/mock_subscription_service.dart';
import '../models/subscription_status.dart';
import '../models/subscription_product.dart';
import '../models/enums.dart';

/// Example provider for the subscription service
/// In a real app, this would be configured based on platform
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return MockSubscriptionService(
    simulateNetworkDelay: true,
    networkDelayMs: 500,
    errorRate: 0.0, // No errors for demo
  );
});

/// Example provider for subscription status
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.subscriptionStatusStream();
});

/// Example provider for available products
final availableProductsProvider = FutureProvider<List<SubscriptionProduct>>((
  ref,
) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getAvailableProducts();
});

/// Example widget demonstrating subscription service usage
class SubscriptionServiceExample extends ConsumerWidget {
  const SubscriptionServiceExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final availableProducts = ref.watch(availableProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Service Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current subscription status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Subscription',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    subscriptionStatus.when(
                      data: (status) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tier: ${status.tier.displayName}'),
                          Text('Active: ${status.isActive}'),
                          if (status.expirationDate != null)
                            Text(
                              'Expires: ${status.expirationDate!.toLocal()}',
                            ),
                          if (status.usageCounts.isNotEmpty)
                            ...status.usageCounts.entries.map(
                              (entry) => Text('${entry.key}: ${entry.value}'),
                            ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Available products
            const Text(
              'Available Subscriptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: availableProducts.when(
                data: (products) => ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.description),
                            Text('${product.price}/${product.period}'),
                            if (product.hasDiscount)
                              Text(
                                product.savingsText!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              _purchaseSubscription(context, ref, product.id),
                          child: const Text('Purchase'),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _refreshStatus(ref),
                  child: const Text('Refresh Status'),
                ),
                ElevatedButton(
                  onPressed: () => _restoreSubscriptions(context, ref),
                  child: const Text('Restore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseSubscription(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) async {
    final service = ref.read(subscriptionServiceProvider);

    try {
      final success = await service.purchaseSubscription(productId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription purchased successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshStatus(WidgetRef ref) async {
    final service = ref.read(subscriptionServiceProvider);

    try {
      await service.refreshSubscriptionStatus();
    } catch (e) {
      // Handle error silently or show notification
    }
  }

  Future<void> _restoreSubscriptions(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(subscriptionServiceProvider);

    try {
      final restored = await service.restoreSubscriptions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored
                  ? 'Subscriptions restored successfully!'
                  : 'No subscriptions to restore',
            ),
            backgroundColor: restored ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Example of how to check subscription status in a widget
class SubscriptionStatusChecker extends ConsumerWidget {
  const SubscriptionStatusChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return subscriptionStatus.when(
      data: (status) {
        if (status.tier == SubscriptionTier.seeker) {
          return const Card(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'You are on the free Seeker tier. Upgrade to unlock more features!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else if (status.isExpired) {
          return const Card(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Your subscription has expired. Please renew to continue using premium features.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else {
          return Card(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'You have an active ${status.tier.displayName} subscription!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Loading subscription status...'),
        ),
      ),
      error: (error, stack) => Card(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading subscription: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Example of how to use subscription service in a provider
class SubscriptionHelper {
  static Future<bool> canAccessFeature(
    WidgetRef ref,
    SubscriptionTier requiredTier,
  ) async {
    final service = ref.read(subscriptionServiceProvider);
    final status = await service.getSubscriptionStatus();

    return status.isValid && status.tier.index >= requiredTier.index;
  }

  static Future<bool> hasUsageRemaining(
    WidgetRef ref,
    String feature,
    int limit,
  ) async {
    final service = ref.read(subscriptionServiceProvider);
    final status = await service.getSubscriptionStatus();

    final currentUsage = status.getUsageCount(feature);
    return currentUsage < limit;
  }

  static Future<void> incrementUsage(WidgetRef ref, String feature) async {
    // In a real implementation, this would be handled by the usage tracking service
    // This is just an example of how you might structure the API
  }
}
