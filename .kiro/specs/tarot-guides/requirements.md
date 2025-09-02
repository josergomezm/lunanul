# Requirements Document

## Introduction

The Tarot Guides feature introduces four distinct guide personalities that users can select to receive personalized tarot card interpretations. Each guide represents a different archetype with unique voice, perspective, and area of expertise, allowing users to choose the type of guidance that best matches their current emotional and spiritual needs. This feature acknowledges that users' needs vary from day to day and reading to reading, providing flexibility between gentle reassurance and direct practical advice.

## Requirements

### Requirement 1

**User Story:** As a user seeking tarot guidance, I want to choose from different guide personalities so that I can receive interpretations that match my current emotional and spiritual needs.

#### Acceptance Criteria

1. WHEN a user completes topic selection (Self, Love, Work, Social) THEN the system SHALL display a guide selection screen with four distinct guide options
2. WHEN a user views the guide selection screen THEN the system SHALL display each guide with their unique visual glyph, name, and brief description of their approach
3. WHEN a user taps on a guide glyph THEN the system SHALL show a detailed description of that guide's perspective and expertise areas
4. WHEN a user selects a guide THEN the system SHALL proceed to the card reading with that guide's personality applied to interpretations

### Requirement 2

**User Story:** As a user, I want each guide to have a distinct personality and voice so that my readings feel meaningfully different based on my selection.

#### Acceptance Criteria

1. WHEN Zian (The Sage) provides interpretations THEN the system SHALL use calm, profound, esoteric language with metaphors and focus on spiritual insights and universal energies
2. WHEN Lyra (The Healer) provides interpretations THEN the system SHALL use gentle, affirming, emotionally-focused language that emphasizes self-love and healing
3. WHEN Kael (The Mentor) provides interpretations THEN the system SHALL use clear, direct, action-oriented language with practical steps and real-world implications
4. WHEN Elara (The Visionary) provides interpretations THEN the system SHALL use inspiring, expansive language focused on possibilities, creativity, and potential

### Requirement 3

**User Story:** As a user, I want each guide to be visually distinct so that I can easily identify and connect with my preferred guide.

#### Acceptance Criteria

1. WHEN displaying Zian THEN the system SHALL show a stylized interconnected knot or constellation glyph
2. WHEN displaying Lyra THEN the system SHALL show a gentle wave or blooming lotus with soft pulsing light
3. WHEN displaying Kael THEN the system SHALL show a clean geometric arrow or stylized mountain peak
4. WHEN displaying Elara THEN the system SHALL show a swirling nebula or stylized eye with galaxy iris
5. WHEN displaying any guide THEN the system SHALL maintain visual consistency with Lunanul's calming design philosophy

### Requirement 4

**User Story:** As a user, I want to understand which guide is best suited for my current situation so that I can make an informed selection.

#### Acceptance Criteria

1. WHEN a user views guide descriptions THEN the system SHALL indicate that Zian is best for deep spiritual insight, karmic patterns, and reconnecting with higher purpose
2. WHEN a user views guide descriptions THEN the system SHALL indicate that Lyra is best for navigating difficult emotions, anxiety, and self-care focused readings
3. WHEN a user views guide descriptions THEN the system SHALL indicate that Kael is best for career, finance, practical decisions, and actionable guidance
4. WHEN a user views guide descriptions THEN the system SHALL indicate that Elara is best for creative blocks, exploring possibilities, and untapped potential

### Requirement 5

**User Story:** As a user, I want my guide selection to be remembered for the current session so that I don't have to reselect for multiple cards in the same reading.

#### Acceptance Criteria

1. WHEN a user selects a guide for a reading session THEN the system SHALL remember this selection for subsequent cards in the same reading
2. WHEN a user starts a new reading session THEN the system SHALL allow them to choose a guide again (not automatically use the previous selection)
3. WHEN a user wants to change guides mid-reading THEN the system SHALL provide an option to return to guide selection

### Requirement 6

**User Story:** As a user, I want the guide's interpretation to be contextually appropriate for my selected topic so that the guidance feels relevant and personalized.

#### Acceptance Criteria

1. WHEN a guide provides interpretation for a "Love" topic reading THEN the system SHALL tailor the guide's voice to relationship and emotional contexts
2. WHEN a guide provides interpretation for a "Work" topic reading THEN the system SHALL tailor the guide's voice to career and professional contexts
3. WHEN a guide provides interpretation for a "Self" topic reading THEN the system SHALL tailor the guide's voice to personal growth and introspection contexts
4. WHEN a guide provides interpretation for a "Social" topic reading THEN the system SHALL tailor the guide's voice to relationships and social dynamics contexts

### Requirement 7

**User Story:** As a user, I want the guide selection interface to be intuitive and accessible so that I can easily navigate and make my choice.

#### Acceptance Criteria

1. WHEN the guide selection screen loads THEN the system SHALL display all four guides in a clear, organized layout
2. WHEN a user interacts with guide elements THEN the system SHALL provide appropriate visual feedback (highlighting, animation)
3. WHEN a user needs more information about a guide THEN the system SHALL provide easy access to detailed descriptions
4. WHEN a user makes a selection THEN the system SHALL provide clear confirmation before proceeding to the reading