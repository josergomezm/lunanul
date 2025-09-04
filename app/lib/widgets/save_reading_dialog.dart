import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading.dart';
import '../providers/journal_provider.dart';
import '../providers/feature_gate_provider.dart';
import '../services/subscription_feature_gate_service.dart';
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
      // Check if user can save journal entry
      final featureGateService = ref.read(featureGateServiceProvider);
      final canSave = await featureGateService.canPerformReading();

      if (!canSave) {
        // Check if it's a usage limit issue
        final upgradeRequirement = await featureGateService
            .getUpgradeRequirement(
              SubscriptionFeatureGateService.readingFeature,
            );

        if (upgradeRequirement?.isUsageBased == true) {
          // Show replacement dialog for free users who hit the limit
          if (mounted) {
            final shouldReplace = await _showReplacementDialog();
            if (!shouldReplace) {
              return; // User cancelled
            }
          }
        } else {
          // Show upgrade prompt for other restrictions
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upgrade required to save more readings'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      // Validate and consume usage (this will handle replacement if needed)
      final canProceed = await featureGateService.validateAndConsumeUsage(
        SubscriptionFeatureGateService.readingFeature,
      );

      if (!canProceed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to save reading at this time'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

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

  Future<bool> _showReplacementDialog() async {
    final savedReadingsAsync = ref.read(savedReadingsProvider);
    final savedReadings = savedReadingsAsync.value ?? [];

    if (savedReadings.isEmpty) return true; // No readings to replace

    return await showDialog<bool>(
          context: context,
          builder: (context) => JournalReplacementDialog(
            existingReadings: savedReadings,
            newReading: widget.reading,
          ),
        ) ??
        false;
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

/// Dialog for handling journal entry replacement when limit is reached
class JournalReplacementDialog extends ConsumerStatefulWidget {
  const JournalReplacementDialog({
    super.key,
    required this.existingReadings,
    required this.newReading,
  });

  final List<Reading> existingReadings;
  final Reading newReading;

  @override
  ConsumerState<JournalReplacementDialog> createState() =>
      _JournalReplacementDialogState();
}

class _JournalReplacementDialogState
    extends ConsumerState<JournalReplacementDialog> {
  Reading? _selectedReading;
  bool _isReplacing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                    Icons.swap_horiz,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Journal Full - Replace Reading',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: _isReplacing
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Explanation
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
                      'Your journal is full (3/3 readings)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To save this new reading, please select an existing reading to replace, or upgrade to Mystic for unlimited journal storage.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // New reading preview
              Text(
                'New Reading:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildReadingPreview(widget.newReading, isNew: true),

              const SizedBox(height: 20),

              // Existing readings selection
              Text(
                'Select reading to replace:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.existingReadings.map((reading) {
                      final isSelected = _selectedReading?.id == reading.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedReading = isSelected ? null : reading;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline
                                          .withValues(alpha: 0.2),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildReadingPreview(
                              reading,
                              isSelected: isSelected,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isReplacing
                          ? null
                          : () => _showUpgradeOption(),
                      child: const Text('Upgrade Instead'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isReplacing || _selectedReading == null
                          ? null
                          : _replaceReading,
                      child: _isReplacing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Replace'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingPreview(
    Reading reading, {
    bool isNew = false,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNew
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reading.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isNew ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reading.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reading.topic.displayName,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                reading.getFormattedDate(const Locale('en')),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _replaceReading() async {
    if (_selectedReading == null) return;

    setState(() {
      _isReplacing = true;
    });

    try {
      // Delete the selected reading
      final deleteSuccess = await ref
          .read(savedReadingsProvider.notifier)
          .deleteReading(_selectedReading!.id);

      if (!deleteSuccess) {
        throw Exception('Failed to delete existing reading');
      }

      // Save the new reading
      final saveSuccess = await ref
          .read(savedReadingsProvider.notifier)
          .saveReading(widget.newReading.copyWith(isSaved: true));

      if (!saveSuccess) {
        throw Exception('Failed to save new reading');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading replaced successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to replace reading: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReplacing = false;
        });
      }
    }
  }

  void _showUpgradeOption() {
    Navigator.of(context).pop(false);
    // TODO: Navigate to subscription management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upgrade to Mystic for unlimited journal storage'),
        backgroundColor: Colors.blue,
      ),
    );
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
