import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/reading.dart';
import '../models/tarot_card.dart';
import '../providers/reading_provider.dart';
import '../utils/app_router.dart';
import '../utils/constants.dart';
import '../widgets/guide_interpretation_widget.dart';

/// Demo page to test the complete guide selection flow
class GuideFlowDemoPage extends ConsumerStatefulWidget {
  const GuideFlowDemoPage({super.key});

  @override
  ConsumerState<GuideFlowDemoPage> createState() => _GuideFlowDemoPageState();
}

class _GuideFlowDemoPageState extends ConsumerState<GuideFlowDemoPage> {
  @override
  Widget build(BuildContext context) {
    final readingFlow = ref.watch(readingFlowProvider);
    final currentReading = ref.watch(currentReadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Flow Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _resetFlow,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Flow',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flow Status Card
              _buildFlowStatusCard(readingFlow),

              const SizedBox(height: 24),

              // Navigation Buttons
              _buildNavigationButtons(readingFlow),

              const SizedBox(height: 24),

              // Current Reading Display
              if (currentReading.hasValue && currentReading.value != null)
                _buildCurrentReadingCard(currentReading.value!),

              const SizedBox(height: 24),

              // Test Guide Interpretations
              _buildGuideInterpretationTest(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowStatusCard(ReadingFlowState readingFlow) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Flow Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              'Topic',
              readingFlow.topic?.displayName ?? 'Not selected',
            ),
            _buildStatusRow(
              'Guide',
              readingFlow.selectedGuide?.guideName ?? 'Not selected',
            ),
            _buildStatusRow(
              'Spread',
              readingFlow.spreadType?.displayName ?? 'Not selected',
            ),
            _buildStatusRow('Custom Title', readingFlow.customTitle ?? 'None'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  (readingFlow.topic != null && readingFlow.spreadType != null)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      (readingFlow.topic != null &&
                          readingFlow.spreadType != null)
                      ? Colors.green
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  (readingFlow.topic != null && readingFlow.spreadType != null)
                      ? 'Ready to create reading'
                      : 'Missing required selections',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        (readingFlow.topic != null &&
                            readingFlow.spreadType != null)
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value.contains('Not selected') || value == 'None'
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ReadingFlowState readingFlow) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Navigation Test',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => context.goReadings(),
                  child: const Text('Go to Readings'),
                ),
                ElevatedButton(
                  onPressed: readingFlow.topic != null
                      ? () => context.goGuideSelection(readingFlow.topic!)
                      : null,
                  child: const Text('Go to Guide Selection'),
                ),
                ElevatedButton(
                  onPressed: readingFlow.topic != null
                      ? () => context.goSpreadSelection(
                          readingFlow.topic!,
                          selectedGuide: readingFlow.selectedGuide,
                        )
                      : null,
                  child: const Text('Go to Spread Selection'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Setup:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReadingTopic.values.map((topic) {
                return OutlinedButton(
                  onPressed: () => _setTopic(topic),
                  child: Text('Set ${topic.displayName}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentReadingCard(Reading reading) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Current Reading',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (reading.selectedGuide != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Guide: ${reading.selectedGuide!.guideName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Topic: ${reading.topic.displayName}'),
            Text('Spread: ${reading.spreadType.displayName}'),
            Text('Cards: ${reading.cards.length}'),
            Text(
              'Created: ${reading.getFormattedDate(Localizations.localeOf(context))}',
            ),

            if (reading.cards.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'First Card Interpretation:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GuideInterpretationWidget(
                card: reading.cards.first.card,
                topic: reading.topic,
                selectedGuide: reading.selectedGuide,
                position: reading.cards.first.positionName,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuideInterpretationTest() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guide Interpretation Test',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'This section tests guide interpretations with different guides for the same card.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),

            // Test with different guides
            ...GuideType.values.map((guide) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.guideName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Using a mock card for testing
                    FutureBuilder(
                      future: _createMockCard(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GuideInterpretationWidget(
                            card: snapshot.data!,
                            topic: ReadingTopic.self,
                            selectedGuide: guide,
                            position: 'Present',
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<TarotCard> _createMockCard() async {
    // Create a simple mock card for testing
    return TarotCard(
      id: 'test-card',
      name: 'The Fool',
      suit: TarotSuit.majorArcana,
      number: 0,
      imageUrl: 'assets/images/cards/major/00_fool.jpg',
      keywords: ['new beginnings', 'innocence', 'adventure'],
      uprightMeaning: 'New beginnings, innocence, spontaneity, free spirit',
      reversedMeaning: 'Recklessness, taken advantage of, inconsideration',
      isReversed: false,
    );
  }

  void _setTopic(ReadingTopic topic) {
    ref.read(readingFlowProvider.notifier).setTopic(topic);
  }

  void _resetFlow() {
    ref.read(readingFlowProvider.notifier).reset();
    ref.read(currentReadingProvider.notifier).clearReading();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flow reset successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
