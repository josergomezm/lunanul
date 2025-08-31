import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/background_widget.dart';
import '../l10n/generated/app_localizations.dart';
import 'journal_page.dart';
import 'card_encyclopedia_page.dart';
import 'reading_patterns_page.dart';
import 'settings_page.dart';

/// Personal journal and learning page
class YourselfPage extends ConsumerWidget {
  const YourselfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.navigationYourself),
        centerTitle: true,
        elevation: 0,
      ),
      body: BackgroundWidget(
        imagePath: 'assets/images/bg_yourself.jpg',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page description
                Text(
                  localizations.yourTarotJourney,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.reflectOnReadings,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),

                const SizedBox(height: 32),

                // Quick stats section
                _buildQuickStats(context, ref),

                const SizedBox(height: 32),

                // Navigation sections
                _buildNavigationSections(context, localizations),

                const SizedBox(height: 32),

                // Recent journal entries
                _buildRecentJournalEntries(context, ref, localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final recentReadingsAsync = ref.watch(recentReadingsProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.yourJourney,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            recentReadingsAsync.when(
              data: (readings) => Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      localizations.totalReadings,
                      readings.length.toString(),
                      Icons.auto_stories,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      localizations.thisWeek,
                      readings
                          .where(
                            (r) =>
                                DateTime.now().difference(r.createdAt).inDays <
                                7,
                          )
                          .length
                          .toString(),
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      localizations.favoriteTopic,
                      readings.isNotEmpty
                          ? _getMostFrequentTopic(readings)
                          : localizations.none,
                      Icons.favorite,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(localizations.unableToLoadStats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
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
    );
  }

  String _getMostFrequentTopic(List readings) {
    if (readings.isEmpty) return 'None';

    final topicCounts = <String, int>{};
    for (final reading in readings) {
      final topic = reading.topic.displayName;
      topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
    }

    return topicCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Widget _buildNavigationSections(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        _buildSectionCard(
          context,
          localizations.readingJournal,
          localizations.readingJournalDescription,
          Icons.book,
          Colors.purple,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const JournalPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          context,
          localizations.cardEncyclopedia,
          localizations.cardEncyclopediaDescription,
          Icons.library_books,
          Colors.blue,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CardEncyclopediaPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          context,
          localizations.readingPatterns,
          localizations.readingPatternsDescription,
          Icons.analytics,
          Colors.green,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ReadingPatternsPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          context,
          localizations.settings,
          localizations.settingsDescription,
          Icons.settings,
          Colors.orange,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentJournalEntries(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    final recentReadingsAsync = ref.watch(recentReadingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.recentJournalEntries,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        recentReadingsAsync.when(
          data: (readings) {
            final savedReadings = readings.where((r) => r.isSaved).toList();

            if (savedReadings.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.book,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.noJournalEntriesYet,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.saveReadingsToBuildJournal,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: savedReadings
                  .take(5)
                  .map(
                    (reading) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.auto_stories,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          reading.title ??
                              '${reading.topic.displayName} Reading',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reading.createdAt.toString().split(' ')[0]),
                            if (reading.userReflection != null)
                              Text(
                                reading.userReflection!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: Text(
                          localizations.cardsCount(reading.cards.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const JournalPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(localizations.unableToLoadJournalEntries),
        ),
      ],
    );
  }
}
