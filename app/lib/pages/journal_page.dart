import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/journal_provider.dart';
import '../models/reading.dart';
import '../models/enums.dart';
import '../utils/constants.dart';
import '../widgets/journal_entry_widget.dart';
import '../widgets/share_reading_dialog.dart';
import 'reading_detail_page.dart';

/// Journal page showing chronological list of saved readings
class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  ReadingTopic? _selectedTopic;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedReadingsAsync = ref.watch(savedReadingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Journal'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(savedReadingsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter section
            _buildSearchAndFilter(context),

            // Journal entries list
            Expanded(
              child: savedReadingsAsync.when(
                data: (readings) => _buildJournalList(context, readings),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorState(context, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search readings...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Topic filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedTopic == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTopic = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...ReadingTopic.values.map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(topic.displayName),
                      selected: _selectedTopic == topic,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTopic = selected ? topic : null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList(BuildContext context, List<Reading> readings) {
    // Filter readings based on search and topic
    final filteredReadings = readings.where((reading) {
      // Topic filter
      if (_selectedTopic != null && reading.topic != _selectedTopic) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return reading.displayTitle.toLowerCase().contains(query) ||
            (reading.userReflection?.toLowerCase().contains(query) ?? false) ||
            reading.cards.any(
              (cp) =>
                  cp.card.name.toLowerCase().contains(query) ||
                  cp.card.keywords.any((k) => k.toLowerCase().contains(query)),
            );
      }

      return true;
    }).toList();

    if (filteredReadings.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: filteredReadings.length,
      itemBuilder: (context, index) {
        final reading = filteredReadings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JournalEntryWidget(
            reading: reading,
            onTap: () => _navigateToReadingDetail(context, reading),
            onShare: () => _shareReading(context, reading),
            onDelete: () => _deleteReading(context, reading),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedTopic != null
                  ? Icons.search_off
                  : Icons.book,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedTopic != null
                  ? 'No readings found'
                  : 'No journal entries yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedTopic != null
                  ? 'Try adjusting your search or filters'
                  : 'Save readings to start building your journal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && _selectedTopic == null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.add),
                label: const Text('Create Reading'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load journal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(savedReadingsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReadingDetail(BuildContext context, Reading reading) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingDetailPage(reading: reading),
      ),
    );
  }

  void _shareReading(BuildContext context, Reading reading) {
    showDialog(
      context: context,
      builder: (context) => ShareReadingDialog(reading: reading),
    );
  }

  Future<void> _deleteReading(BuildContext context, Reading reading) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: Text(
          'Are you sure you want to delete "${reading.displayTitle}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(savedReadingsProvider.notifier)
          .deleteReading(reading.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Reading deleted successfully'
                  : 'Failed to delete reading',
            ),
            backgroundColor: success
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
