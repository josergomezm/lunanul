import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../widgets/guide_selector_widget.dart';
import '../utils/app_theme.dart';

/// Demo page to showcase the GuideSelectorWidget functionality
class GuideSelectorDemoPage extends ConsumerStatefulWidget {
  const GuideSelectorDemoPage({super.key});

  @override
  ConsumerState<GuideSelectorDemoPage> createState() =>
      _GuideSelectorDemoPageState();
}

class _GuideSelectorDemoPageState extends ConsumerState<GuideSelectorDemoPage> {
  GuideType? _selectedGuide;
  ReadingTopic? _selectedTopic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Selector Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Topic selector for demonstration
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            margin: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.lightLavender,
              borderRadius: AppTheme.cardRadius,
              border: Border.all(
                color: AppTheme.primaryPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Topic',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Choose a topic to see guide recommendations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Wrap(
                  spacing: AppTheme.spacingS,
                  runSpacing: AppTheme.spacingS,
                  children: [
                    ...ReadingTopic.values.map(
                      (topic) => _buildTopicChip(topic),
                    ),
                    _buildClearTopicChip(),
                  ],
                ),
              ],
            ),
          ),

          // Guide selector widget
          Expanded(
            child: GuideSelectorWidget(
              selectedGuide: _selectedGuide,
              currentTopic: _selectedTopic,
              onGuideSelected: (guide) {
                setState(() {
                  _selectedGuide = guide;
                });
                if (guide != null) {
                  _showSelectionDialog(guide);
                }
              },
            ),
          ),

          // Selection status
          if (_selectedGuide != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              margin: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Guide',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    '${_selectedGuide!.guideName}, ${_selectedGuide!.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    _selectedGuide!.expertise,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(ReadingTopic topic) {
    final isSelected = _selectedTopic == topic;

    return FilterChip(
      label: Text(topic.displayName),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTopic = selected ? topic : null;
        });
      },
      selectedColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryPurple,
      side: BorderSide(
        color: isSelected
            ? AppTheme.primaryPurple
            : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildClearTopicChip() {
    return ActionChip(
      label: const Text('Clear Topic'),
      onPressed: _selectedTopic != null
          ? () {
              setState(() {
                _selectedTopic = null;
              });
            }
          : null,
      backgroundColor: Colors.grey.withValues(alpha: 0.1),
      side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
    );
  }

  void _showSelectionDialog(GuideType guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Guide Selected'),
        content: Text(
          'You have selected ${guide.guideName}, ${guide.title}.\n\n'
          '${guide.expertise}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
