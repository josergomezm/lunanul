import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';

/// Page that explains subscription benefits in detail
class SubscriptionBenefitsPage extends ConsumerStatefulWidget {
  final SubscriptionTier? highlightedTier;
  final String? fromContext;

  const SubscriptionBenefitsPage({
    super.key,
    this.highlightedTier,
    this.fromContext,
  });

  @override
  ConsumerState<SubscriptionBenefitsPage> createState() =>
      _SubscriptionBenefitsPageState();
}

class _SubscriptionBenefitsPageState
    extends ConsumerState<SubscriptionBenefitsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    // Navigate to highlighted tier if specified
    if (widget.highlightedTier != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = widget.highlightedTier!.index;
        _tabController.animateTo(index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Benefits'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          tabs: const [
            Tab(text: 'Seeker', icon: Icon(Icons.explore)),
            Tab(text: 'Mystic', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Oracle', icon: Icon(Icons.diamond)),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.fromContext != null) _buildContextBanner(context),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              children: [
                _buildTierBenefitsPage(context, SubscriptionTier.seeker),
                _buildTierBenefitsPage(context, SubscriptionTier.mystic),
                _buildTierBenefitsPage(context, SubscriptionTier.oracle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getContextMessage(widget.fromContext!),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBenefitsPage(BuildContext context, SubscriptionTier tier) {
    final tierInfo = _getTierInfo(tier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTierHeader(context, tierInfo),
          const SizedBox(height: 24),
          _buildFeaturesList(context, tierInfo),
          const SizedBox(height: 24),
          if (tier != SubscriptionTier.seeker) ...[
            _buildComparisonSection(context, tier),
            const SizedBox(height: 24),
          ],
          _buildUseCases(context, tierInfo),
          const SizedBox(height: 24),
          if (tier != SubscriptionTier.seeker)
            _buildUpgradeSection(context, tier),
        ],
      ),
    );
  }

  Widget _buildTierHeader(BuildContext context, _TierInfo tierInfo) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tierInfo.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tierInfo.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tierInfo.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tierInfo.price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tierInfo.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context, _TierInfo tierInfo) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Included',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...tierInfo.features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (feature.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          feature.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSection(BuildContext context, SubscriptionTier tier) {
    final theme = Theme.of(context);
    final previousTier = SubscriptionTier.values[tier.index - 1];
    final previousTierInfo = _getTierInfo(previousTier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade from ${previousTierInfo.name}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Additional benefits you\'ll unlock:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ..._getUpgradeFeatures(tier).map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCases(BuildContext context, _TierInfo tierInfo) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perfect For',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...tierInfo.useCases.map(
          (useCase) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(useCase.icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        useCase.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        useCase.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeSection(BuildContext context, SubscriptionTier tier) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Upgrade?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your enhanced spiritual journey today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToSubscription(context, tier),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text('Upgrade to ${_getTierName(tier)}'),
          ),
        ],
      ),
    );
  }

  void _navigateToSubscription(BuildContext context, SubscriptionTier tier) {
    Navigator.of(context).pushNamed('/subscription-management');
  }

  String _getContextMessage(String context) {
    switch (context) {
      case 'manual_interpretations':
        return 'You\'re approaching your monthly interpretation limit';
      case 'journal_storage':
        return 'Your journal is getting full';
      case 'advanced_spreads':
        return 'Unlock more detailed tarot spreads';
      case 'all_guides':
        return 'Meet all four spiritual guides';
      default:
        return 'Discover what each subscription tier offers';
    }
  }

  String _getTierName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return 'Seeker';
      case SubscriptionTier.mystic:
        return 'Mystic';
      case SubscriptionTier.oracle:
        return 'Oracle';
    }
  }

  List<String> _getUpgradeFeatures(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.mystic:
        return [
          'Unlimited AI readings and interpretations',
          'Access to all tarot spreads',
          'All four spiritual guides',
          'Unlimited journal storage',
          'Ad-free experience',
        ];
      case SubscriptionTier.oracle:
        return [
          'AI-generated audio readings',
          'Personalized journal prompts',
          'Advanced specialized spreads',
          'Custom themes and card backs',
          'Early access to new features',
        ];
      case SubscriptionTier.seeker:
        return [];
    }
  }

  _TierInfo _getTierInfo(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return _TierInfo(
          name: 'Seeker',
          price: 'Free Forever',
          description:
              'Perfect for exploring tarot and building daily spiritual habits',
          icon: Icons.explore,
          gradientColors: [Colors.green.shade400, Colors.teal.shade400],
          features: [
            _Feature(
              'Daily card readings',
              'Get guidance every day with Card of the Day',
            ),
            _Feature(
              'Basic spreads',
              '1-card and 3-card spreads for quick insights',
            ),
            _Feature(
              'Two spiritual guides',
              'Connect with The Healer and The Mentor',
            ),
            _Feature(
              '5 interpretations per month',
              'Manual card lookups for deeper understanding',
            ),
            _Feature('3 journal entries', 'Save your most meaningful readings'),
          ],
          useCases: [
            _UseCase(
              Icons.wb_sunny,
              'Daily Spiritual Practice',
              'Building consistent tarot habits and morning guidance',
            ),
            _UseCase(
              Icons.school,
              'Learning Tarot',
              'New to tarot and want to explore without commitment',
            ),
            _UseCase(
              Icons.explore,
              'Casual Seekers',
              'Occasional readings for life\'s simple questions',
            ),
          ],
        );
      case SubscriptionTier.mystic:
        return _TierInfo(
          name: 'Mystic',
          price: '\$4.99/month',
          description:
              'Complete tarot experience with unlimited access to all core features',
          icon: Icons.auto_awesome,
          gradientColors: [Colors.indigo.shade400, Colors.purple.shade400],
          features: [
            _Feature('Everything in Seeker', null),
            _Feature(
              'Unlimited AI readings',
              'No limits on readings or interpretations',
            ),
            _Feature(
              'All tarot spreads',
              'Celtic Cross, Relationship, Career, and more',
            ),
            _Feature('All four guides', 'Access to The Sage and The Visionary'),
            _Feature(
              'Unlimited journal storage',
              'Save and track all your readings',
            ),
            _Feature('Ad-free experience', 'Uninterrupted spiritual practice'),
            _Feature(
              'Reading statistics',
              'Insights into your spiritual journey',
            ),
          ],
          useCases: [
            _UseCase(
              Icons.trending_up,
              'Serious Practitioners',
              'Regular tarot users who want unlimited access',
            ),
            _UseCase(
              Icons.psychology,
              'Deep Self-Reflection',
              'Using tarot for personal growth and insight',
            ),
            _UseCase(
              Icons.group,
              'Guidance Seekers',
              'Want access to all guides for varied perspectives',
            ),
          ],
        );
      case SubscriptionTier.oracle:
        return _TierInfo(
          name: 'Oracle',
          price: '\$9.99/month',
          description:
              'Premium experience with advanced features and personalization',
          icon: Icons.diamond,
          gradientColors: [Colors.amber.shade400, Colors.orange.shade400],
          features: [
            _Feature('Everything in Mystic', null),
            _Feature(
              'AI-generated audio readings',
              'Hear your readings in your guide\'s voice',
            ),
            _Feature(
              'Personalized journal prompts',
              'Tailored reflection questions for each reading',
            ),
            _Feature(
              'Advanced spreads',
              'Specialized spreads for complex situations',
            ),
            _Feature('Custom themes', 'Personalize your app\'s appearance'),
            _Feature('Custom card backs', 'Choose from multiple card designs'),
            _Feature('Early access', 'Be first to try new features and guides'),
            _Feature(
              'Priority support',
              'Faster response to questions and issues',
            ),
          ],
          useCases: [
            _UseCase(
              Icons.star,
              'Tarot Enthusiasts',
              'Advanced users who want the ultimate experience',
            ),
            _UseCase(
              Icons.headphones,
              'Audio Learners',
              'Prefer listening to readings and interpretations',
            ),
            _UseCase(
              Icons.palette,
              'Personalization Lovers',
              'Want to customize their spiritual practice space',
            ),
          ],
        );
    }
  }
}

class _TierInfo {
  final String name;
  final String price;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<_Feature> features;
  final List<_UseCase> useCases;

  _TierInfo({
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.features,
    required this.useCases,
  });
}

class _Feature {
  final String title;
  final String? description;

  _Feature(this.title, this.description);
}

class _UseCase {
  final IconData icon;
  final String title;
  final String description;

  _UseCase(this.icon, this.title, this.description);
}
