import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/reading.dart';
import '../models/card_position.dart';
import '../providers/reading_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/save_reading_dialog.dart';

/// Page for selecting a spread type after choosing a topic
class SpreadSelectionPage extends ConsumerWidget {
  final ReadingTopic topic;

  const SpreadSelectionPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableSpreads = SpreadType.getSpreadsByTopic(topic);
    final readingFlow = ref.watch(readingFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.displayName} Reading'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic confirmation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getTopicIcon(topic),
                      size: 32,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Spread selection title
              Text(
                'Choose Your Spread',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the type of reading that resonates with your question',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),

              const SizedBox(height: 24),

              // Spread options
              ...availableSpreads.map(
                (spread) => _buildSpreadCard(
                  context,
                  ref,
                  spread,
                  readingFlow.spreadType == spread,
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: readingFlow.spreadType != null
                      ? () => _startReading(context, ref)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.buttonRadius,
                    ),
                  ),
                  child: Text(
                    readingFlow.spreadType != null
                        ? 'Start ${readingFlow.spreadType!.displayName} Reading'
                        : 'Select a Spread',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpreadCard(
    BuildContext context,
    WidgetRef ref,
    SpreadType spread,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: isSelected ? 8 : 2,
        borderRadius: AppTheme.cardRadius,
        child: InkWell(
          onTap: () {
            ref.read(readingFlowProvider.notifier).setSpreadType(spread);
          },
          borderRadius: AppTheme.cardRadius,
          child: AnimatedContainer(
            duration: AppTheme.shortAnimation,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: AppTheme.cardRadius,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryPurple
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? AppTheme.primaryPurple.withValues(alpha: 0.05)
                  : Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                // Card count indicator
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${spread.cardCount}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Spread details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spread.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.primaryPurple
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spread.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${spread.cardCount} card${spread.cardCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isSelected
                                  ? AppTheme.primaryPurple
                                  : Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
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

  void _startReading(BuildContext context, WidgetRef ref) {
    final readingFlow = ref.read(readingFlowProvider);
    if (readingFlow.topic != null && readingFlow.spreadType != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReadingInProgressPage(
            topic: readingFlow.topic!,
            spreadType: readingFlow.spreadType!,
          ),
        ),
      );
    }
  }
}

/// Page that shows the reading in progress with card dealing animation
class ReadingInProgressPage extends ConsumerStatefulWidget {
  final ReadingTopic topic;
  final SpreadType spreadType;

  const ReadingInProgressPage({
    super.key,
    required this.topic,
    required this.spreadType,
  });

  @override
  ConsumerState<ReadingInProgressPage> createState() =>
      _ReadingInProgressPageState();
}

class _ReadingInProgressPageState extends ConsumerState<ReadingInProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _dealingController;
  late AnimationController _revealController;
  late List<Animation<Offset>> _cardSlideAnimations;
  late List<Animation<double>> _cardFadeAnimations;

  bool _isDealingComplete = false;
  bool _isReadingComplete = false;
  List<bool> _revealedCards = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startReading();
  }

  void _initializeAnimations() {
    _dealingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize card animations
    _cardSlideAnimations = List.generate(
      widget.spreadType.cardCount,
      (index) =>
          Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _dealingController,
              curve: Interval(
                index * 0.1,
                (index * 0.1) + 0.3,
                curve: Curves.easeOutBack,
              ),
            ),
          ),
    );

    _cardFadeAnimations = List.generate(
      widget.spreadType.cardCount,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dealingController,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.3,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _revealedCards = List.filled(widget.spreadType.cardCount, false);
  }

  void _startReading() async {
    // Start the reading creation
    await ref
        .read(currentReadingProvider.notifier)
        .createReading(topic: widget.topic, spreadType: widget.spreadType);

    // Start dealing animation
    await _dealingController.forward();

    setState(() {
      _isDealingComplete = true;
    });

    // Wait a moment then mark reading as complete
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isReadingComplete = true;
    });
  }

  @override
  void dispose() {
    _dealingController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readingAsync = ref.watch(currentReadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic.displayName} Reading'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: readingAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
          data: (reading) => reading != null
              ? _buildReadingState(reading)
              : _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Shuffling the cards...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The universe is preparing your reading',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to create your reading. Please try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingState(Reading reading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Reading header
          _buildReadingHeader(),
          const SizedBox(height: 32),

          // Cards display
          _buildCardsDisplay(reading),

          const SizedBox(height: 32),

          // Instructions or interpretations
          if (!_isDealingComplete)
            _buildDealingInstructions()
          else if (!_isReadingComplete)
            _buildRevealInstructions()
          else
            _buildInterpretations(reading),

          const SizedBox(height: 32),

          // Action buttons
          if (_isReadingComplete) _buildActionButtons(reading),
        ],
      ),
    );
  }

  Widget _buildReadingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getTopicIcon(widget.topic),
            size: 40,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 12),
          Text(
            widget.spreadType.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Focus: ${widget.topic.displayName}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsDisplay(Reading reading) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          for (int i = 0; i < reading.cards.length; i++)
            AnimatedBuilder(
              animation: Listenable.merge([
                _cardSlideAnimations[i],
                _cardFadeAnimations[i],
              ]),
              builder: (context, child) {
                return SlideTransition(
                  position: _cardSlideAnimations[i],
                  child: FadeTransition(
                    opacity: _cardFadeAnimations[i],
                    child: _buildAnimatedCard(reading.cards[i], i),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(CardPosition cardPosition, int index) {
    final isRevealed = _revealedCards[index];

    return Positioned(
      left: _getCardPosition(index).dx,
      top: _getCardPosition(index).dy,
      child: GestureDetector(
        onTap: _isDealingComplete && !isRevealed
            ? () => _revealCard(index)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 100,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isRevealed
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryPurple,
                          AppTheme.primaryPurple.withValues(alpha: 0.8),
                        ],
                      ),
              ),
              child: isRevealed
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 32,
                          color: AppTheme.primaryPurple,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            cardPosition.card.name,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Icon(
                        Icons.auto_stories_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Offset _getCardPosition(int index) {
    // Simple horizontal layout for now
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = 100.0;
    final totalWidth =
        widget.spreadType.cardCount * cardWidth +
        (widget.spreadType.cardCount - 1) * 16;
    final startX = (screenWidth - totalWidth) / 2;

    return Offset(startX + (index * (cardWidth + 16)), 50);
  }

  void _revealCard(int index) {
    setState(() {
      _revealedCards[index] = true;
    });
  }

  Widget _buildDealingInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.shuffle, size: 32, color: AppTheme.primaryPurple),
          const SizedBox(height: 12),
          Text(
            'Cards are being dealt...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Watch as your cards are placed in their positions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.touch_app, size: 32, color: AppTheme.primaryPurple),
          const SizedBox(height: 12),
          Text(
            'Tap to reveal your cards',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Touch each card when you\'re ready to see its message',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretations(Reading reading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Reading',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...reading.cards.asMap().entries.map((entry) {
          final index = entry.key;
          final cardPosition = entry.value;
          return _buildCardInterpretation(cardPosition, index);
        }),
      ],
    );
  }

  Widget _buildCardInterpretation(CardPosition cardPosition, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardPosition.positionName,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          cardPosition.card.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                cardPosition.aiInterpretation,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Reading reading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveReading(reading),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.buttonRadius,
              ),
            ),
            child: const Text(
              'Save to Journal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _startNewReading(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
              side: BorderSide(color: AppTheme.primaryPurple),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.buttonRadius,
              ),
            ),
            child: const Text(
              'New Reading',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
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

  void _saveReading(Reading reading) {
    // Show save dialog for adding reflection
    showDialog(
      context: context,
      builder: (context) => SaveReadingDialog(reading: reading),
    ).then((saved) {
      if (saved == true) {
        // Mark as saved in current reading provider
        ref.read(currentReadingProvider.notifier).markAsSaved();
      }
    });
  }

  void _startNewReading() {
    ref.read(readingFlowProvider.notifier).reset();
    ref.read(currentReadingProvider.notifier).clearReading();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
