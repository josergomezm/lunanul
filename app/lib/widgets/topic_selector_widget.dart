import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/enums.dart';
import '../utils/app_theme.dart';

/// A beautiful widget for selecting reading topics with animated buttons
class TopicSelectorWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildTopicGrid(),
        ],
      ),
    );
  }

  Widget _buildTopicGrid() {
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
        return _buildTopicButton(topic, context)
            .animate()
            .fadeIn(
              duration: AppTheme.mediumAnimation,
              delay: (index * 100).ms,
            )
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

  Widget _buildTopicButton(ReadingTopic topic, BuildContext context) {
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
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryPurple.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryPurple
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getTopicIcon(topic),
                  size: 32,
                  color: isSelected ? Colors.white : AppTheme.primaryPurple,
                ),
                const SizedBox(height: 8),
                Text(
                  topic.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showDescriptions) ...[
                  const SizedBox(height: 4),
                  Text(
                    topic.description,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
}

/// A compact horizontal version of the topic selector
class CompactTopicSelectorWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ReadingTopic.values.map((topic) {
            final isSelected = selectedTopic == topic;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildCompactTopicChip(context, topic, isSelected),
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
  ) {
    return Material(
      elevation: isSelected ? 4 : 1,
      borderRadius: AppTheme.buttonRadius,
      child: InkWell(
        onTap: () => onTopicSelected(topic),
        borderRadius: AppTheme.buttonRadius,
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppTheme.buttonRadius,
            color: isSelected ? AppTheme.primaryPurple : Colors.white,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryPurple
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTopicIcon(topic),
                size: 16,
                color: isSelected ? Colors.white : AppTheme.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                topic.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
}