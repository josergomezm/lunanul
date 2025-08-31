import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading.dart';
import '../models/enums.dart';
import '../providers/journal_provider.dart';
import '../widgets/card_widget.dart';
import '../widgets/reflection_input_widget.dart';
import '../utils/constants.dart';

/// Page for viewing detailed reading information with reflection editing
class ReadingDetailPage extends ConsumerStatefulWidget {
  const ReadingDetailPage({super.key, required this.reading});

  final Reading reading;

  @override
  ConsumerState<ReadingDetailPage> createState() => _ReadingDetailPageState();
}

class _ReadingDetailPageState extends ConsumerState<ReadingDetailPage> {
  bool _isEditingReflection = false;
  bool _isSavingReflection = false;
  String _currentReflection = '';

  @override
  void initState() {
    super.initState();
    _currentReflection = widget.reading.userReflection ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reading.displayTitle),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Reading'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Reading', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reading header
              _buildReadingHeader(),

              const SizedBox(height: 24),

              // Cards section
              _buildCardsSection(),

              const SizedBox(height: 24),

              // Reflection section
              _buildReflectionSection(),

              const SizedBox(height: 24),

              // Reading statistics
              _buildReadingStatistics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTopicColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTopicIcon(),
                    color: _getTopicColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reading.topic.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.reading.spreadType.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date and time
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.reading.formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.style,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.reading.cards.length} cards',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cards & Interpretations',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        ...widget.reading.orderedCards.map((cardPosition) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Position name
                    Text(
                      cardPosition.positionName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card image
                        SizedBox(
                          width: 80,
                          height: 140,
                          child: CardWidget(
                            card: cardPosition.card,
                            isRevealed: true,
                            size: CardSize.small,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Card info and interpretation
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardPosition.card.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),

                              if (cardPosition.card.isReversed)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Reversed',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Position meaning
                              Text(
                                cardPosition.positionMeaning,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),

                              const SizedBox(height: 8),

                              // AI interpretation
                              Text(
                                cardPosition.aiInterpretation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReflectionSection() {
    if (_isEditingReflection || widget.reading.userReflection == null) {
      return ReflectionInputWidget(
        initialReflection: _currentReflection,
        onReflectionChanged: (reflection) {
          _currentReflection = reflection;
        },
        onSave: _saveReflection,
        isLoading: _isSavingReflection,
      );
    } else {
      return ReflectionDisplayWidget(
        reflection: widget.reading.userReflection!,
        onEdit: () {
          setState(() {
            _isEditingReflection = true;
          });
        },
      );
    }
  }

  Widget _buildReadingStatistics() {
    final stats = widget.reading.statistics;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildStatChip(
                  'Major Arcana',
                  '${stats['majorArcanaCount']}',
                  Icons.star,
                ),
                _buildStatChip(
                  'Minor Arcana',
                  '${stats['minorArcanaCount']}',
                  Icons.style,
                ),
                _buildStatChip(
                  'Reversed',
                  '${stats['reversedCount']}',
                  Icons.flip,
                ),
                _buildStatChip(
                  'Suits',
                  '${stats['uniqueSuits']}',
                  Icons.category,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReflection() async {
    setState(() {
      _isSavingReflection = true;
    });

    try {
      final success = await ref
          .read(savedReadingsProvider.notifier)
          .updateReflection(widget.reading.id, _currentReflection);

      if (success) {
        setState(() {
          _isEditingReflection = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reflection saved successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save reflection'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingReflection = false;
        });
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareReading();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _shareReading() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: const Text(
          'Are you sure you want to delete this reading? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReading();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReading() async {
    final success = await ref
        .read(savedReadingsProvider.notifier)
        .deleteReading(widget.reading.id);

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete reading'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getTopicIcon() {
    switch (widget.reading.topic) {
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

  Color _getTopicColor() {
    switch (widget.reading.topic) {
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
}

/// Widget for displaying existing reflection with edit option
class ReflectionDisplayWidget extends StatelessWidget {
  final String reflection;
  final VoidCallback onEdit;

  const ReflectionDisplayWidget({
    super.key,
    required this.reflection,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Reflection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reflection,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
