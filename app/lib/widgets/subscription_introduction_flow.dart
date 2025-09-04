import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/onboarding_state.dart';
import '../providers/subscription_onboarding_provider.dart';

/// Widget that displays the subscription introduction flow for new users
class SubscriptionIntroductionFlow extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const SubscriptionIntroductionFlow({super.key, this.onComplete, this.onSkip});

  @override
  ConsumerState<SubscriptionIntroductionFlow> createState() =>
      _SubscriptionIntroductionFlowState();
}

class _SubscriptionIntroductionFlowState
    extends ConsumerState<SubscriptionIntroductionFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      title: 'Welcome to Your Spiritual Journey',
      subtitle: 'Discover the power of personalized tarot guidance',
      description:
          'Lunanul offers three paths to deepen your spiritual practice, each designed to meet you where you are in your journey.',
      icon: Icons.auto_awesome,
      gradient: [Colors.purple.shade300, Colors.blue.shade300],
    ),
    IntroPage(
      title: 'Seeker - Your Free Foundation',
      subtitle: 'Essential daily spiritual tools',
      description:
          'Start with daily card readings, basic spreads, and access to two wise guides. Perfect for building your spiritual habits.',
      icon: Icons.explore,
      gradient: [Colors.green.shade300, Colors.teal.shade300],
      tier: SubscriptionTier.seeker,
    ),
    IntroPage(
      title: 'Mystic - Complete Experience',
      subtitle: 'Unlimited spiritual guidance',
      description:
          'Unlock all spreads, guides, and unlimited readings. Remove ads and access detailed insights about your spiritual journey.',
      icon: Icons.auto_awesome,
      gradient: [Colors.indigo.shade300, Colors.purple.shade300],
      tier: SubscriptionTier.mystic,
    ),
    IntroPage(
      title: 'Oracle - Premium Wisdom',
      subtitle: 'Advanced features for deep seekers',
      description:
          'Experience AI-generated audio readings, personalized journal prompts, and early access to new spiritual tools.',
      icon: Icons.diamond,
      gradient: [Colors.amber.shade300, Colors.orange.shade300],
      tier: SubscriptionTier.oracle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPage(context, _pages[index]),
                    );
                  },
                ),
              ),
              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lunanul',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (widget.onSkip != null)
            TextButton(
              onPressed: _handleSkip,
              child: Text(
                'Skip',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, IntroPage page) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(page.icon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (page.tier != null) ...[
            const SizedBox(height: 32),
            _buildTierHighlights(context, page.tier!),
          ],
        ],
      ),
    );
  }

  Widget _buildTierHighlights(BuildContext context, SubscriptionTier tier) {
    final theme = Theme.of(context);
    final highlights = _getTierHighlights(tier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: highlights
            .map(
              (highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(highlight, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLastPage ? _handleComplete : _nextPage,
                  child: Text(isLastPage ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleComplete() async {
    // Mark subscription introduction as seen
    await ref
        .read(onboardingStateProvider.notifier)
        .completeStep(OnboardingStep.subscriptionIntroduction);

    await ref
        .read(onboardingStateProvider.notifier)
        .markSubscriptionIntroSeen();

    widget.onComplete?.call();
  }

  void _handleSkip() async {
    // Still mark as seen even if skipped
    await ref
        .read(onboardingStateProvider.notifier)
        .markSubscriptionIntroSeen();

    widget.onSkip?.call();
  }

  List<String> _getTierHighlights(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return [
          'Daily card readings',
          'Basic spreads (1-3 cards)',
          'Two spiritual guides',
          '5 interpretations per month',
          '3 readings per month',
        ];
      case SubscriptionTier.mystic:
        return [
          'Unlimited AI readings',
          'All tarot spreads',
          'All four guides',
          'Unlimited interpretations',
          'Ad-free experience',
        ];
      case SubscriptionTier.oracle:
        return [
          'Everything in Mystic',
          'AI-generated audio',
          'Personalized prompts',
          'Advanced spreads',
          'Custom themes',
        ];
    }
  }
}

/// Data class for introduction pages
class IntroPage {
  const IntroPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    this.tier,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final SubscriptionTier? tier;
}
