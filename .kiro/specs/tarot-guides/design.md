# Design Document - Tarot Guides Feature

## Overview

The Tarot Guides feature introduces four distinct AI-powered guide personalities that provide personalized tarot card interpretations. Each guide has a unique voice, visual identity, and area of expertise, allowing users to select the type of guidance that matches their current needs. The feature integrates seamlessly into the existing reading flow, appearing after topic selection and before card drawing.

## Architecture

### Integration Points
- **Reading Flow**: Inserts between topic selection and spread selection
- **State Management**: Extends existing Riverpod providers for reading state
- **Localization**: Integrates with existing dynamic content localization system
- **UI Components**: Follows established widget patterns and theme system

### Data Flow
1. User selects reading topic (Self, Love, Work, Social)
2. System presents guide selection interface
3. User selects preferred guide
4. Guide selection is stored in reading session state
5. Selected guide influences all card interpretations in the reading
6. Guide personality is applied to interpretation generation

## Components and Interfaces

### 1. Guide Model (`lib/models/tarot_guide.dart`)

```dart
enum GuideType {
  sage,    // Zian - The Wise Mystic
  healer,  // Lyra - The Compassionate Nurturer  
  mentor,  // Kael - The Practical Strategist
  visionary // Elara - The Creative Muse
}

class TarotGuide {
  final GuideType type;
  final String name;
  final String description;
  final String expertise;
  final String iconPath;
  final Color primaryColor;
  final List<ReadingTopic> bestForTopics;
}
```

### 2. Guide Selection Widget (`lib/widgets/guide_selector_widget.dart`)

```dart
class GuideSelectorWidget extends ConsumerWidget {
  final GuideType? selectedGuide;
  final Function(GuideType) onGuideSelected;
  final ReadingTopic currentTopic;
}
```

Features:
- Grid layout with visual guide representations
- Animated guide glyphs/icons
- Expandable descriptions on tap
- Topic-based recommendations
- Smooth transitions and feedback

### 3. Guide Service (`lib/services/guide_service.dart`)

```dart
class GuideService {
  // Mock interpretation generation based on guide personality
  String generateInterpretation(TarotCard card, GuideType guide, ReadingTopic topic);
  
  // Get guide recommendations for topic
  List<GuideType> getRecommendedGuides(ReadingTopic topic);
  
  // Get guide personality traits
  GuidePersonality getGuidePersonality(GuideType guide);
}
```

### 4. Guide Provider (`lib/providers/guide_provider.dart`)

```dart
// Current selected guide for reading session
final selectedGuideProvider = StateProvider<GuideType?>((ref) => null);

// Guide service provider
final guideServiceProvider = Provider<GuideService>((ref) => GuideService());

// Available guides provider
final availableGuidesProvider = Provider<List<TarotGuide>>((ref) => GuideService.getAllGuides());
```

### 5. Updated Reading Model

Extend existing `Reading` model to include guide selection:

```dart
class Reading {
  // ... existing fields
  final GuideType? selectedGuide;
  
  // Updated constructor and methods
}
```

## Data Models

### Guide Personality Structure

```dart
class GuidePersonality {
  final String voiceTone;           // "calm, profound, esoteric"
  final List<String> vocabularyStyle; // ["metaphors", "universal energies"]
  final String focusArea;           // "spiritual insights"
  final Map<String, String> samplePhrases; // Topic-specific phrases
}
```

### Guide Visual Identity

```dart
class GuideVisualIdentity {
  final String glyphAssetPath;      // SVG or PNG path
  final Color primaryColor;
  final Color accentColor;
  final String backgroundPattern;   // Optional pattern overlay
}
```

### Mock Interpretation Templates

```dart
class InterpretationTemplate {
  final GuideType guide;
  final String openingPhrase;
  final String cardContextTemplate;
  final String actionAdviceTemplate;
  final String closingPhrase;
}
```

## Guide Personalities Implementation

### 1. Zian (The Sage)
- **Visual**: Interconnected knot or constellation glyph
- **Colors**: Deep purple, cosmic blue
- **Voice**: Mystical, metaphorical, big-picture focused
- **Templates**: "The universe speaks through [card]...", "This reflects the cosmic dance of..."

### 2. Lyra (The Healer)
- **Visual**: Blooming lotus with soft pulsing light
- **Colors**: Soft pink, healing green
- **Voice**: Gentle, affirming, emotionally supportive
- **Templates**: "Your heart knows...", "Be gentle with yourself as..."

### 3. Kael (The Mentor)
- **Visual**: Geometric arrow or mountain peak
- **Colors**: Strong blue, grounded brown
- **Voice**: Direct, practical, action-oriented
- **Templates**: "The practical step forward is...", "Focus your energy on..."

### 4. Elara (The Visionary)
- **Visual**: Swirling nebula or galaxy eye
- **Colors**: Vibrant purple, creative orange
- **Voice**: Inspiring, possibility-focused, creative
- **Templates**: "Imagine if...", "What new possibility is calling..."

## Error Handling

### Graceful Fallbacks
- If no guide selected: Default to neutral interpretation style
- If guide data unavailable: Fall back to standard card meanings
- If localization missing: Use English guide descriptions with fallback

### Validation
- Ensure guide selection persists through reading session
- Validate guide compatibility with selected topic
- Handle edge cases in interpretation generation

## Testing Strategy

*Note: As requested, detailed testing implementation is excluded, but the architecture supports:*
- Unit testing of guide service logic
- Widget testing of guide selection interface
- Integration testing of reading flow with guides
- Mock data for guide personalities and interpretations

## Performance Considerations

### Optimization Strategies
- Lazy load guide assets and descriptions
- Cache interpretation templates
- Preload guide glyphs during app initialization
- Efficient state management with Riverpod

### Memory Management
- Dispose of unused guide resources
- Optimize image assets for guide visuals
- Minimize interpretation template memory footprint

## Localization Integration

### Multi-language Support
- Guide names and descriptions in English/Spanish
- Localized interpretation templates
- Cultural adaptation of guide personalities
- Integration with existing `DynamicContentLocalizations`

### Implementation Approach
```dart
// Extend existing localization service
class GuideLocalizations {
  static String getGuideName(GuideType guide, Locale locale);
  static String getGuideDescription(GuideType guide, Locale locale);
  static InterpretationTemplate getLocalizedTemplate(GuideType guide, Locale locale);
}
```

## Integration with Existing Systems

### Reading Provider Updates
- Extend `ReadingProvider` to include guide selection
- Update reading creation flow to capture guide choice
- Modify interpretation generation to use selected guide

### Router Integration
- Add guide selection route between topic and spread selection
- Handle navigation state for guide selection
- Support back navigation to change guide mid-reading

### Theme Integration
- Guide colors integrate with existing `AppTheme`
- Visual elements follow established design patterns
- Animations use existing `AppTheme` duration constants

## Future Extensibility

### Planned Enhancements
- User preference for default guide per topic
- Guide personality customization options
- Additional guide types based on user feedback
- Guide-specific reading spreads

### Architecture Support
- Modular guide system allows easy addition of new guides
- Template-based interpretation system supports customization
- Provider-based state management scales with new featurese: Straightforward instructions, actionable insights, goal-oriented

**ElaraInterpreter (The Visionary)**
- Voice: Inspiring, expansive, creative
- Focus: Possibilities, creativity, untapped potential
- Language: Imaginative metaphors, "what if" scenarios, creative exploration

### State Management

#### GuideProvider (Riverpod)
```dart
final selectedGuideProvider = StateProvider<GuideType?>((ref) => null);

final guidesProvider = Provider<List<Guide>>((ref) {
  final locale = ref.watch(languageProvider);
  return GuideService.getLocalizedGuides(locale);
});

final guideRecommendationProvider = Provider.family<GuideType?, ReadingTopic>((ref, topic) {
  return GuideService.getRecommendedGuide(topic);
});
```

## Data Models

### Guide Visual Identity System

#### Visual Glyphs
Each guide has a unique visual identity:

- **Zian (The Sage)**: Interconnected Celtic knot or constellation pattern
- **Lyra (The Healer)**: Blooming lotus with soft pulsing light effect
- **Kael (The Mentor)**: Clean geometric arrow or mountain peak
- **Elara (The Visionary)**: Swirling nebula or galaxy eye

#### Color Palette
- **Zian**: Deep purple with gold accents (#6B46C1 + #F59E0B)
- **Lyra**: Soft pink with warm white (#EC4899 + #FEF7FF)
- **Kael**: Strong blue with silver (#2563EB + #E5E7EB)
- **Elara**: Cosmic purple with starlight (#8B5CF6 + #FBBF24)

### Localization Structure

#### Guide Content Localization
```json
{
  "guides": {
    "zian": {
      "name": "Zian",
      "description": "The Wise Mystic who speaks in cosmic truths",
      "expertise": "Deep spiritual insight and universal patterns",
      "tagline": "Connecting you to universal wisdom"
    },
    "lyra": {
      "name": "Lyra", 
      "description": "The Compassionate Healer who nurtures your heart",
      "expertise": "Emotional healing and self-compassion",
      "tagline": "Gentle guidance for your healing journey"
    }
    // ... etc for kael and elara
  }
}
```

## Error Handling

### Graceful Degradation
- If guide selection fails, fall back to standard interpretation
- If guide-specific interpretation fails, use base interpretation with guide voice overlay
- Maintain reading functionality even if guide system is unavailable

### Error Recovery
- Guide selection timeout: Auto-select recommended guide for topic
- Interpretation generation failure: Fall back to standard interpretation
- Localization missing: Use English fallback with guide personality intact

### User Experience Continuity
- Save guide preference for session (not permanently)
- Allow guide change mid-reading if desired
- Maintain reading flow even with guide system errors

## Testing Strategy

### Unit Tests
- **Guide Model Tests**: Validation, serialization, localization
- **Interpreter Tests**: Voice consistency, topic appropriateness, output quality
- **Service Tests**: Guide selection logic, interpretation generation, error handling

### Widget Tests
- **GuideSelectionWidget**: Selection interaction, visual feedback, accessibility
- **GuideCard**: Visual rendering, animation behavior, state management
- **GuideDetailModal**: Content display, navigation, confirmation flow

### Integration Tests
- **Complete Reading Flow**: Topic → Guide → Spread → Cards → Interpretation
- **Localization**: Guide content in multiple languages
- **State Persistence**: Guide selection throughout reading session

### User Experience Tests
- **Guide Personality Consistency**: Verify each guide maintains distinct voice
- **Topic Appropriateness**: Ensure guide recommendations match topic context
- **Performance**: Guide selection and interpretation generation speed
- **Accessibility**: Screen reader compatibility, keyboard navigation

## Performance Considerations

### Lazy Loading
- Guide assets loaded on-demand when guide selection screen appears
- Interpreter classes instantiated only when needed
- Guide images and animations optimized for smooth performance

### Caching Strategy
- Guide definitions cached in memory after first load
- Interpretation templates cached per guide type
- Visual assets preloaded during app initialization

### Memory Management
- Guide selection state cleared after reading completion
- Interpreter instances reused within session
- Image assets managed through existing ImageCacheService

## Accessibility Features

### Screen Reader Support
- Semantic labels for all guide elements
- Descriptive text for guide glyphs and visual elements
- Clear navigation announcements

### Keyboard Navigation
- Tab order through guide selection
- Enter/Space for selection
- Escape to return to previous screen

### Visual Accessibility
- High contrast mode support for guide colors
- Scalable text for guide descriptions
- Alternative text for all visual elements

## Integration Points

### Existing Systems Integration

#### Router Integration
- New route: `/reading/guide-selection`
- Integrated into existing reading flow after topic selection
- Maintains navigation stack for back button functionality

#### Localization Integration
- Extends existing `app_en.arb` and `app_es.arb` files
- Uses existing `DynamicContentLocalizations` service
- Maintains consistency with current localization patterns

#### Theme Integration
- Guide colors complement existing `AppTheme` color scheme
- Animations use existing `AppTheme` duration constants
- Visual elements follow established design patterns

#### State Management Integration
- Integrates with existing `ReadingProvider`
- Uses established Riverpod patterns
- Maintains compatibility with existing reading state

This design ensures the Tarot Guides feature integrates seamlessly with the existing Lunanul app architecture while providing a rich, personalized experience that enhances the core tarot reading functionality.