# Implementation Plan

- [x] 1. Create core guide data models and enums





  - Define GuideType enum with four guide types (sage, healer, mentor, visionary)
  - Create TarotGuide model class with properties for name, description, visual identity
  - Create GuidePersonality model for voice characteristics and interpretation styles
  - _Requirements: 1.1, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4_

- [x] 2. Implement guide service with mock interpretation logic





  - Create GuideService class with methods for interpretation generation
  - Implement mock interpretation templates for each guide personality
  - Add methods to get guide recommendations based on reading topic
  - Create static guide data with all four guide personalities and their characteristics
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 4.1, 4.2, 4.3, 4.4, 6.1, 6.2, 6.3, 6.4_

- [x] 3. Create guide selection UI widget





  - Build GuideSelectorWidget with grid layout for four guides
  - Implement guide visual representations using placeholder icons/glyphs
  - Add tap interactions for guide selection with visual feedback
  - Create expandable guide descriptions with expertise areas
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 7.1, 7.2, 7.3_

- [x] 4. Implement Riverpod providers for guide state management





  - Create selectedGuideProvider for current reading session
  - Add guideServiceProvider for dependency injection
  - Create availableGuidesProvider for guide data access
  - Integrate providers with existing reading state management
  - _Requirements: 1.4, 5.1, 5.2, 5.3_

- [x] 5. Extend Reading model to include guide selection





  - Update Reading class to include selectedGuide field
  - Modify Reading.copyWith, toJson, and fromJson methods
  - Update reading creation flow to capture guide selection
  - Ensure backward compatibility with existing reading data
  - _Requirements: 5.1, 5.2, 6.1, 6.2, 6.3, 6.4_



- [x] 6. Integrate guide selection into reading flow

  - Add guide selection step after topic selection in reading flow
  - Update app router to include guide selection route
  - Modify existing reading pages to handle guide selection state




  - Implement navigation between topic selection, guide selection, and spread selection
  - _Requirements: 1.1, 1.4, 5.2, 7.4_

- [x] 7. Update card interpretation generation to use selected guide

  - Modify interpretation display components to use guide-specific language
  - Integrate GuideService interpretation methods with card display widgets
  - Apply guide personality to card meanings based on selected guide
  - Ensure interpretation context matches reading topic and guide combination
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 6.1, 6.2, 6.3, 6.4_

- [x] 8. Add localization support for guide content





  - Extend existing localization system to include guide names and descriptions
  - Create localized interpretation templates for English and Spanish
  - Update guide service to use localized content based on current locale
  - Integrate with existing DynamicContentLocalizations system
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 4.1, 4.2, 4.3, 4.4_

- [x] 9. Implement guide visual assets and styling





  - Create or integrate guide glyph assets (SVG or PNG files)
  - Define guide-specific color schemes that integrate with app theme
  - Style guide selection interface with proper visual hierarchy
  - Add smooth animations and transitions for guide selection interactions
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 7.1, 7.2_

- [x] 10. Wire together complete guide selection flow





  - Connect all components into seamless user experience from topic to guide to reading
  - Ensure guide selection persists throughout reading session
  - Implement option to change guide selection mid-reading if needed
  - Verify guide-influenced interpretations appear correctly in all reading contexts
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 5.1, 5.2, 5.3, 7.4_