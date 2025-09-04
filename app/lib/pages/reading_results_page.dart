import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/enums.dart';
import '../models/reading.dart';
import '../models/card_position.dart';
import '../providers/reading_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/guide_interpretation_widget.dart';
import '../widgets/save_reading_dialog.dart';

/// Page that shows the reading in progress with card dealing animation
class ReadingResultsPage extends ConsumerStatefulWidget {
  final ReadingTopic topic;
  final SpreadType spreadType;
  final GuideType? selectedGuide;

  const ReadingResultsPage({
    super.key,
    required this.topic,
    required this.spreadType,
    this.selectedGuide,
  });

  @override
  ConsumerState<ReadingResultsPage> createState() => _ReadingResultsPageState();
}

class _ReadingResultsPageState extends ConsumerState<ReadingResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _dealingController;
  late AnimationController _revealController;
  late List<Animation<Offset>> _cardSlideAnimations;
  late List<Animation<double>> _cardFadeAnimations;
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;

  bool _isDealingComplete = false;
  List<bool> _revealedCards = [];
  List<bool> _isFlipping = [];
  final List<int> _revealOrder = []; // Track the order cards were revealed

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

    // Initialize card animations with proper interval bounds
    _cardSlideAnimations = List.generate(widget.spreadType.cardCount, (index) {
      final startTime = (index * 0.1).clamp(0.0, 0.7);
      final endTime = (startTime + 0.3).clamp(startTime, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _dealingController,
          curve: Interval(startTime, endTime, curve: Curves.easeOutBack),
        ),
      );
    });

    _cardFadeAnimations = List.generate(widget.spreadType.cardCount, (index) {
      final startTime = (index * 0.1).clamp(0.0, 0.7);
      final endTime = (startTime + 0.3).clamp(startTime, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dealingController,
          curve: Interval(startTime, endTime, curve: Curves.easeOut),
        ),
      );
    });

    // Initialize flip animations for each card
    _flipControllers = List.generate(
      widget.spreadType.cardCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _flipAnimations = _flipControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _revealedCards = List.filled(widget.spreadType.cardCount, false);
    _isFlipping = List.filled(widget.spreadType.cardCount, false);
  }

  void _startReading() {
    // Delay the provider modification to avoid modifying during widget build
    Future(() async {
      try {
        // Start the reading creation
        await ref
            .read(currentReadingProvider.notifier)
            .createReading(
              topic: widget.topic,
              spreadType: widget.spreadType,
              selectedGuide: widget.selectedGuide,
            );

        // Only proceed with animations if the widget is still mounted
        if (!mounted) return;

        // Start dealing animation
        await _dealingController.forward();

        if (!mounted) return;
        setState(() {
          _isDealingComplete = true;
        });

        // Wait a moment for smooth transition
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (error) {
        // Error handling is managed by the provider's AsyncValue
        // The UI will show the error state automatically
      }
    });
  }

  @override
  void dispose() {
    _dealingController.dispose();
    _revealController.dispose();
    for (final controller in _flipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final readingAsync = ref.watch(currentReadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic.displayName} ${localizations.readings}'),
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
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            localizations.shufflingCards,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.universePreparingReading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final localizations = AppLocalizations.of(context);
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
            localizations.somethingWentWrong,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.unableToCreateReading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.goBack),
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

          // Instructions, revealed cards, or final interpretation
          if (!_isDealingComplete)
            _buildDealingInstructions()
          else if (!_areAllCardsRevealed()) ...[
            _buildRevealInstructions(),
            const SizedBox(height: 24),
            _buildRevealedCardMeanings(reading),
          ] else ...[
            _buildRevealedCardMeanings(reading),
            const SizedBox(height: 32),
            _buildOverallInterpretation(reading),
          ],

          const SizedBox(height: 32),

          // Action buttons
          if (_areAllCardsRevealed()) _buildActionButtons(reading),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: _getTotalCardsWidth(reading.cards.length),
          child: Stack(
            children: [
              for (int i = 0; i < reading.cards.length; i++)
                Positioned(
                  left: _getCardPosition(i).dx,
                  top: _getCardPosition(i).dy,
                  child: AnimatedBuilder(
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(CardPosition cardPosition, int index) {
    final isRevealed = _revealedCards.length > index
        ? _revealedCards[index]
        : false;
    final isFlipping = _isFlipping.length > index ? _isFlipping[index] : false;

    return GestureDetector(
      onTap: _isDealingComplete && !isRevealed && !isFlipping
          ? () => _revealCard(index)
          : null,
      child: AnimatedBuilder(
        animation: _flipAnimations[index],
        builder: (context, child) {
          final flipValue = _flipAnimations[index].value;
          final isShowingFront = flipValue >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Add perspective
              ..rotateY(flipValue * 3.14159), // Rotate around Y-axis
            child: Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isShowingFront && (isRevealed || isFlipping)
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(3.14159), // Flip the front face
                        child: _buildCardFront(cardPosition),
                      )
                    : _buildCardBack(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(CardPosition cardPosition) {
    final cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_stories, size: 32, color: AppTheme.primaryPurple),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            cardPosition.card.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryPurple,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardPosition.card.isReversed
              ? Colors.orange.shade700
              : AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Main card content (rotated if reversed)
          cardPosition.card.isReversed
              ? Transform.rotate(
                  angle: 3.14159, // 180 degrees
                  child: cardContent,
                )
              : cardContent,
          // Reversed indicator badge
          if (cardPosition.card.isReversed)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'R',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Card back image
        Image.asset(
          'assets/images/card_back.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.8),
                    AppTheme.deepBlue.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LUNANUL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Subtle overlay for depth
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Offset _getCardPosition(int index) {
    // Horizontal layout with consistent spacing
    const cardWidth = 100.0;
    const cardSpacing = 16.0;

    return Offset(index * (cardWidth + cardSpacing), 50);
  }

  double _getTotalCardsWidth(int cardCount) {
    const cardWidth = 100.0;
    const cardSpacing = 16.0;
    return cardCount * cardWidth + (cardCount - 1) * cardSpacing;
  }

  bool _areAllCardsRevealed() {
    return _revealedCards.every((revealed) => revealed);
  }

  void _revealCard(int index) async {
    if (_isFlipping[index]) return; // Prevent multiple flips

    setState(() {
      _isFlipping[index] = true;
    });

    // Start the flip animation
    await _flipControllers[index].forward();

    // Mark as revealed after flip completes
    if (mounted) {
      setState(() {
        _revealedCards[index] = true;
        _isFlipping[index] = false;
        _revealOrder.add(index); // Track reveal order
      });
    }
  }

  Widget _buildDealingInstructions() {
    final localizations = AppLocalizations.of(context);
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
            localizations.cardsBeingDealt,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.watchCardsPlaced,
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
    final localizations = AppLocalizations.of(context);
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
            localizations.tapToRevealCards,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.touchCardWhenReady,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedCardMeanings(Reading reading) {
    if (_revealOrder.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use reveal order (reversed so newest appears at top)
    final reversedOrder = _revealOrder.reversed.toList();
    final mostRecentlyRevealed = _revealOrder.isNotEmpty
        ? _revealOrder.last
        : -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Meanings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...reversedOrder.map((index) {
          final shouldAnimate = index == mostRecentlyRevealed;
          return shouldAnimate
              ? _buildAnimatedCardMeaning(reading.cards[index], index)
              : _buildCardMeaning(reading.cards[index], index);
        }),
      ],
    );
  }

  Widget _buildOverallInterpretation(Reading reading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Interpretation',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryPurple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Overall Interpretation for ${widget.topic.displayName}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Generated interpretation would be here. This will provide insights about how the revealed cards work together to answer your question about ${widget.topic.displayName.toLowerCase()}. The AI will analyze the card positions, their meanings, and their relationships to provide personalized guidance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardMeaning(CardPosition cardPosition, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          cardPosition.card.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cardPosition.card.isReversed)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Reversed',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Revealed',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GuideInterpretationWidget(
                card: cardPosition.card,
                topic: widget.topic,
                selectedGuide: widget.selectedGuide,
                position: cardPosition.positionName,
                showGuideInfo: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCardMeaning(CardPosition cardPosition, int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildCardMeaning(cardPosition, index),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(Reading reading) {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveReading(reading),
            child: Text(localizations.addPersonalReflection),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _startNewReading(),
            child: Text(localizations.newReading),
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
