# Requirements Document

## Introduction

The Lunanul Subscription Model introduces a three-tier monetization system designed to make the free tier a genuinely useful daily tool while unlocking depth and personalization in paid tiers. The model balances accessibility with premium features, ensuring the app remains an indispensable spiritual guide for users at every level. The tiers are structured around AI token usage optimization and feature access, with clear value propositions for each level.

## Requirements

### Requirement 1: Seeker Tier (Free) - Core Daily Experience

**User Story:** As a free user, I want access to essential daily tarot features that create genuine value and establish a spiritual habit, so that I can experience the app's core benefits while understanding the value of premium features.

#### Acceptance Criteria

1. WHEN a free user accesses the daily card feature THEN the system SHALL provide unlimited access to Card of the Day with no restrictions
2. WHEN a free user requests AI readings THEN the system SHALL limit access to 1-card and 3-card spreads only
3. WHEN a free user attempts larger spreads THEN the system SHALL display upgrade prompts explaining premium spread availability
4. WHEN a free user accesses tarot guides THEN the system SHALL provide access to The Healer (Lyra) and The Mentor (Kael) only
5. WHEN a free user attempts to access The Sage or The Visionary THEN the system SHALL show upgrade messaging with guide previews
6. WHEN a free user uses manual interpretations THEN the system SHALL limit access to 5 card lookups per month
7. WHEN a free user exceeds manual interpretation limit THEN the system SHALL display usage counter and upgrade options
8. WHEN a free user saves readings THEN the system SHALL limit journal storage to 3 readings maximum
9. WHEN a free user's journal is full THEN the system SHALL prompt to upgrade or replace existing readings
10. WHEN a free user completes a reading THEN the system SHALL display a single, non-intrusive advertisement

### Requirement 2: Mystic Tier (Core Subscription) - Complete Experience

**User Story:** As a paying subscriber, I want access to the complete Lunanul experience without limitations or interruptions, so that I can fully engage with all spiritual guidance features and maintain uninterrupted focus during readings.

#### Acceptance Criteria

1. WHEN a Mystic subscriber uses the app THEN the system SHALL provide a completely ad-free experience
2. WHEN a Mystic subscriber requests AI readings THEN the system SHALL provide unlimited access to all available spreads including 7-card Horseshoe and 10-card Celtic Cross
3. WHEN a Mystic subscriber accesses tarot guides THEN the system SHALL provide access to all four guides including The Sage (Zian) and The Visionary (Elara)
4. WHEN a Mystic subscriber uses manual interpretations THEN the system SHALL provide unlimited card lookups with no monthly restrictions
5. WHEN a Mystic subscriber saves readings THEN the system SHALL provide unlimited journal storage capacity
6. WHEN a Mystic subscriber views their history THEN the system SHALL display reading statistics showing most frequent cards and recurring themes
7. WHEN a Mystic subscriber accesses any premium feature THEN the system SHALL provide immediate access without upgrade prompts

### Requirement 3: Oracle Tier (Premium Experience) - Advanced Features

**User Story:** As a premium user and tarot enthusiast, I want access to the most immersive and advanced features available, so that I can have the deepest possible spiritual experience and early access to new capabilities.

#### Acceptance Criteria

1. WHEN an Oracle subscriber completes a reading THEN the system SHALL offer AI-generated audio interpretations in the selected guide's voice
2. WHEN an Oracle subscriber finishes a reading THEN the system SHALL generate personalized journal prompts based on the specific cards drawn
3. WHEN an Oracle subscriber accesses spreads THEN the system SHALL provide access to highly specialized and advanced tarot spreads
4. WHEN an Oracle subscriber uses the app THEN the system SHALL provide early access to new guides, features, and app themes before general release
5. WHEN an Oracle subscriber accesses customization THEN the system SHALL allow selection from multiple digital card back designs
6. WHEN an Oracle subscriber personalizes their experience THEN the system SHALL provide multiple app color theme options
7. WHEN an Oracle subscriber receives journal prompts THEN the system SHALL generate contextual reflection questions specific to their reading (e.g., "The Tower appeared in your reading. What structure in your life feels unstable but needs to fall away for new growth?")

### Requirement 4: Subscription Management and Onboarding

**User Story:** As a user, I want clear information about subscription tiers and easy management of my subscription status, so that I can make informed decisions and easily upgrade or manage my account.

#### Acceptance Criteria

1. WHEN a user first opens the app THEN the system SHALL clearly communicate the current tier and available features
2. WHEN a user encounters tier limitations THEN the system SHALL display informative upgrade prompts with clear benefit explanations
3. WHEN a user wants to upgrade THEN the system SHALL provide a clear subscription selection interface with pricing and feature comparisons
4. WHEN a user subscribes THEN the system SHALL immediately unlock tier-appropriate features without requiring app restart
5. WHEN a user manages their subscription THEN the system SHALL provide access to subscription status, renewal dates, and cancellation options
6. WHEN a user's subscription expires THEN the system SHALL gracefully downgrade to appropriate tier while preserving user data
7. WHEN a user cancels their subscription THEN the system SHALL maintain access until the end of the billing period

### Requirement 5: Feature Access Control and Usage Tracking

**User Story:** As the system, I need to accurately track feature usage and enforce tier limitations, so that the subscription model functions correctly and users receive appropriate access to features.

#### Acceptance Criteria

1. WHEN a user attempts to access tier-restricted features THEN the system SHALL check current subscription status and enforce appropriate limitations
2. WHEN a free user uses limited features THEN the system SHALL track usage counts (manual interpretations, journal entries) and display remaining allowances
3. WHEN usage limits are approached THEN the system SHALL notify users of remaining capacity and upgrade options
4. WHEN subscription status changes THEN the system SHALL immediately update feature access without requiring user logout
5. WHEN the app starts THEN the system SHALL verify subscription status and sync with platform subscription services (App Store/Google Play)
6. WHEN network connectivity is limited THEN the system SHALL gracefully handle subscription verification with appropriate fallback behavior

### Requirement 6: Monetization Integration and User Experience

**User Story:** As a user, I want subscription prompts and advertisements to feel natural and non-disruptive to my spiritual practice, so that monetization enhances rather than detracts from the app's tranquil atmosphere.

#### Acceptance Criteria

1. WHEN displaying advertisements to free users THEN the system SHALL show only a single, contextually appropriate ad after completing readings
2. WHEN showing upgrade prompts THEN the system SHALL use gentle, benefit-focused messaging that aligns with the app's spiritual tone
3. WHEN a user explores premium features THEN the system SHALL provide preview experiences that demonstrate value without full access
4. WHEN presenting subscription options THEN the system SHALL clearly communicate the spiritual and practical benefits of each tier
5. WHEN handling subscription flows THEN the system SHALL integrate seamlessly with platform billing systems (App Store/Google Play)
6. WHEN users interact with monetization elements THEN the system SHALL maintain the app's calming visual design and user experience principles