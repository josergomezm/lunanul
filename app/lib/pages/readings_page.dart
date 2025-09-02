import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/reading.dart';
import '../providers/reading_provider.dart';
import '../providers/journal_provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/constants.dart';
import '../utils/app_router.dart';
import '../widgets/topic_selector_widget.dart';
import '../widgets/background_widget.dart';
import 'reading_detail_page.dart';

/// AI-powered readings page with topic selection and spreads
class ReadingsPage extends ConsumerWidget {
  const ReadingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.readings),
        centerTitle: true,
        elevation: 0,
      ),
      body: BackgroundWidget(
        imagePath: 'assets/images/bg_readings.jpg',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page description
                Text(
                  localizations.chooseTopicForReading,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.aiPoweredInsights,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),

                const SizedBox(height: 32),

                // Topic selection grid
                _buildTopicGrid(context, ref),

                const SizedBox(height: 32),

                // Recent saved readings section
                _buildRecentReadings(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: ReadingTopic.values
          .map((topic) => _buildTopicCard(context, topic, ref))
          .toList(),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    ReadingTopic topic,
    WidgetRef ref,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Set the topic in the reading flow and navigate to guide selection
          ref.read(readingFlowProvider.notifier).setTopic(topic);
          context.goGuideSelection(topic);
        },
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                topic.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        topic.color.withValues(alpha: 0.7),
                        topic.color.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
              // Soft color overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      topic.color.withValues(alpha: 0.2),
                      topic.color.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              // Dark overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
              // Text content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReadings(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final savedReadingsAsync = ref.watch(savedReadingsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Saved Readings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full journal/yourself page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Navigate to Yourself page to see all readings',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            savedReadingsAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load readings',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              data: (readings) => readings.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No saved readings yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete a reading above and save it to see it here',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: readings
                          .take(3)
                          .map(
                            (reading) =>
                                _buildRecentReadingCard(context, reading),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentReadingCard(BuildContext context, Reading reading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReadingDetailPage(reading: reading),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTopicColor(reading.topic).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTopicIcon(reading.topic),
                    color: _getTopicColor(reading.topic),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reading.topic.displayName} • ${reading.spreadType.displayName}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatReadingDate(reading.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
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

  Color _getTopicColor(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return Colors.purple;
      case ReadingTopic.love:
        return Colors.pink;
      case ReadingTopic.work:
        return Colors.blue;
      case ReadingTopic.social:
        return Colors.green;
    }
  }

  String _formatReadingDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
