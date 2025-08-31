import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

/// Elegant placeholder widget shown while images are loading
class CardImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final String? cardName;

  const CardImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.cardName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.1),
            AppTheme.deepBlue.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Shimmer effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppTheme.cardRadius,
              child: Container()
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1.5.seconds,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AppTheme.primaryPurple.withValues(alpha: 0.6),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 1.5.seconds,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                if (cardName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Loading $cardName...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Elegant error widget shown when image loading fails
class CardImageError extends StatelessWidget {
  final double? width;
  final double? height;
  final String? cardName;
  final VoidCallback? onRetry;

  const CardImageError({
    super.key,
    this.width,
    this.height,
    this.cardName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          if (cardName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cardName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Image unavailable',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
                textStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 24),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple loading indicator for small images
class SimpleImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const SimpleImagePlaceholder({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryPurple,
          ),
        ),
      ),
    );
  }
}
