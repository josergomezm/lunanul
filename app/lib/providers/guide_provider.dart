import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarot_guide.dart';
import '../models/enums.dart';
import '../services/guide_service.dart';
import '../services/guide_localizations.dart';
import '../l10n/generated/app_localizations.dart';

/// Provider for the GuideService instance
final guideServiceProvider = Provider<GuideService>((ref) {
  return GuideService();
});

/// Provider for the GuideLocalizations service
final guideLocalizationsProvider = Provider<GuideLocalizations>((ref) {
  return GuideLocalizations();
});

/// Provider for current selected guide in reading session
/// This is reset when a new reading session starts
final selectedGuideProvider = StateProvider<GuideType?>((ref) => null);

/// Provider for all available guides
final availableGuidesProvider = Provider<List<TarotGuide>>((ref) {
  final guideService = ref.read(guideServiceProvider);
  return guideService.getAllGuides();
});

/// Provider for localized guides based on current locale
final localizedGuidesProvider = Provider<List<TarotGuide>>((ref) {
  final guideService = ref.read(guideServiceProvider);
  // Note: locale watching removed as it's not currently used
  // final locale = ref.watch(languageProvider);

  // Get AppLocalizations from context - this will be provided by the widget
  // For now, return non-localized guides as fallback
  return guideService.getAllGuides();
});

/// Provider for localized guides with AppLocalizations
final localizedGuidesWithLocalizationsProvider =
    Provider.family<List<TarotGuide>, AppLocalizations>((ref, localizations) {
      final guideService = ref.read(guideServiceProvider);
      return guideService.getLocalizedGuides(localizations);
    });

/// Provider for getting a specific guide by type
final guideByTypeProvider = Provider.family<TarotGuide?, GuideType>((
  ref,
  type,
) {
  final guideService = ref.read(guideServiceProvider);
  return guideService.getGuideByType(type);
});

/// Provider for guide recommendations based on reading topic
final recommendedGuidesProvider =
    Provider.family<List<GuideType>, ReadingTopic>((ref, topic) {
      final guideService = ref.read(guideServiceProvider);
      return guideService.getRecommendedGuides(topic);
    });

/// Provider for the best guide recommendation for a specific topic
final bestGuideForTopicProvider = Provider.family<GuideType?, ReadingTopic>((
  ref,
  topic,
) {
  final guideService = ref.read(guideServiceProvider);
  return guideService.getBestGuideForTopic(topic);
});

/// Provider for checking if a guide is selected
final hasSelectedGuideProvider = Provider<bool>((ref) {
  final selectedGuide = ref.watch(selectedGuideProvider);
  return selectedGuide != null;
});

/// Provider for getting the currently selected guide object
final currentGuideProvider = Provider<TarotGuide?>((ref) {
  final selectedGuideType = ref.watch(selectedGuideProvider);
  if (selectedGuideType == null) return null;

  final guideService = ref.read(guideServiceProvider);
  return guideService.getGuideByType(selectedGuideType);
});

/// State notifier for managing guide selection flow
class GuideSelectionNotifier extends StateNotifier<GuideSelectionState> {
  GuideSelectionNotifier(this._guideService)
    : super(GuideSelectionState.initial());

  final GuideService _guideService;

  /// Set the current reading topic for guide recommendations
  void setReadingTopic(ReadingTopic topic) {
    final recommendedGuides = _guideService.getRecommendedGuides(topic);
    final bestGuide = _guideService.getBestGuideForTopic(topic);

    state = state.copyWith(
      currentTopic: topic,
      recommendedGuides: recommendedGuides,
      suggestedGuide: bestGuide,
    );
  }

  /// Select a guide for the current reading session
  void selectGuide(GuideType guideType) {
    state = state.copyWith(selectedGuide: guideType);
  }

  /// Clear guide selection
  void clearSelection() {
    state = state.copyWith(selectedGuide: null);
  }

  /// Reset the guide selection flow
  void reset() {
    state = GuideSelectionState.initial();
  }

  /// Check if ready to proceed with reading
  bool get canProceedWithReading => state.selectedGuide != null;

  /// Get guide recommendations for current topic
  List<GuideType> get currentRecommendations => state.recommendedGuides;

  /// Get suggested guide for current topic
  GuideType? get currentSuggestion => state.suggestedGuide;
}

/// State class for guide selection flow
class GuideSelectionState {
  const GuideSelectionState({
    this.currentTopic,
    this.selectedGuide,
    this.recommendedGuides = const [],
    this.suggestedGuide,
  });

  final ReadingTopic? currentTopic;
  final GuideType? selectedGuide;
  final List<GuideType> recommendedGuides;
  final GuideType? suggestedGuide;

  factory GuideSelectionState.initial() {
    return const GuideSelectionState();
  }

  GuideSelectionState copyWith({
    ReadingTopic? currentTopic,
    GuideType? selectedGuide,
    List<GuideType>? recommendedGuides,
    GuideType? suggestedGuide,
  }) {
    return GuideSelectionState(
      currentTopic: currentTopic ?? this.currentTopic,
      selectedGuide: selectedGuide,
      recommendedGuides: recommendedGuides ?? this.recommendedGuides,
      suggestedGuide: suggestedGuide ?? this.suggestedGuide,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuideSelectionState &&
        other.currentTopic == currentTopic &&
        other.selectedGuide == selectedGuide &&
        other.recommendedGuides.length == recommendedGuides.length &&
        other.suggestedGuide == suggestedGuide;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentTopic,
      selectedGuide,
      recommendedGuides.length,
      suggestedGuide,
    );
  }

  @override
  String toString() {
    return 'GuideSelectionState(topic: $currentTopic, selected: $selectedGuide, recommended: ${recommendedGuides.length})';
  }
}

/// Provider for guide selection flow state
final guideSelectionProvider =
    StateNotifierProvider<GuideSelectionNotifier, GuideSelectionState>((ref) {
      final guideService = ref.read(guideServiceProvider);
      return GuideSelectionNotifier(guideService);
    });
