import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/manual_interpretation_provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/topic_selector_widget.dart';
import '../widgets/guide_selector_widget.dart';
import '../widgets/manual_card_display.dart';
import '../widgets/card_connections_widget.dart';
import '../widgets/card_selection_grid.dart';
import '../widgets/background_widget.dart';
import '../widgets/subscription_gate.dart';
import '../widgets/usage_tracker_widget.dart';
import '../widgets/error_display_widget.dart';
import '../utils/constants.dart';

/// Manual interpretation page for physical tarot decks
class InterpretationsPage extends ConsumerWidget {
  const InterpretationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(manualInterpretationProvider);
    final notifier = ref.read(manualInterpretationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.manualInterpretations),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => notifier.clearSelection(),
            icon: const Icon(Icons.refresh),
            tooltip: localizations.startOver,
          ),
        ],
      ),
      body: BackgroundWidget(
        imagePath: 'assets/images/bg_manual.jpg',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Usage tracker at the top
                const UsageTrackerWidget(
                  featureKey: 'manual_interpretations',
                  featureName: 'Manual Interpretations',
                ),

                const SizedBox(height: 16),

                // Error display at the top
                if (state.error != null)
                  ErrorDisplayWidget(
                    error: state.error!,
                    onDismiss: () => notifier.clearError(),
                  ),

                const SizedBox(height: 8),
                Text(
                  localizations.inputPhysicalDeck,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),

                const SizedBox(height: 32),

                // Topic selection
                _buildTopicSelection(context, ref, state, notifier),

                const SizedBox(height: 32),

                // Guide selection (optional)
                if (state.selectedTopic != null)
                  _buildGuideSelection(context, ref, state, notifier),

                if (state.selectedTopic != null) const SizedBox(height: 32),

                // Card selection section
                _buildCardSelection(context, ref, state, notifier),

                const SizedBox(height: 16),

                // Interpret button - shown when cards are selected but interpretations not requested yet
                if (state.canInterpretCards &&
                    !(state.hasRequestedInterpretation == true)) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SubscriptionGate(
                      featureKey: 'manual_interpretations',
                      gateType: GateType.action,
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => _interpretAllCards(context, ref),
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          state.isLoading
                              ? localizations.interpretingCards
                              : (state.hasCardsWithoutInterpretation
                                    ? localizations.interpretCards
                                    : localizations.reinterpretCards),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Interpretations display (only show after user clicks "Interpret")
                if (state.shouldShowInterpretations) ...[
                  InterpretationDisplay(
                    selectedCards: state.selectedCards,
                    isLoading: state.isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Save reading section - only shows after interpretation
                  _buildSaveReadingSection(context, ref, state),
                  const SizedBox(height: 32),
                ],

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
      ),
    );
  }

  Widget _buildTopicSelection(
    BuildContext context,
    WidgetRef ref,
    ManualInterpretationState state,
    ManualInterpretationNotifier notifier,
  ) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.selectReadingContext,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.chooseAreaOfLife,
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

  Widget _buildGuideSelection(
    BuildContext context,
    WidgetRef ref,
    ManualInterpretationState state,
    ManualInterpretationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        GuideSelectorWidget(
          selectedGuide: state.selectedGuide,
          onGuideSelected: (guide) => notifier.selectGuide(guide),
          currentTopic: state.selectedTopic!,
          allowDeselection: true,
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
    final localizations = AppLocalizations.of(context);
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
                  localizations.addYourCards,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              canAddCards
                  ? localizations.selectCardsFromDeck
                  : localizations.pleaseSelectContext,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),

            // Add card button
            SizedBox(
              width: double.infinity,
              child: SubscriptionGate(
                featureKey: 'manual_interpretations',
                gateType: GateType.action,
                child: ElevatedButton.icon(
                  onPressed: canAddCards
                      ? () => _showCardSelectionDialog(context, ref)
                      : null,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addCardFromDeck),
                ),
              ),
            ),

            // Clear cards button - only show when cards are selected
            if (state.hasSelectedCards) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => notifier.clearSelection(),
                  icon: const Icon(Icons.clear_all),
                  label: Text(localizations.clearAll),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInterpretations(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final savedInterpretations = ref.watch(savedManualInterpretationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.recentManualInterpretations,
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
                        localizations.noManualInterpretations,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.addCardsToGetStarted,
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
                        SnackBar(
                          content: Text(
                            localizations.interpretationDetailsComingSoon,
                          ),
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
                localizations.failedToLoadInterpretations,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveReadingSection(
    BuildContext context,
    WidgetRef ref,
    ManualInterpretationState state,
  ) {
    final localizations = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.saveReading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Save this reading to review later or start a new one.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSaveDialog(context, ref),
                    icon: const Icon(Icons.save),
                    label: Text(localizations.saveReading),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(manualInterpretationProvider.notifier)
                        .clearSelection(),
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations.startNewReading),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCardSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => _CardSelectionDialog());
  }

  Future<void> _interpretAllCards(BuildContext context, WidgetRef ref) async {
    final localizations = AppLocalizations.of(context);
    final notifier = ref.read(manualInterpretationProvider.notifier);

    try {
      await notifier.interpretAllCards();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.interpretationComplete),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to interpret cards: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final notifier = ref.read(manualInterpretationProvider.notifier);
    final interpretation = notifier.createInterpretation();

    if (interpretation == null) return;

    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.saveInterpretationDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.saveInterpretationQuestion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: localizations.personalNotes,
                hintText: localizations.addThoughts,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
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
                    SnackBar(
                      content: Text(localizations.interpretationSaved),
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
                      content: Text(localizations.failedToSave),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    );
  }
}

/// Reactive card selection dialog that updates with provider state
class _CardSelectionDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    // Note: state and notifier variables removed as they're not currently used
    // final state = ref.watch(manualInterpretationProvider);
    // final notifier = ref.read(manualInterpretationProvider.notifier);

    return Dialog(
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
                  localizations.selectCard,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card selection grid with Consumer to ensure reactivity
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(manualInterpretationProvider);
                  final notifier = ref.read(
                    manualInterpretationProvider.notifier,
                  );

                  return CardSelectionGrid(
                    cards: state.availableCards,
                    isLoading: state.isLoading || state.isSearching,
                    searchQuery: state.searchQuery,
                    onCardSelected: (card, {bool isReversed = false}) {
                      // Add card without interpretation for faster workflow
                      notifier.addCardWithoutInterpretation(
                        card,
                        isReversed: isReversed,
                      );
                      Navigator.of(context).pop();
                    },
                    onSearchChanged: (query) {
                      // Debug: Search changed to: "$query"
                      notifier.searchCards(query);
                    },
                    onSuitFilter: (suit) {
                      // Debug: Filter changed to: ${suit?.name ?? "all"}
                      notifier.filterBySuit(suit);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
