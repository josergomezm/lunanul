import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading.dart';
import '../providers/journal_provider.dart';
import '../widgets/reflection_input_widget.dart';
import '../l10n/generated/app_localizations.dart';

/// Dialog for saving a reading with optional reflection
class SaveReadingDialog extends ConsumerStatefulWidget {
  const SaveReadingDialog({super.key, required this.reading});

  final Reading reading;

  @override
  ConsumerState<SaveReadingDialog> createState() => _SaveReadingDialogState();
}

class _SaveReadingDialogState extends ConsumerState<SaveReadingDialog> {
  String _reflection = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.bookmark_add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.saveReadingDialog,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Reading summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reading.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.reading.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reflection input
              Expanded(
                child: SingleChildScrollView(
                  child: ReflectionInputWidget(
                    onReflectionChanged: (reflection) {
                      _reflection = reflection;
                    },
                    maxLines: 8,
                    hintText:
                        'Add your thoughts about this reading (optional)...',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveReading,
                    icon: _isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Reading'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveReading() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Create reading with reflection
      final readingToSave = widget.reading.copyWith(
        userReflection: _reflection.isNotEmpty ? _reflection : null,
        isSaved: true,
      );

      final success = await ref
          .read(savedReadingsProvider.notifier)
          .saveReading(readingToSave);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reading saved to your journal'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save reading'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// Simple save reading button widget
class SaveReadingButton extends ConsumerWidget {
  const SaveReadingButton({
    super.key,
    required this.reading,
    this.onSaved,
    this.style,
  });

  final Reading reading;
  final VoidCallback? onSaved;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAlreadySaved = ref.watch(isReadingSavedProvider(reading.id));

    if (isAlreadySaved) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.bookmark),
        label: const Text('Saved'),
        style: style,
      );
    }

    return FilledButton.icon(
      onPressed: () => _showSaveDialog(context),
      icon: const Icon(Icons.bookmark_add),
      label: const Text('Save Reading'),
      style: style,
    );
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SaveReadingDialog(reading: reading),
    ).then((saved) {
      if (saved == true) {
        onSaved?.call();
      }
    });
  }
}

/// Quick save button for immediate saving without dialog
class QuickSaveButton extends ConsumerStatefulWidget {
  const QuickSaveButton({super.key, required this.reading, this.onSaved});

  final Reading reading;
  final VoidCallback? onSaved;

  @override
  ConsumerState<QuickSaveButton> createState() => _QuickSaveButtonState();
}

class _QuickSaveButtonState extends ConsumerState<QuickSaveButton> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final isAlreadySaved = ref.watch(isReadingSavedProvider(widget.reading.id));

    if (isAlreadySaved) {
      return IconButton(
        onPressed: null,
        icon: const Icon(Icons.bookmark),
        tooltip: 'Already saved',
      );
    }

    return IconButton(
      onPressed: _isSaving ? null : _quickSave,
      icon: _isSaving
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : const Icon(Icons.bookmark_add_outlined),
      tooltip: 'Save reading',
    );
  }

  Future<void> _quickSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ref
          .read(savedReadingsProvider.notifier)
          .saveReading(widget.reading.copyWith(isSaved: true));

      if (success) {
        widget.onSaved?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reading saved'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save reading'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
