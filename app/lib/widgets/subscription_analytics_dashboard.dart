import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_analytics_provider.dart';
import '../models/enums.dart';
import '../models/subscription_analytics.dart';

/// Widget for displaying subscription analytics dashboard
class SubscriptionAnalyticsDashboard extends ConsumerWidget {
  const SubscriptionAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(subscriptionHealthMetricsProvider);
              ref.invalidate(performanceMetricsProvider);
              ref.invalidate(systemAlertsProvider);
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HealthStatusCard(),
            SizedBox(height: 16),
            _MetricsOverviewCard(),
            SizedBox(height: 16),
            _ConversionMetricsCard(),
            SizedBox(height: 16),
            _FeatureAdoptionCard(),
            SizedBox(height: 16),
            _SystemAlertsCard(),
            SizedBox(height: 16),
            _DiagnosticsCard(),
          ],
        ),
      ),
    );
  }
}

class _HealthStatusCard extends ConsumerWidget {
  const _HealthStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthStatus = ref.watch(healthStatusProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            healthStatus.when(
              data: (status) => _buildHealthStatus(status),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatus(Map<String, dynamic> status) {
    final isHealthy = status['isHealthy'] as bool? ?? false;
    final statusText = status['status'] as String? ?? 'unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isHealthy ? Icons.check_circle : Icons.error,
              color: isHealthy ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              statusText.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHealthy ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Last Check: ${status['lastCheck'] ?? 'Unknown'}'),
        if (status['error'] != null) ...[
          const SizedBox(height: 8),
          Text(
            'Error: ${status['error']}',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}

class _MetricsOverviewCard extends ConsumerWidget {
  const _MetricsOverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthMetrics = ref.watch(subscriptionHealthMetricsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            healthMetrics.when(
              data: (metrics) => _buildMetricsOverview(metrics),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsOverview(SubscriptionHealthMetrics metrics) {
    return Column(
      children: [
        _MetricRow(
          label: 'Conversion Rate',
          value: '${(metrics.conversionRate * 100).toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: metrics.conversionRate > 0.1 ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Churn Rate',
          value: '${(metrics.churnRate * 100).toStringAsFixed(1)}%',
          icon: Icons.trending_down,
          color: metrics.churnRate < 0.1 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Error Rate',
          value: '${(metrics.errorRate * 100).toStringAsFixed(2)}%',
          icon: Icons.error_outline,
          color: metrics.errorRate < 0.05 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Total Errors',
          value: '${metrics.totalErrors}',
          icon: Icons.bug_report,
          color: metrics.totalErrors < 10 ? Colors.green : Colors.orange,
        ),
      ],
    );
  }
}

class _ConversionMetricsCard extends ConsumerWidget {
  const _ConversionMetricsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion Rates by Tier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...SubscriptionTier.values.map((tier) {
              final conversionRate = ref.watch(conversionRateProvider(tier));
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: conversionRate.when(
                  data: (rate) => _MetricRow(
                    label: tier.name.toUpperCase(),
                    value: '${(rate * 100).toStringAsFixed(1)}%',
                    icon: Icons.person_add,
                    color: _getConversionColor(tier, rate),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text('Error loading ${tier.name}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getConversionColor(SubscriptionTier tier, double rate) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return Colors.blue;
      case SubscriptionTier.mystic:
        return rate > 0.1 ? Colors.green : Colors.orange;
      case SubscriptionTier.oracle:
        return rate > 0.03 ? Colors.green : Colors.orange;
    }
  }
}

class _FeatureAdoptionCard extends ConsumerWidget {
  const _FeatureAdoptionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Adoption Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...SubscriptionTier.values.map((tier) {
              final adoptionRates = ref.watch(
                featureAdoptionRatesProvider(tier),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    adoptionRates.when(
                      data: (rates) => Column(
                        children: rates.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: _MetricRow(
                              label: entry.key
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              value:
                                  '${(entry.value * 100).toStringAsFixed(1)}%',
                              icon: Icons.analytics,
                              color: entry.value > 0.5
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          );
                        }).toList(),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (error, _) => Text('Error loading ${tier.name}'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SystemAlertsCard extends ConsumerWidget {
  const _SystemAlertsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(systemAlertsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            alerts.when(
              data: (alertList) => alertList.isEmpty
                  ? const Text('No active alerts')
                  : Column(
                      children: alertList
                          .map((alert) => _buildAlert(alert))
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String? ?? 'info';
    final message = alert['message'] as String? ?? 'Unknown alert';

    Color alertColor;
    IconData alertIcon;

    switch (severity) {
      case 'critical':
        alertColor = Colors.red;
        alertIcon = Icons.error;
        break;
      case 'warning':
        alertColor = Colors.orange;
        alertIcon = Icons.warning;
        break;
      case 'info':
        alertColor = Colors.blue;
        alertIcon = Icons.info;
        break;
      default:
        alertColor = Colors.grey;
        alertIcon = Icons.notifications;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: alertColor)),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsCard extends ConsumerWidget {
  const _DiagnosticsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnostics = ref.watch(systemDiagnosticsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Diagnostics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            diagnostics.when(
              data: (data) => _buildDiagnostics(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnostics(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
          label: 'Total Events',
          value: '${data['totalEvents'] ?? 0}',
          icon: Icons.event,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Storage Size',
          value: '${data['storageSize'] ?? 0}',
          icon: Icons.storage,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        if (data['lastEventTime'] != null) ...[
          _MetricRow(
            label: 'Last Event',
            value: data['lastEventTime'],
            icon: Icons.access_time,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
        ],
        _MetricRow(
          label: 'System Status',
          value: data['isHealthy'] == true ? 'HEALTHY' : 'UNHEALTHY',
          icon: data['isHealthy'] == true ? Icons.check_circle : Icons.error,
          color: data['isHealthy'] == true ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
