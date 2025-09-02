import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarot_card.dart';
import '../models/enums.dart';
import '../services/guide_service.dart';

/// Widget that displays guide-specific interpretations for a card
class GuideInterpretationWidget extends ConsumerWidget {
  final TarotCard card;
  final ReadingTopic topic;
  final GuideType? selectedGuide;
  final String? position;
  final bool showGuideInfo;

  const GuideInterpretationWidget({
    super.key,
    required this.card,
    required this.topic,
    this.selectedGuide,
    this.position,
    this.showGuideInfo = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedGuide == null) {
      return _buildStandardInterpretation(context);
    }

    return FutureBuilder<String>(
      future: _generateGuideInterpretation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        final interpretation = snapshot.data ?? card.currentMeaning;
        return _buildGuideInterpretation(context, interpretation);
      },
    );
  }

  Future<String> _generateGuideInterpretation() async {
    final guideService = GuideService();
    return guideService.generateInterpretation(
      card,
      selectedGuide!,
      topic,
      position: position,
    );
  }

  Widget _buildStandardInterpretation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showGuideInfo) ...[
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Standard Interpretation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            card.currentMeaning,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideInterpretation(
    BuildContext context,
    String interpretation,
  ) {
    final guide = GuideService().getGuideByType(selectedGuide!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              guide?.primaryColor.withValues(alpha: 0.3) ??
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showGuideInfo && guide != null) ...[
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: guide.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    guide.iconData,
                    size: 14,
                    color: guide.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${guide.name} - ${guide.title}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: guide.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            interpretation,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Generating interpretation...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to generate interpretation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version for showing guide interpretation in smaller spaces
class CompactGuideInterpretationWidget extends ConsumerWidget {
  final TarotCard card;
  final ReadingTopic topic;
  final GuideType? selectedGuide;
  final String? position;

  const CompactGuideInterpretationWidget({
    super.key,
    required this.card,
    required this.topic,
    this.selectedGuide,
    this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedGuide == null) {
      return Text(
        card.currentMeaning,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    return FutureBuilder<String>(
      future: _generateGuideInterpretation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          );
        }

        final interpretation = snapshot.data ?? card.currentMeaning;
        return Text(
          interpretation,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Future<String> _generateGuideInterpretation() async {
    final guideService = GuideService();
    return guideService.generateInterpretation(
      card,
      selectedGuide!,
      topic,
      position: position,
    );
  }
}
