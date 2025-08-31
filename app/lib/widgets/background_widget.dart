import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A flexible background widget that supports images, videos, and gradients with theme-aware overlays
///
/// The widget automatically determines the background type based on the provided path:
/// - If imagePath ends with video extensions (.mp4, .mov, .avi), it displays a video background
/// - If imagePath is provided with image extensions, it displays an image background
/// - If no imagePath is provided, it defaults to a mystical gradient background
///
/// Example usage:
/// ```dart
/// // Gradient background (default)
/// BackgroundWidget(
///   animated: true,
///   child: YourContentWidget(),
/// )
///
/// // Image background
/// BackgroundWidget(
///   imagePath: 'assets/images/mystical_background.jpg',
///   child: YourContentWidget(),
/// )
///
/// // Video background
/// BackgroundWidget(
///   imagePath: 'assets/videos/mystical_background.mp4',
///   child: YourContentWidget(),
/// )
/// ```
class BackgroundWidget extends StatefulWidget {
  const BackgroundWidget({
    super.key,
    required this.child,
    this.imagePath,
    this.animated = false,
    this.overlayOpacity,
    this.blendMode,
    this.gradientColors,
  });

  final Widget child;
  final String? imagePath;
  final bool animated;
  final double? overlayOpacity;
  final BlendMode? blendMode;
  final List<Color>? gradientColors;

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBackground();
  }

  void _initializeBackground() {
    // Initialize animation if needed
    if (widget.animated) {
      _animationController = AnimationController(
        duration: const Duration(seconds: 20),
        vsync: this,
      );
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.linear),
      );
      _animationController!.repeat();
    }

    // Initialize video if it's a video file
    if (widget.imagePath != null && _isVideoFile(widget.imagePath!)) {
      _initializeVideo();
    }
  }

  bool _isVideoFile(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  void _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.imagePath!);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0.0); // Mute the video
      _videoController!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      // Fallback to gradient if video fails to load
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background type based on imagePath
    if (widget.imagePath != null) {
      if (_isVideoFile(widget.imagePath!)) {
        return _buildVideoBackground(context, isDark);
      } else {
        return _buildImageBackground(context, isDark);
      }
    } else {
      // Default to gradient background
      return _buildGradientBackground(context, isDark);
    }
  }

  Widget _buildVideoBackground(BuildContext context, bool isDark) {
    if (!_isVideoInitialized || _videoController == null) {
      // Show gradient background while video loads or if it fails
      return _buildGradientBackground(context, isDark);
    }

    final overlayColor = _getOverlayColor(isDark);

    return Stack(
      children: [
        // Video background
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        // Overlay for better text readability
        Positioned.fill(
          child: Container(decoration: BoxDecoration(color: overlayColor)),
        ),
        // Content
        widget.child,
      ],
    );
  }

  Widget _buildImageBackground(BuildContext context, bool isDark) {
    final effectiveOpacity = widget.overlayOpacity ?? (isDark ? 0.7 : 0.8);
    final effectiveBlendMode =
        widget.blendMode ?? (isDark ? BlendMode.darken : BlendMode.lighten);
    final overlayColor = isDark
        ? Colors.black.withValues(alpha: effectiveOpacity)
        : Colors.white.withValues(alpha: effectiveOpacity);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.imagePath!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(overlayColor, effectiveBlendMode),
        ),
      ),
      child: widget.child,
    );
  }

  Widget _buildGradientBackground(BuildContext context, bool isDark) {
    final gradientColors =
        widget.gradientColors ??
        (isDark
            ? [
                const Color(0xFF1A1B3A), // Deep cosmic blue
                const Color(0xFF2D1B69), // Dark purple
                const Color(0xFF0F0F23), // Almost black
              ]
            : [
                const Color(0xFFF8FAFC), // Light lavender
                const Color(0xFFE2E8F0), // Moonlight silver
                const Color(0xFFCBD5E1), // Soft gray
              ]);

    Widget gradientContainer = Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: widget.animated && _animation != null
              ? Alignment.lerp(
                  Alignment.topRight,
                  Alignment.bottomLeft,
                  _animation!.value,
                )!
              : Alignment.topRight,
          radius: 1.5,
          colors: gradientColors,
        ),
      ),
      child: Container(
        // Add a subtle pattern overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.transparent,
                    const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    const Color(0xFF6B46C1).withValues(alpha: 0.05),
                  ]
                : [
                    Colors.transparent,
                    const Color(0xFF6B46C1).withValues(alpha: 0.03),
                    const Color(0xFF1E3A8A).withValues(alpha: 0.02),
                  ],
          ),
        ),
        child: widget.child,
      ),
    );

    if (widget.animated && _animation != null) {
      return AnimatedBuilder(
        animation: _animation!,
        builder: (context, child) => gradientContainer,
      );
    }

    return gradientContainer;
  }

  Color _getOverlayColor(bool isDark) {
    final effectiveOpacity = widget.overlayOpacity ?? (isDark ? 0.6 : 0.3);
    return isDark
        ? Colors.black.withValues(alpha: effectiveOpacity)
        : Colors.white.withValues(alpha: effectiveOpacity);
  }
}
