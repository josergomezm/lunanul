import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../utils/app_theme.dart';
import '../providers/language_provider.dart';

/// A beautiful widget for selecting reading topics with animated buttons
class TopicSelectorWidget extends ConsumerWidget {
  final ReadingTopic? selectedTopic;
  final Function(ReadingTopic) onTopicSelected;
  final bool showDescriptions;
  final EdgeInsets padding;

  const TopicSelectorWidget({
    super.key,
    this.selectedTopic,
    required this.onTopicSelected,
    this.showDescriptions = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final dynamicLocalizations = ref.read(dynamicContentLocalizationsProvider);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your focus',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the area of life you\'d like guidance on',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildTopicGrid(context, locale, dynamicLocalizations),
        ],
      ),
    );
  }

  Widget _buildTopicGrid(
    BuildContext context,
    Locale locale,
    dynamic dynamicLocalizations,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: ReadingTopic.values.length,
      itemBuilder: (context, index) {
        final topic = ReadingTopic.values[index];
        return _buildTopicButton(topic, context, locale, dynamicLocalizations)
            .animate()
            .fadeIn(duration: AppTheme.mediumAnimation, delay: (index * 100).ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: AppTheme.mediumAnimation,
              delay: (index * 100).ms,
              curve: Curves.elasticOut,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              duration: AppTheme.mediumAnimation,
              delay: (index * 100).ms,
              curve: Curves.easeOutBack,
            );
      },
    );
  }

  Widget _buildTopicButton(
    ReadingTopic topic,
    BuildContext context,
    Locale locale,
    dynamic dynamicLocalizations,
  ) {
    final isSelected = selectedTopic == topic;

    return Material(
      elevation: isSelected ? 8 : 2,
      borderRadius: AppTheme.cardRadius,
      child: InkWell(
        onTap: () => onTopicSelected(topic),
        borderRadius: AppTheme.cardRadius,
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          decoration: BoxDecoration(
            borderRadius: AppTheme.cardRadius,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryPurple
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 3 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppTheme.cardRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  topic.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          topic.color.withValues(alpha: 0.7),
                          topic.color.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                // Soft color overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        topic.color.withValues(alpha: 0.2),
                        topic.color.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
                // Dark overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                // Selection overlay
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    ),
                  ),
                // Text content
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dynamicLocalizations.getTopicDisplayName(topic, locale),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact horizontal version of the topic selector
class CompactTopicSelectorWidget extends ConsumerWidget {
  final ReadingTopic? selectedTopic;
  final Function(ReadingTopic) onTopicSelected;
  final EdgeInsets padding;

  const CompactTopicSelectorWidget({
    super.key,
    this.selectedTopic,
    required this.onTopicSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final dynamicLocalizations = ref.read(dynamicContentLocalizationsProvider);
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ReadingTopic.values.map((topic) {
            final isSelected = selectedTopic == topic;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildCompactTopicChip(
                context,
                topic,
                isSelected,
                locale,
                dynamicLocalizations,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompactTopicChip(
    BuildContext context,
    ReadingTopic topic,
    bool isSelected,
    Locale locale,
    dynamic dynamicLocalizations,
  ) {
    return Material(
      elevation: isSelected ? 4 : 1,
      borderRadius: AppTheme.buttonRadius,
      child: InkWell(
        onTap: () => onTopicSelected(topic),
        borderRadius: AppTheme.buttonRadius,
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: AppTheme.buttonRadius,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryPurple
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppTheme.buttonRadius,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    topic.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : topic.color.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Soft color overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryPurple.withValues(alpha: 0.7)
                          : topic.color.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: Text(
                      dynamicLocalizations.getTopicDisplayName(topic, locale),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper extension for topic utilities
extension TopicSelectorHelpers on ReadingTopic {
  String get imagePath {
    switch (this) {
      case ReadingTopic.self:
        return 'assets/images/topic_self.jpg';
      case ReadingTopic.love:
        return 'assets/images/topic_love.jpg';
      case ReadingTopic.work:
        return 'assets/images/topic_work.jpg';
      case ReadingTopic.social:
        return 'assets/images/topic_social.jpg';
    }
  }

  Color get color {
    switch (this) {
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
