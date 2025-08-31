import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/utils/app_router.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/theme_helpers.dart';
import '../widgets/card_widget.dart';
import '../widgets/loading_animations.dart';
import '../widgets/background_widget.dart';

/// Home page with Card of the Day and recent readings
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isCardRevealed = false;

  @override
  Widget build(BuildContext context) {
    // Watch providers for home page data
    final cardOfTheDayAsync = ref.watch(cardOfTheDayProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final recentReadingsAsync = ref.watch(recentReadingsProvider);

    return Scaffold(
      body: BackgroundWidget(
        imagePath: 'assets/images/home_background.png',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: StaggeredFadeInAnimation(
              delay: const Duration(milliseconds: 150),
              children: [
                // Personalized greeting
                _buildGreeting(context, currentUserAsync),

                const SizedBox(height: 32),

                // Card of the Day section
                _buildCardOfTheDay(context, ref, cardOfTheDayAsync),

                const SizedBox(height: 32),

                // Recent readings section
                _buildRecentReadings(context, recentReadingsAsync),

                const SizedBox(height: 32),

                // Optional journal prompt
                _buildJournalPrompt(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, AsyncValue currentUserAsync) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good morning';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good evening';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.8),
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeHelpers.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                greetingIcon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    currentUserAsync.when(
                      data: (user) => Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      loading: () => Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      error: (_, _) => Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to your personal sanctuary of reflection and insight.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardOfTheDay(
    BuildContext context,
    WidgetRef ref,
    AsyncValue cardOfTheDayAsync,
  ) {
    return Card(
      elevation: 8,
      color: ThemeHelpers.getCardColor(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Card of the Day',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            cardOfTheDayAsync.when(
              data: (card) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Card display with reveal animation
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCardRevealed = !_isCardRevealed;
                        });
                      },
                      child: CardWidget(
                        card: card,
                        isRevealed: _isCardRevealed,
                        size: CardSize.large,
                        enableFlipAnimation: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tap to reveal instruction or card meaning
                  if (!_isCardRevealed)
                    Column(
                      children: [
                        Text(
                          'Tap the card to reveal your daily guidance',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.touch_app,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          card.displayName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            card.currentMeaning,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isCardRevealed = false;
                            });
                            ref.invalidate(cardOfTheDayProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('New Card'),
                        ),
                      ),
                      if (_isCardRevealed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.goYourself();
                            },
                            icon: const Icon(Icons.book),
                            label: const Text('Journal'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CalmingLoadingAnimation(
                    size: 64,
                    message: 'Drawing your card...',
                  ),
                ),
              ),
              error: (error, stack) => Container(
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
                      'Unable to load your card',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(cardOfTheDayProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReadings(
    BuildContext context,
    AsyncValue recentReadingsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Readings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full readings history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full history coming soon!')),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recentReadingsAsync.when(
          data: (readings) => readings.isEmpty
              ? Card(
                  elevation: 4,
                  color: ThemeHelpers.getCardColor(context, opacity: 0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No readings yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your journey with a new reading',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to readings page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Navigate to readings page'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Start Reading'),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: readings.take(5).length,
                    itemBuilder: (context, index) {
                      final reading = readings[index];
                      return Container(
                        width: 280,
                        margin: EdgeInsets.only(
                          right: index < readings.length - 1 ? 12 : 0,
                        ),
                        child: Card(
                          elevation: 4,
                          color: ThemeHelpers.getCardColor(
                            context,
                            opacity: 0.9,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // TODO: Navigate to reading details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('View ${reading.displayTitle}'),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          reading.topic.displayName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        reading.formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    reading.displayTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reading.summary,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CalmingLoadingAnimation(
                size: 48,
                message: 'Loading readings...',
              ),
            ),
          ),
          error: (error, stack) => Card(
            elevation: 4,
            color: ThemeHelpers.getCardColor(context, opacity: 0.9),
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
                    'Unable to load recent readings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJournalPrompt(BuildContext context) {
    final prompts = [
      'What energy do you want to cultivate today?',
      'What lesson is the universe trying to teach you?',
      'How can you show yourself compassion today?',
      'What are you ready to release?',
      'What brings you peace in this moment?',
      'How can you honor your intuition today?',
      'What patterns are you noticing in your life?',
      'What would your highest self do in this situation?',
      'How can you create more balance in your life?',
      'What are you most grateful for right now?',
    ];

    final prompt = prompts[DateTime.now().day % prompts.length];

    return Card(
      elevation: 6,
      color: ThemeHelpers.getCardColor(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.6),
              Theme.of(
                context,
              ).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Daily Reflection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.6),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to journal page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Journal page coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Reflect'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        // Force rebuild to get a new prompt
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'New prompt',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
