# Requirements Document

## Introduction

Lunanul is a Flutter mobile application that provides a gentle, personalized tarot reading experience focused on self-reflection and meaningful connections. The app serves as both an AI-powered reading companion and a manual interpretation tool for physical tarot decks, with features for journaling, card learning, and private sharing with trusted friends. The design emphasizes minimalism, tranquility, and personal growth.

## Requirements

### Requirement 1: Home Page Experience

**User Story:** As a user, I want a welcoming home page that feels like a personal sanctuary, so that I can start each session with a sense of calm and intention.

#### Acceptance Criteria

1. WHEN the user opens the app THEN the system SHALL display a personalized greeting that changes based on time of day
2. WHEN the user views the home page THEN the system SHALL present a single "Card of the Day" facedown as the main feature
3. WHEN the user taps the Card of the Day THEN the system SHALL reveal the card with an insightful message or affirmation
4. WHEN the user has previous readings THEN the system SHALL display the last 2-3 saved readings in a scrollable section
5. WHEN the user views the home page THEN the system SHALL show an optional journal prompt for daily introspection
6. WHEN the user is on any page THEN the system SHALL provide a minimalist bottom navigation bar with clean icons

### Requirement 2: AI-Powered Readings

**User Story:** As a user, I want the app to guide me through complete tarot readings, so that I can receive quick, intuitive insights on topics that matter to me.

#### Acceptance Criteria

1. WHEN the user accesses readings THEN the system SHALL present four topic categories: Self, Love, Work, and Social
2. WHEN the user selects a topic THEN the system SHALL display relevant spread options for that category
3. WHEN the user selects a spread THEN the system SHALL animate cards being shuffled and dealt
4. WHEN cards are dealt THEN the system SHALL prompt the user to tap to reveal their cards
5. WHEN the user taps a revealed card THEN the system SHALL display the card name, meaning summary, and AI-generated interpretation
6. WHEN a reading is complete THEN the system SHALL provide options to save to journal and add personal reflections
7. WHEN the user saves a reading THEN the system SHALL store the complete reading with cards, topic, date, and interpretations

### Requirement 3: Manual Interpretation Tool

**User Story:** As a user with a physical tarot deck, I want to input my own card draws and receive contextual interpretations, so that I can enhance my personal readings with AI insights.

#### Acceptance Criteria

1. WHEN the user accesses interpretations THEN the system SHALL present the same four topic categories as readings
2. WHEN the user selects a topic THEN the system SHALL provide an interface to manually select drawn cards
3. WHEN selecting cards THEN the system SHALL display a searchable grid of all 78 tarot cards
4. WHEN the user selects cards THEN the system SHALL allow assignment of position meanings for each card
5. WHEN cards are assigned THEN the system SHALL display them in the specified order
6. WHEN the user taps a card THEN the system SHALL provide detailed meaning enhanced by topic context and position
7. WHEN interpretations are complete THEN the system SHALL highlight potential connections between selected cards
8. WHEN the user completes a manual reading THEN the system SHALL provide save and journal options

### Requirement 4: Personal Journal and Learning

**User Story:** As a user, I want a private space to track my readings and learn about tarot cards, so that I can reflect on my journey and deepen my understanding.

#### Acceptance Criteria

1. WHEN the user accesses the Yourself section THEN the system SHALL display a chronological journal of all saved readings
2. WHEN viewing journal entries THEN the system SHALL clearly label each entry with date and topic
3. WHEN the user taps a journal entry THEN the system SHALL display the full reading and saved notes
4. WHEN the user accesses the card encyclopedia THEN the system SHALL provide a searchable library of all 78 tarot cards
5. WHEN browsing the encyclopedia THEN the system SHALL allow users to learn card meanings outside of readings
6. IF reading statistics are enabled THEN the system SHALL show recurring cards and themes over time

### Requirement 5: Private Friend Connections

**User Story:** As a user, I want to be able to share meaningful readings with trusted friends.

#### Acceptance Criteria

1. WHEN the user accesses Friends THEN the system SHALL display a simple list of connected friends
2. WHEN adding friends THEN the system SHALL require private invitation links or codes to prevent unwanted requests
3. WHEN the user has a saved reading THEN the system SHALL provide a "Share with a Friend" option
4. WHEN sharing a reading THEN the system SHALL send the reading to the selected friend within the app

### Requirement 6: Visual Design and User Experience

**User Story:** As a user, I want a beautiful, calming interface that supports my spiritual practice, so that the app enhances rather than distracts from my reflection time.

#### Acceptance Criteria

1. WHEN using any feature THEN the system SHALL maintain a minimalist, tranquil design aesthetic
2. WHEN cards are displayed THEN the system SHALL render them beautifully with smooth animations
3. WHEN navigating THEN the system SHALL provide intuitive, clean interface elements
4. WHEN performing actions THEN the system SHALL use calming animations and transitions
5. WHEN viewing content THEN the system SHALL ensure readability and visual hierarchy support focus and reflection