import 'package:flutter/material.dart';

/// Widget for inputting user reflections on readings
class ReflectionInputWidget extends StatefulWidget {
  const ReflectionInputWidget({
    super.key,
    this.initialReflection,
    this.onReflectionChanged,
    this.onSave,
    this.isLoading = false,
    this.maxLines = 5,
    this.hintText = 'Add your personal reflections on this reading...',
  });

  final String? initialReflection;
  final ValueChanged<String>? onReflectionChanged;
  final VoidCallback? onSave;
  final bool isLoading;
  final int maxLines;
  final String hintText;

  @override
  State<ReflectionInputWidget> createState() => _ReflectionInputWidgetState();
}

class _ReflectionInputWidgetState extends State<ReflectionInputWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReflection ?? '');
    _focusNode = FocusNode();

    _controller.addListener(() {
      final hasChanges = _controller.text != (widget.initialReflection ?? '');
      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
      widget.onReflectionChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReflectionInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialReflection != oldWidget.initialReflection) {
      _controller.text = widget.initialReflection ?? '';
      _hasChanges = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Reflection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Text input field
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // Character count and save button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_controller.text.length} characters',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),

                if (widget.onSave != null)
                  FilledButton.icon(
                    onPressed: _hasChanges && !widget.isLoading
                        ? widget.onSave
                        : null,
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save, size: 16),
                    label: Text(widget.isLoading ? 'Saving...' : 'Save'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),

            // Tips section
            if (_controller.text.isEmpty && !_focusNode.hasFocus)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reflection Tips:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• How do these cards relate to your current situation?\n'
                        '• What emotions or thoughts do they bring up?\n'
                        '• What actions might you take based on this guidance?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple reflection display widget for read-only viewing
class ReflectionDisplayWidget extends StatelessWidget {
  const ReflectionDisplayWidget({
    super.key,
    required this.reflection,
    this.onEdit,
  });

  final String reflection;
  final VoidCallback? onEdit;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Reflection',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit reflection',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(reflection, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
