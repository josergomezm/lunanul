import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/enums.dart';
import '../providers/reading_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/app_router.dart';
import '../widgets/guide_selector_widget.dart';

/// Page for selecting a guide after choosing a topic
class GuideSelectionPage extends ConsumerWidget {
  final ReadingTopic topic;

  const GuideSelectionPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final readingFlow = ref.watch(readingFlowProvider);
    final selectedGuide = readingFlow.selectedGuide;

    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.displayName} ${localizations.readings}'),
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
              _buildTopicHeader(context),

              const SizedBox(height: 32),

              // Guide selection title
              Text(
                'Choose Your Guide',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a guide whose wisdom resonates with your current needs',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),

              const SizedBox(height: 24),

              // Guide selector widget
              GuideSelectorWidget(
                selectedGuide: selectedGuide,
                currentTopic: topic,
                onGuideSelected: (guide) {
                  ref
                      .read(readingFlowProvider.notifier)
                      .setSelectedGuide(guide);
                },
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedGuide != null
                      ? () => _continueToSpreadSelection(context, ref)
                      : null,
                  child: Text(
                    selectedGuide != null
                        ? 'Continue with ${selectedGuide.guideName}'
                        : 'Select a Guide to Continue',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip guide selection option
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _skipGuideSelection(context, ref),
                  child: const Text('Skip Guide Selection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicHeader(BuildContext context) {
    return Container(
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
          Icon(_getTopicIcon(topic), size: 32, color: AppTheme.primaryPurple),
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

  void _continueToSpreadSelection(BuildContext context, WidgetRef ref) {
    final selectedGuide = ref.read(readingFlowProvider).selectedGuide;
    context.goSpreadSelection(topic, selectedGuide: selectedGuide);
  }

  void _skipGuideSelection(BuildContext context, WidgetRef ref) {
    // Clear any selected guide and continue to spread selection
    ref.read(readingFlowProvider.notifier).setSelectedGuide(null);
    context.goSpreadSelection(topic);
  }
}
