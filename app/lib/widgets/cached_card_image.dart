import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tarot_card.dart';
import '../utils/app_theme.dart';
import 'image_loading_widgets.dart';

/// Enhanced cached image widget specifically for tarot cards
/// with progressive loading and smooth transitions
class CachedCardImage extends StatefulWidget {
  final TarotCard card;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableProgressiveLoading;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final VoidCallback? onImageLoaded;
  final VoidCallback? onImageError;

  const CachedCardImage({
    super.key,
    required this.card,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableProgressiveLoading = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.onImageLoaded,
    this.onImageError,
  });

  @override
  State<CachedCardImage> createState() => _CachedCardImageState();
}

class _CachedCardImageState extends State<CachedCardImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _imageLoaded = false;
  bool _hasError = false;
  String? _retryKey;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onImageLoaded() {
    if (!_imageLoaded) {
      setState(() {
        _imageLoaded = true;
        _hasError = false;
      });
      _animationController.forward();
      widget.onImageLoaded?.call();
    }
  }

  void _onImageError() {
    setState(() {
      _hasError = true;
      _imageLoaded = false;
    });
    widget.onImageError?.call();
  }

  void _retryLoad() {
    setState(() {
      _hasError = false;
      _imageLoaded = false;
      _retryKey = DateTime.now().millisecondsSinceEpoch.toString();
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        widget.card.imageUrl + (_retryKey != null ? '?retry=$_retryKey' : '');

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background placeholder (always visible)
            CardImagePlaceholder(
              width: widget.width,
              height: widget.height,
              cardName: widget.card.name,
            ),

            // Main image with progressive loading
            if (!_hasError)
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                fadeInDuration: Duration.zero, // We handle our own fade
                fadeOutDuration: widget.fadeOutDuration,

                errorWidget: (context, url, error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onImageError();
                  });
                  return const SizedBox.shrink();
                },
                imageBuilder: (context, imageProvider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onImageLoaded();
                  });

                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: widget.fit,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                // Progressive loading configuration
                progressIndicatorBuilder: widget.enableProgressiveLoading
                    ? (context, url, downloadProgress) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Show a low-quality placeholder while loading
                            SimpleImagePlaceholder(
                              width: widget.width,
                              height: widget.height,
                            ),
                            // Progress indicator
                            if (downloadProgress.progress != null)
                              Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 2,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                          ],
                        );
                      }
                    : null,
              ),

            // Error state overlay
            if (_hasError)
              CardImageError(
                width: widget.width,
                height: widget.height,
                cardName: widget.card.name,
                onRetry: _retryLoad,
              ),

            // Reversed card indicator overlay
            if (widget.card.isReversed && _imageLoaded)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.red.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.rotate_left,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Simplified cached image widget for non-card images
class CachedAppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration fadeInDuration;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) =>
          placeholder ?? SimpleImagePlaceholder(width: width, height: height),
      errorWidget: (context, url, error) =>
          errorWidget ?? CardImageError(width: width, height: height),
    );
  }
}
