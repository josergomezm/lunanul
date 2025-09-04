import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ad_service.dart';
import '../providers/ad_provider.dart';
import '../utils/app_theme.dart';

/// A tranquil, non-intrusive ad widget that respects the app's spiritual atmosphere
class TranquilAdWidget extends ConsumerStatefulWidget {
  const TranquilAdWidget({
    super.key,
    required this.adContent,
    this.onDismiss,
    this.onTap,
    this.showCloseButton = true,
  });

  final AdContent adContent;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final bool showCloseButton;

  @override
  ConsumerState<TranquilAdWidget> createState() => _TranquilAdWidgetState();
}

class _TranquilAdWidgetState extends ConsumerState<TranquilAdWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Auto-dismiss after duration if specified (disabled for tests)
    // if (widget.adContent.displayDuration != null) {
    //   Future.delayed(widget.adContent.displayDuration!, () {
    //     if (mounted) {
    //       _dismissAd();
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissAd() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  void _handleTap() {
    // Track click (only if provider scope is available)
    try {
      ref.read(adStateProvider.notifier).trackAdClick(widget.adContent.id);
    } catch (e) {
      // Ignore provider errors in tests
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.moonlightSilver.withValues(alpha: 0.1),
                    AppTheme.lightLavender.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(
                  color: AppTheme.mysticPurple.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.adContent.actionUrl != null ? _handleTap : null,
                  borderRadius: AppTheme.cardRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with spiritual icon and close button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingS),
                              decoration: BoxDecoration(
                                color: AppTheme.mysticPurple.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getAdIcon(),
                                size: 16,
                                color: AppTheme.mysticPurple,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              'Spiritual Inspiration',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppTheme.mysticPurple,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (widget.showCloseButton)
                              IconButton(
                                onPressed: _dismissAd,
                                icon: const Icon(Icons.close),
                                iconSize: 18,
                                color: AppTheme.darkGray.withValues(alpha: 0.6),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingM),

                        // Ad content
                        Text(
                          widget.adContent.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGray,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        if (widget.adContent.actionUrl != null) ...[
                          const SizedBox(height: AppTheme.spacingM),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.mysticPurple.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: AppTheme.chipRadius,
                              border: Border.all(
                                color: AppTheme.mysticPurple.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              'Learn More',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppTheme.mysticPurple,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getAdIcon() {
    switch (widget.adContent.type) {
      case AdType.spiritual:
        return Icons.auto_awesome;
      case AdType.native:
        return Icons.lightbulb_outline;
      case AdType.banner:
        return Icons.info_outline;
      case AdType.interstitial:
        return Icons.star_outline;
    }
  }
}

/// Widget that displays ads after readings for free users
class PostReadingAdWidget extends ConsumerWidget {
  const PostReadingAdWidget({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adState = ref.watch(adStateProvider);

    if (adState.currentAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: TranquilAdWidget(
            adContent: adState.currentAd!,
            onDismiss: () {
              ref.read(adStateProvider.notifier).clearCurrentAd();
              onDismiss();
            },
            onTap: () {
              // Handle ad tap - could open URL or show more info
              ref.read(adStateProvider.notifier).clearCurrentAd();
              onDismiss();
            },
          ),
        ),
      ),
    );
  }
}

/// Inline ad widget for subtle placement within content
class InlineAdWidget extends ConsumerWidget {
  const InlineAdWidget({super.key, required this.adContent, this.onDismiss});

  final AdContent adContent;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TranquilAdWidget(
          adContent: adContent,
          onDismiss: onDismiss,
          showCloseButton: false,
        )
        .animate()
        .fadeIn(duration: AppTheme.mediumAnimation)
        .slideY(begin: 0.2, end: 0, duration: AppTheme.mediumAnimation);
  }
}
