# Implementation Plan

- [x] 1. Create core subscription models and enums





  - Create SubscriptionTier enum with seeker, mystic, and oracle values
  - Implement SubscriptionStatus model with tier, active status, expiration, and usage tracking
  - Create FeatureAccess model defining permissions for each tier
  - Add SubscriptionProduct model for platform subscription offerings
  - _Requirements: 1.1, 2.1, 3.1, 4.1_

- [x] 2. Implement subscription configuration and feature definitions





  - Create SubscriptionConfig class with static tier feature mappings
  - Define UsageLimits class with monthly limits and tier-specific restrictions
  - Implement SubscriptionError enum and SubscriptionException class for error handling
  - Add feature key constants for subscription gates
  - _Requirements: 1.2, 1.3, 1.6, 2.2, 3.2_
-

- [x] 3. Create usage tracking service and local storage




  - Implement UsageTrackingService interface with usage counting methods
  - Create concrete implementation using SharedPreferences for local storage
  - Add monthly usage reset functionality with date tracking
  - Implement usage increment and limit checking methods
  - _Requirements: 1.7, 1.8, 5.2, 5.3_
-

- [x] 4. Build feature gate service for access control




  - Create FeatureGateService interface with access control methods
  - Implement concrete service that checks subscription tier and usage limits
  - Add methods for validating reading spreads, guide access, and journal limits
  - Integrate with usage tracking for free tier enforcement
  - _Requirements: 1.2, 1.3, 1.4, 1.5, 2.2, 2.3, 3.2, 3.3_
-

- [x] 5. Create subscription service interface and mock implementation




  - Define SubscriptionService interface with platform integration methods
  - Create mock implementation for development and testing
  - Add subscription status retrieval and product listing methods
  - Implement subscription purchase and restoration mock flows
  - _Requirements: 4.2, 4.4, 4.5, 5.1_
-

- [x] 6. Implement subscription providers using Riverpod




  - Create SubscriptionNotifier extending StateNotifier for subscription status
  - Add FeatureGateProvider for accessing feature permissions
  - Implement UsageTrackingProvider for monitoring feature usage
  - Create derived providers for current tier and feature access
  - _Requirements: 4.1, 5.1, 5.4, 6.1_

- [x] 7. Build SubscriptionGate widget for feature protection





  - Create SubscriptionGate widget that wraps protected features
  - Add logic to check feature access and display upgrade prompts
  - Implement different gate behaviors for usage limits vs tier restrictions
  - Add smooth animations for gate state changes
  - _Requirements: 1.2, 1.3, 1.7, 2.2, 6.2_
-

- [x] 8. Create upgrade prompt and subscription management UI




  - Build UpgradePrompt widget with tier comparison and benefits
  - Create SubscriptionManagement screen for viewing and managing subscriptions
  - Add tier selection interface with pricing and feature highlights
  - Implement subscription status display with renewal dates and usage stats
  - _Requirements: 4.2, 4.3, 6.3, 6.4_

- [x] 9. Integrate subscription gates with reading features





  - Add SubscriptionGate to spread selection limiting free users to 1-3 card spreads
  - Integrate usage tracking for manual interpretations with monthly limits
  - Add upgrade prompts when users attempt to access premium spreads
  - Update reading flow to respect subscription tier limitations
  - _Requirements: 1.2, 1.6, 2.2, 5.2_

- [x] 10. Integrate subscription gates with guide system





  - Add SubscriptionGate to guide selection limiting free users to Healer and Mentor
  - Update guide selection UI to show locked guides with upgrade prompts
  - Modify guide provider to respect subscription tier access
  - Add preview functionality for locked guides
  - _Requirements: 1.4, 2.3, 6.2_

- [x] 11. Implement journal subscription limits and management





  - Add SubscriptionGate to journal saving with 3-entry limit for free users
  - Create journal management UI showing usage and upgrade options
  - Implement journal entry replacement flow when limit is reached
  - Add unlimited journal access for paid subscribers
  - _Requirements: 1.8, 1.9, 2.5, 5.2_
-

- [x] 12. Add advertisement integration for free tier




  - Create AdService interface for displaying non-intrusive ads
  - Implement mock ad service for development
  - Add ad display after readings for free users only
  - Ensure ads respect the app's tranquil design principles
  - _Requirements: 1.10, 2.1, 6.5_

- [x] 13. Create subscription onboarding and user education





  - Build subscription introduction flow for new users
  - Add feature discovery prompts that highlight premium benefits
  - Create subscription benefits explanation screens
  - Implement gentle upgrade suggestions throughout the app
  - _Requirements: 4.1, 4.4, 6.4_
- [x] 14. Implement subscription status synchronization

  - Add subscription status refresh functionality
  - Create periodic subscription verification
  - Implement graceful handling of expired subscriptions
  - Add subscription restoration for users switching devices
  - _Requirements: 4.5, 4.6, 5.1, 5.4_



- [x] 15. Add Oracle tier premium features foundation







  - Create AudioReadingService interface for AI-generated audio
  - Implement JournalPromptService for personalized reflection questions

  - Add CustomizationService for themes and card backs

  - Create EarlyAccessService for beta features

  - _Requirements: 3.1, 3.2, 3.6, 3.7_

- [x] 16. Integrate subscription system with existing user provider







  - Extend User model to include subscription information
  - Update UserProvider to load and manage subscription s
tatus
  - Add subscription-aware user preferences and settings
  - Ensure subscription data persists across app sessions
  - _Requirements: 4.1, 4.6, 5.4_

- [x] 17. Create subscription analytics and monitoring






  - Implement subscription event tracking for conv
ersions and usage
  - Add subscription status monitoring and error reporting
  - Create usage analytics for feature adoption by tier

  - Add subscription health checks and diagnostics
  - _Requirements: 5.5, 6.6_
-

- [x] 18. Add comprehensive error handling and recovery





  - Implement subscription error handling with user-friendly messages
  - Add retry mechanisms for failed subscription operations
  - Create fallback behavior for network connectivity issues
  - Implement graceful degradation when subscription verification fails
  - _Requirements: 4.6, 5.6, 6.5_

- [x] 19. Create subscription settings and management interface








  - Build subscription settings page within app settings
  - Add subscription status display with tier benefits
  - Implement subscription cancellation and modification flows
  - Create usage statistics display for current billing period
  - _Requirements: 4.5, 6.3, 6.4_



-

- [x] 20. Integrate and test complete subscription system





  - Wire all subscription components together in main app
  - Add subscription providers to ProviderScope configuration
  - Test subscription flows across all app features
  - Verify feature gating works correctly for all tiers
  - _Requirements: 4.1, 5.1, 5.4, 6.1_