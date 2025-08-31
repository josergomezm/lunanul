import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_cache_provider.dart';
import '../utils/app_theme.dart';

/// Page for managing image cache settings and information
class CacheManagementPage extends ConsumerStatefulWidget {
  const CacheManagementPage({super.key});

  @override
  ConsumerState<CacheManagementPage> createState() =>
      _CacheManagementPageState();
}

class _CacheManagementPageState extends ConsumerState<CacheManagementPage> {
  bool _isClearing = false;
  bool _isCleaning = false;

  @override
  Widget build(BuildContext context) {
    final cacheInfo = ref.watch(cacheInfoProvider);
    final cacheManager = ref.read(cacheManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cache Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Cache Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    cacheInfo.when(
                      data: (info) => _buildCacheInfo(context, info),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text(
                        'Error loading cache info: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cache Management Actions
            Text(
              'Cache Management',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Clear Cache Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isClearing ? null : () => _clearCache(cacheManager),
                icon: _isClearing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.clear_all),
                label: Text(_isClearing ? 'Clearing...' : 'Clear All Cache'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cleanup Old Cache Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCleaning
                    ? null
                    : () => _cleanupOldCache(cacheManager),
                icon: _isCleaning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cleaning_services),
                label: Text(_isCleaning ? 'Cleaning...' : 'Cleanup Old Files'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Information Section
            Card(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Image Caching',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lunanul caches tarot card images to provide a smooth experience. '
                      'Cached images load faster and work offline. The cache automatically '
                      'manages its size and removes old files.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Clear cache if you\'re running low on storage\n'
                      '• Cleanup removes only expired files\n'
                      '• Images will re-download as needed',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildCacheInfo(BuildContext context, Map<String, dynamic> info) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          'Status',
          info['status']?.toString().toUpperCase() ?? 'UNKNOWN',
          info['status'] == 'active' ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Max Cache Size',
          '${(info['maxSize'] as int? ?? 0) ~/ (1024 * 1024)} MB',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Max Objects',
          info['maxObjects']?.toString() ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Cache Duration',
          '${info['cacheDuration']} days',
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Future<void> _clearCache(CacheManager cacheManager) async {
    setState(() {
      _isClearing = true;
    });

    try {
      await cacheManager.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh cache info
        ref.invalidate(cacheInfoProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  Future<void> _cleanupOldCache(CacheManager cacheManager) async {
    setState(() {
      _isCleaning = true;
    });

    try {
      await cacheManager.cleanupOldCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Old cache files cleaned up'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh cache info
        ref.invalidate(cacheInfoProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cleaning cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCleaning = false;
        });
      }
    }
  }
}
