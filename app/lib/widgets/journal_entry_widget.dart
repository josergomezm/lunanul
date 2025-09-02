import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading.dart';
import '../models/card_position.dart';
import '../models/enums.dart';
import '../utils/app_theme.dart';
import '../providers/language_provider.dart';
import '../widgets/guide_interpretation_widget.dart';
import 'reading_spread_widget.dart';

/// A widget for displaying reading history entries in the journal
class JournalEntryWidget extends ConsumerStatefulWidget {
  final Reading reading;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isExpanded;

  const JournalEntryWidget({
    super.key,
    required this.reading,
    this.onTap,
    this.onShare,
    this.onDelete,
    this.showActions = true,
    this.isExpanded = false,
  });

  @override
  ConsumerState<JournalEntryWidget> createState() => _JournalEntryWidgetState();
}

class _JournalEntryWidgetState extends ConsumerState<JournalEntryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _animationController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: InkWell(
        onTap: widget.onTap ?? _toggleExpanded,
        borderRadius: AppTheme.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme),
              const SizedBox(height: 12),
              _buildSummary(),
              AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: child,
                  );
                },
                child: _buildExpandedContent(),
              ),
              if (widget.showActions) _buildActions(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTopicColor(widget.reading.topic).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTopicIcon(widget.reading.topic),
                size: 14,
                color: _getTopicColor(widget.reading.topic),
              ),
              const SizedBox(width: 4),
              Text(
                widget.reading.topic.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getTopicColor(widget.reading.topic),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Consumer(
          builder: (context, ref, child) {
            final locale = ref.watch(languageProvider);
            return Text(
              widget.reading.getFormattedDate(locale),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.reading.displayTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          widget.reading.summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        CompactReadingSpreadWidget(
          spreadType: widget.reading.spreadType,
          cards: widget.reading.cards,
          cardSize: 40,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Reading details
        Text(
          'Reading Details',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(height: 8),

        // Cards with interpretations
        ...widget.reading.orderedCards.asMap().entries.map((entry) {
          final index = entry.key;
          final cardPosition = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCardInterpretation(cardPosition, index),
          );
        }),

        // User reflection if available
        if (widget.reading.hasReflection) ...[
          const SizedBox(height: 16),
          Text(
            'Your Reflection',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              widget.reading.userReflection!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],

        // Reading statistics
        const SizedBox(height: 16),
        _buildReadingStats(),
      ],
    );
  }

  Widget _buildCardInterpretation(CardPosition cardPosition, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small card image
          Container(
            width: 40,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Card details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cardPosition.card.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (cardPosition.positionName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cardPosition.positionName,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.softGold.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                CompactGuideInterpretationWidget(
                  card: cardPosition.card,
                  topic: widget.reading.topic,
                  selectedGuide: widget.reading.selectedGuide,
                  position: cardPosition.positionName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStats() {
    final stats = widget.reading.statistics;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightLavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Statistics',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatChip('${stats['majorArcanaCount']} Major Arcana'),
              _buildStatChip('${stats['reversedCount']} Reversed'),
              _buildStatChip('${stats['uniqueSuits']} Suits'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (widget.reading.canBeShared && widget.onShare != null) ...[
            TextButton.icon(
              onPressed: widget.onShare,
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Share'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.onDelete != null) ...[
            TextButton.icon(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            ),
          ],
          const Spacer(),
          if (widget.reading.isSaved)
            Icon(Icons.bookmark, size: 16, color: AppTheme.softGold),
        ],
      ),
    );
  }

  Color _getTopicColor(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return AppTheme.primaryPurple;
      case ReadingTopic.love:
        return Colors.pink;
      case ReadingTopic.work:
        return AppTheme.softGold;
      case ReadingTopic.social:
        return Colors.blue;
    }
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
}

/// A compact version for displaying in lists
class CompactJournalEntryWidget extends ConsumerWidget {
  final Reading reading;
  final VoidCallback? onTap;

  const CompactJournalEntryWidget({
    super.key,
    required this.reading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
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
        title: Text(
          reading.displayTitle,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          reading.getFormattedDate(locale),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: reading.isSaved
            ? Icon(Icons.bookmark, color: AppTheme.softGold, size: 16)
            : null,
      ),
    );
  }

  Color _getTopicColor(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return AppTheme.primaryPurple;
      case ReadingTopic.love:
        return Colors.pink;
      case ReadingTopic.work:
        return AppTheme.softGold;
      case ReadingTopic.social:
        return Colors.blue;
    }
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
}
