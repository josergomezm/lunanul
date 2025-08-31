import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_cache_service.dart';

/// Provider for the image cache service
final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService();
});

/// Provider for cache information
final cacheInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final cacheService = ref.read(imageCacheServiceProvider);
  return await cacheService.getCacheInfo();
});

/// Provider for cache management operations
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final cacheService = ref.read(imageCacheServiceProvider);
  return CacheManager(cacheService);
});

/// Cache manager class for handling cache operations
class CacheManager {
  final ImageCacheService _cacheService;

  CacheManager(this._cacheService);

  /// Clear all cached images
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  /// Get cache information
  Future<Map<String, dynamic>> getCacheInfo() async {
    return await _cacheService.getCacheInfo();
  }

  /// Remove specific image from cache
  Future<void> removeFromCache(String url) async {
    await _cacheService.removeFromCache(url);
  }

  /// Check if image is cached
  Future<bool> isImageCached(String url) async {
    return await _cacheService.isImageCached(url);
  }

  /// Clean up old cache files
  Future<void> cleanupOldCache() async {
    await _cacheService.cleanupOldCache();
  }

  /// Preload images for better performance
  Future<void> preloadImages(List<String> imageUrls, context) async {
    await _cacheService.preloadImages(imageUrls, context);
  }
}
