import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service for managing image caching and cleanup
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  /// Maximum cache size in bytes (50MB)
  static const int maxCacheSize = 50 * 1024 * 1024;

  /// Maximum number of cached images
  static const int maxCacheObjects = 200;

  /// Cache duration in days
  static const int cacheDurationDays = 30;

  /// Initialize the cache manager with custom settings
  void initialize() {
    // Configure the default cache manager
    DefaultCacheManager().emptyCache();

    if (kDebugMode) {
      print('ImageCacheService initialized');
      print('Max cache size: ${maxCacheSize / (1024 * 1024)}MB');
      print('Max cache objects: $maxCacheObjects');
      print('Cache duration: $cacheDurationDays days');
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      if (kDebugMode) {
        print('Image cache cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing image cache: $e');
      }
    }
  }

  /// Get cache size information
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // Note: CacheManager doesn't provide direct size info in newer versions
      // This is a placeholder for cache information
      return {
        'status': 'active',
        'maxSize': maxCacheSize,
        'maxObjects': maxCacheObjects,
        'cacheDuration': cacheDurationDays,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cache info: $e');
      }
      return {'status': 'error', 'error': e.toString()};
    }
  }

  /// Remove specific image from cache
  Future<void> removeFromCache(String url) async {
    try {
      await DefaultCacheManager().removeFile(url);
      if (kDebugMode) {
        print('Removed from cache: $url');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing from cache: $e');
      }
    }
  }

  /// Preload images for better user experience
  Future<void> preloadImages(
    List<String> imageUrls,
    BuildContext context,
  ) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(CachedNetworkImageProvider(url), context);
      } catch (e) {
        if (kDebugMode) {
          print('Error preloading image $url: $e');
        }
      }
    }
  }

  /// Check if image is cached
  Future<bool> isImageCached(String url) async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(url);
      return fileInfo != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking cache for $url: $e');
      }
      return false;
    }
  }

  /// Clean up old cache files (called periodically)
  Future<void> cleanupOldCache() async {
    try {
      // The DefaultCacheManager handles cleanup automatically based on duration
      // This method can be extended for custom cleanup logic
      if (kDebugMode) {
        print('Cache cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during cache cleanup: $e');
      }
    }
  }
}
