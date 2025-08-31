import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/journal_provider.dart';
import '../providers/card_provider.dart';
import '../models/tarot_card.dart';
import '../utils/constants.dart';
import '../widgets/card_widget.dart';

/// Page showing reading patterns, statistics, and recurring themes
class ReadingPatternsPage extends ConsumerWidget {
  const ReadingPatternsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(readingStatisticsProvider);
    final allCardsAsync = ref.watch(allCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Patterns'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview statistics
              _buildOverviewSection(context, statisticsAsync),

              const SizedBox(height: 24),

              // Topic preferences
              _buildTopicPreferencesSection(context, statisticsAsync),

              const SizedBox(height: 24),

              // Spread preferences
              _buildSpreadPreferencesSection(context, statisticsAsync),

              const SizedBox(height: 24),

              // Most frequent cards
              _buildFrequentCardsSection(
                context,
                statisticsAsync,
                allCardsAsync,
              ),

              const SizedBox(height: 24),

              // Reflection insights
              _buildReflectionInsightsSection(context, statisticsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Reading Journey',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            statisticsAsync.when(
              data: (stats) => _buildOverviewStats(context, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Unable to load statistics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(BuildContext context, Map<String, dynamic> stats) {
    final totalReadings = stats['totalReadings'] as int;
    final readingsWithReflections = stats['readingsWithReflections'] as int;
    final averageReflectionLength = stats['averageReflectionLength'] as double;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Readings',
                totalReadings.toString(),
                Icons.auto_stories,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'With Reflections',
                readingsWithReflections.toString(),
                Icons.edit_note,
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Reflection Rate',
                totalReadings > 0
                    ? '${((readingsWithReflections / totalReadings) * 100).round()}%'
                    : '0%',
                Icons.rate_review,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg. Reflection',
                '${averageReflectionLength.round()} chars',
                Icons.text_fields,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicPreferencesSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic Preferences',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            statisticsAsync.when(
              data: (stats) {
                final topicCounts = stats['topicCounts'] as Map<String, int>;
                return _buildTopicChart(context, topicCounts);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Unable to load topic data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChart(BuildContext context, Map<String, int> topicCounts) {
    if (topicCounts.isEmpty) {
      return const Text('No topic data available');
    }

    final sortedTopics = topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedTopics.first.value;

    return Column(
      children: sortedTopics.map((entry) {
        final percentage = maxCount > 0 ? (entry.value / maxCount) : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  entry.key,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Container(
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getTopicColor(entry.key),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '${entry.value}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getTopicColor(String topic) {
    switch (topic.toLowerCase()) {
      case 'self':
        return Colors.purple;
      case 'love':
        return Colors.pink;
      case 'work':
        return Colors.blue;
      case 'social':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSpreadPreferencesSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spread Preferences',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            statisticsAsync.when(
              data: (stats) {
                final spreadCounts = stats['spreadCounts'] as Map<String, int>;
                return _buildSpreadList(context, spreadCounts);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Unable to load spread data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadList(BuildContext context, Map<String, int> spreadCounts) {
    if (spreadCounts.isEmpty) {
      return const Text('No spread data available');
    }

    final sortedSpreads = spreadCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedSpreads
          .map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  '${entry.value}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(entry.key),
              subtitle: Text('Used ${entry.value} times'),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFrequentCardsSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
    AsyncValue<List<TarotCard>> allCardsAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Frequent Cards',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            statisticsAsync.when(
              data: (stats) {
                final mostFrequentCards =
                    stats['mostFrequentCards'] as Map<String, int>;
                return allCardsAsync.when(
                  data: (cards) => _buildFrequentCardsList(
                    context,
                    mostFrequentCards,
                    cards,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Text('Unable to load card data'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Unable to load frequency data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentCardsList(
    BuildContext context,
    Map<String, int> cardCounts,
    List<TarotCard> allCards,
  ) {
    if (cardCounts.isEmpty) {
      return const Text('No card frequency data available');
    }

    final cardMap = {for (var card in allCards) card.id: card};
    final validEntries = cardCounts.entries
        .where((entry) => cardMap.containsKey(entry.key))
        .take(10)
        .toList();

    if (validEntries.isEmpty) {
      return const Text('No matching cards found');
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: validEntries.length,
        itemBuilder: (context, index) {
          final entry = validEntries[index];
          final card = cardMap[entry.key]!;

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Expanded(
                  child: CardWidget(card: card, size: CardSize.small),
                ),
                const SizedBox(height: 4),
                Text(
                  card.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${entry.value}x',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReflectionInsightsSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection Insights',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            statisticsAsync.when(
              data: (stats) => _buildReflectionInsights(context, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Unable to load reflection data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionInsights(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final totalReadings = stats['totalReadings'] as int;
    final readingsWithReflections = stats['readingsWithReflections'] as int;

    if (totalReadings == 0) {
      return const Text('No reflection data available');
    }

    final reflectionRate = (readingsWithReflections / totalReadings) * 100;

    String insight;
    IconData icon;
    Color color;

    if (reflectionRate >= 80) {
      insight =
          'Excellent! You consistently reflect on your readings. This deep engagement helps you gain more insights from your tarot practice.';
      icon = Icons.star;
      color = Colors.green;
    } else if (reflectionRate >= 50) {
      insight =
          'Good reflection habits! Consider adding notes to more readings to deepen your understanding of the cards\' messages.';
      icon = Icons.thumb_up;
      color = Colors.blue;
    } else if (reflectionRate >= 25) {
      insight =
          'You\'re starting to build reflection habits. Try adding personal thoughts to more readings to enhance your tarot journey.';
      icon = Icons.trending_up;
      color = Colors.orange;
    } else {
      insight =
          'Consider adding reflections to your readings. Personal notes help you remember insights and track your spiritual growth.';
      icon = Icons.lightbulb_outline;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reflection Rate: ${reflectionRate.round()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
