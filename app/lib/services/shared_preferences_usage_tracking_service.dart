import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../models/usage_limits.dart';
import 'usage_tracking_service.dart';

/// Concrete implementation of UsageTrackingService using SharedPreferences
class SharedPreferencesUsageTrackingService implements UsageTrackingService {
  static const String _usagePrefix = 'usage_count_';
  static const String _lastResetKey = 'usage_last_reset';
  static const String _usageHistoryKey = 'usage_history';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<int> getUsageCount(String feature) async {
    final prefs = await _preferences;
    return prefs.getInt('$_usagePrefix$feature') ?? 0;
  }

  @override
  Future<void> incrementUsage(String feature) async {
    final currentCount = await getUsageCount(feature);
    await setUsageCount(feature, currentCount + 1);
  }

  @override
  Future<Map<String, int>> getAllUsageCounts() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys();
    final usageCounts = <String, int>{};

    for (final key in keys) {
      if (key.startsWith(_usagePrefix)) {
        final feature = key.substring(_usagePrefix.length);
        try {
          final count = prefs.getInt(key) ?? 0;
          usageCounts[feature] = count;
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    }

    return usageCounts;
  }

  @override
  Future<void> resetMonthlyUsage() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys();

    // Store current usage in history before reset
    await _storeUsageHistory();

    // Reset all usage counts
    for (final key in keys) {
      if (key.startsWith(_usagePrefix)) {
        await prefs.remove(key);
      }
    }

    // Update last reset date
    await setLastResetDate(DateTime.now());
  }

  @override
  Future<bool> isWithinLimit(SubscriptionTier tier, String feature) async {
    final currentUsage = await getUsageCount(feature);
    return UsageLimits.isWithinLimit(tier, feature, currentUsage);
  }

  @override
  Future<bool> hasReachedLimit(SubscriptionTier tier, String feature) async {
    final currentUsage = await getUsageCount(feature);
    return UsageLimits.hasReachedLimit(tier, feature, currentUsage);
  }

  @override
  Future<int> getRemainingUsage(SubscriptionTier tier, String feature) async {
    final currentUsage = await getUsageCount(feature);
    return UsageLimits.getRemainingUsage(tier, feature, currentUsage);
  }

  @override
  Future<double> getUsagePercentage(
    SubscriptionTier tier,
    String feature,
  ) async {
    final currentUsage = await getUsageCount(feature);
    return UsageLimits.getUsagePercentage(tier, feature, currentUsage);
  }

  @override
  Future<bool> isApproachingLimit(SubscriptionTier tier, String feature) async {
    final currentUsage = await getUsageCount(feature);
    return UsageLimits.isApproachingLimit(tier, feature, currentUsage);
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    final prefs = await _preferences;
    final timestamp = prefs.getInt(_lastResetKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  @override
  Future<void> setLastResetDate(DateTime date) async {
    final prefs = await _preferences;
    await prefs.setInt(_lastResetKey, date.millisecondsSinceEpoch);
  }

  @override
  Future<bool> shouldResetMonthlyUsage() async {
    final lastReset = await getLastResetDate();

    // If no reset date is stored, we should reset
    if (lastReset == null) return true;

    final now = DateTime.now();

    // Check if we're in a different month or year
    return now.year != lastReset.year || now.month != lastReset.month;
  }

  @override
  Future<void> clearAllUsage() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys();

    // Remove all usage-related keys
    for (final key in keys) {
      if (key.startsWith(_usagePrefix) ||
          key == _lastResetKey ||
          key == _usageHistoryKey) {
        await prefs.remove(key);
      }
    }
  }

  @override
  Future<Map<String, List<int>>> getUsageHistory() async {
    final prefs = await _preferences;
    final historyJson = prefs.getString(_usageHistoryKey);

    if (historyJson == null) return {};

    try {
      final historyMap = json.decode(historyJson) as Map<String, dynamic>;
      final result = <String, List<int>>{};

      for (final entry in historyMap.entries) {
        final values = (entry.value as List<dynamic>).cast<int>();
        result[entry.key] = values;
      }

      return result;
    } catch (e) {
      // If there's an error parsing history, return empty map
      return {};
    }
  }

  @override
  Future<void> setUsageCount(String feature, int count) async {
    final prefs = await _preferences;
    await prefs.setInt('$_usagePrefix$feature', count);
  }

  /// Store current usage counts in history before reset
  Future<void> _storeUsageHistory() async {
    final currentUsage = await getAllUsageCounts();
    if (currentUsage.isEmpty) return;

    final history = await getUsageHistory();
    final prefs = await _preferences;

    // Add current usage to history for each feature
    for (final entry in currentUsage.entries) {
      final feature = entry.key;
      final count = entry.value;

      if (!history.containsKey(feature)) {
        history[feature] = [];
      }

      history[feature]!.add(count);

      // Keep only last 12 months of history
      if (history[feature]!.length > 12) {
        history[feature] = history[feature]!.sublist(
          history[feature]!.length - 12,
        );
      }
    }

    // Save updated history
    final historyJson = json.encode(history);
    await prefs.setString(_usageHistoryKey, historyJson);
  }

  /// Perform automatic monthly reset check and reset if needed
  Future<void> checkAndResetIfNeeded() async {
    if (await shouldResetMonthlyUsage()) {
      await resetMonthlyUsage();
    }
  }

  /// Get usage summary for a specific tier
  Future<Map<String, dynamic>> getUsageSummary(SubscriptionTier tier) async {
    final allUsage = await getAllUsageCounts();
    final limitedFeatures = UsageLimits.getLimitedFeatures(tier);
    final summary = <String, dynamic>{};

    for (final feature in limitedFeatures) {
      final currentUsage = allUsage[feature] ?? 0;
      final remaining = await getRemainingUsage(tier, feature);
      final percentage = await getUsagePercentage(tier, feature);

      // Calculate limit from remaining usage and current usage
      int featureLimit;
      if (remaining == -1) {
        featureLimit = -1; // unlimited
      } else {
        featureLimit = currentUsage + remaining;
      }

      summary[feature] = {
        'current': currentUsage,
        'limit': featureLimit,
        'remaining': remaining,
        'percentage': percentage,
        'approaching_limit': await isApproachingLimit(tier, feature),
        'reached_limit': await hasReachedLimit(tier, feature),
      };
    }

    return summary;
  }

  /// Get usage statistics for analytics
  Future<Map<String, dynamic>> getUsageStatistics() async {
    final allUsage = await getAllUsageCounts();
    final history = await getUsageHistory();
    final lastReset = await getLastResetDate();

    return {
      'current_usage': allUsage,
      'usage_history': history,
      'last_reset': lastReset?.toIso8601String(),
      'total_features_tracked': allUsage.length,
      'total_usage_this_month': allUsage.values.fold(
        0,
        (sum, count) => sum + count,
      ),
    };
  }
}
