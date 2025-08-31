import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/image_preloader.dart';

/// Widget that handles image preloading in the background
class ImagePreloaderWidget extends ConsumerStatefulWidget {
  final Widget child;
  final bool preloadEssentials;
  final bool preloadAll;

  const ImagePreloaderWidget({
    super.key,
    required this.child,
    this.preloadEssentials = true,
    this.preloadAll = false,
  });

  @override
  ConsumerState<ImagePreloaderWidget> createState() =>
      _ImagePreloaderWidgetState();
}

class _ImagePreloaderWidgetState extends ConsumerState<ImagePreloaderWidget> {
  @override
  void initState() {
    super.initState();

    // Start preloading after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPreloading();
    });
  }

  Future<void> _startPreloading() async {
    if (!mounted) return;

    final preloader = ref.read(imagePreloaderProvider);

    try {
      if (widget.preloadEssentials &&
          !preloader.hasPreloadedEssentials &&
          mounted) {
        await preloader.preloadEssentialCards(context, ref);
      }

      if (widget.preloadAll && mounted) {
        await preloader.preloadAllCards(context, ref);
      }
    } catch (e) {
      debugPrint('Error during image preloading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Provider to track preloading status
final preloadingStatusProvider =
    StateNotifierProvider<PreloadingStatusNotifier, PreloadingStatus>((ref) {
      return PreloadingStatusNotifier();
    });

/// Status of image preloading
class PreloadingStatus {
  final bool isPreloadingEssentials;
  final bool isPreloadingAll;
  final bool hasPreloadedEssentials;
  final String? error;

  const PreloadingStatus({
    this.isPreloadingEssentials = false,
    this.isPreloadingAll = false,
    this.hasPreloadedEssentials = false,
    this.error,
  });

  PreloadingStatus copyWith({
    bool? isPreloadingEssentials,
    bool? isPreloadingAll,
    bool? hasPreloadedEssentials,
    String? error,
  }) {
    return PreloadingStatus(
      isPreloadingEssentials:
          isPreloadingEssentials ?? this.isPreloadingEssentials,
      isPreloadingAll: isPreloadingAll ?? this.isPreloadingAll,
      hasPreloadedEssentials:
          hasPreloadedEssentials ?? this.hasPreloadedEssentials,
      error: error,
    );
  }
}

/// Notifier for preloading status
class PreloadingStatusNotifier extends StateNotifier<PreloadingStatus> {
  PreloadingStatusNotifier() : super(const PreloadingStatus());

  void setPreloadingEssentials(bool isPreloading) {
    state = state.copyWith(isPreloadingEssentials: isPreloading);
  }

  void setPreloadingAll(bool isPreloading) {
    state = state.copyWith(isPreloadingAll: isPreloading);
  }

  void setPreloadedEssentials(bool hasPreloaded) {
    state = state.copyWith(hasPreloadedEssentials: hasPreloaded);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
