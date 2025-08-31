import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/manual_interpretation_provider.dart';
import '../widgets/topic_selector_widget.dart';
import '../widgets/manual_card_display.dart';
import '../widgets/card_connections_widget.dart';
import '../widgets/card_selection_grid.dart';
import '../utils/constants.dart';

/// Manual interpretation page for physical tarot decks
class InterpretationsPage extends ConsumerWidget {
  const InterpretationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manualInterpretationProvider);
    final notifier = ref.read(manualInterpretationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Interpretations'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (state.hasSelectedCards)
            IconButton(
              onPressed: () => _showSaveDialog(context, ref),
              icon: const Icon(Icons.save),
              tooltip: 'Save interpretation',
            ),
          IconButton(
            onPressed: () => notifier.clearSelection(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Start over',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Input your physical deck draws for AI-enhanced insights',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),

              const SizedBox(height: 32),

              // Topic selection
              _buildTopicSelection(context, ref, state, notifier),

              const SizedBox(height: 32),

              // Card selection section
              _buildCardSelection(context, ref, state, notifier),

              const SizedBox(height: 32),

              // Selected cards display
              ManualCardDisplay(
                selectedCards: state.selectedCards,
                onRemoveCard: (index) => notifier.removeCard(index),
                onUpdatePosition: (index, newPosition) =>
                    notifier.updateCardPosition(index, newPosition),
                isLoading: state.isLoading,
              ),

              const SizedBox(height: 24),

              // Card connections
              if (state.hasConnections)
                ExpandableCardConnections(connections: state.connections),

              const SizedBox(height: 32),

              // Recent interpretations
              _buildRecentInterpretations(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSelection(
    BuildContext context,
    WidgetRef ref,
    ManualInterpretationState state,
    ManualInterpretationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select reading context',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the area of life you want to explore',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        TopicSelectorWidget(
          selectedTopic: state.selectedTopic,
          onTopicSelected: (topic) => notifier.selectTopic(topic),
          showDescriptions: true,
        ),
      ],
    );
  }

  Widget _buildCardSelection(
    BuildContext context,
    WidgetRef ref,
    ManualInterpretationState state,
    ManualInterpretationNotifier notifier,
  ) {
    final canAddCards = state.selectedTopic != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.style, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Add your cards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              canAddCards
                  ? 'Select the cards you drew from your physical deck'
                  : 'Please select a reading context first',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),

            // Add card button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAddCards
                    ? () => _showCardSelectionDialog(context, ref)
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Card from Deck'),
              ),
            ),

            if (state.hasSelectedCards) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => notifier.clearSelection(),
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.canGenerateInterpretation
                          ? () => _showSaveDialog(context, ref)
                          : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Reading'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInterpretations(BuildContext context, WidgetRef ref) {
    final savedInterpretations = ref.watch(savedManualInterpretationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Manual Interpretations',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        savedInterpretations.when(
          data: (interpretations) {
            if (interpretations.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No manual interpretations yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add cards from your physical deck to get started',
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
              children: interpretations.take(3).map((interpretation) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        interpretation.selectedCards.length.toString(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(interpretation.displayTitle),
                    subtitle: Text(
                      '${interpretation.formattedDate} • ${interpretation.summary}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to interpretation detail
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Interpretation details coming soon'),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Failed to load interpretations: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCardSelectionDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(manualInterpretationProvider);
    final notifier = ref.read(manualInterpretationProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Select a Card',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card selection grid
              Expanded(
                child: CardSelectionGrid(
                  cards: state.availableCards,
                  isLoading: state.isLoading || state.isSearching,
                  searchQuery: state.searchQuery,
                  onCardSelected: (card) {
                    notifier.addCard(card);
                    Navigator.of(context).pop();
                  },
                  onSearchChanged: (query) => notifier.searchCards(query),
                  onSuitFilter: (suit) => notifier.filterBySuit(suit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(manualInterpretationProvider.notifier);
    final interpretation = notifier.createInterpretation();

    if (interpretation == null) return;

    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Interpretation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save this manual interpretation to your journal?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Personal notes (optional)',
                hintText: 'Add your thoughts about this reading...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = ref.read(manualInterpretationServiceProvider);
              final interpretationWithNotes = interpretation.copyWith(
                userNotes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );

              try {
                await service.saveInterpretation(interpretationWithNotes);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Interpretation saved to journal'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh the saved interpretations list
                  ref.invalidate(savedManualInterpretationsProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
