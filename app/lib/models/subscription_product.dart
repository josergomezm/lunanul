import 'enums.dart';

/// Represents a subscription product available for purchase on the platform
class SubscriptionProduct {
  const SubscriptionProduct({
    required this.id,
    required this.tier,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.period,
    this.originalPrice,
    this.discountPercentage,
    this.isPopular = false,
    this.features = const [],
    this.platformProductId,
  });

  /// Unique identifier for this product
  final String id;

  /// The subscription tier this product provides
  final SubscriptionTier tier;

  /// Display title for the product
  final String title;

  /// Detailed description of what's included
  final String description;

  /// Current price as a formatted string
  final String price;

  /// Currency code (e.g., 'USD', 'EUR')
  final String currency;

  /// Billing period (e.g., 'monthly', 'yearly')
  final String period;

  /// Original price if there's a discount
  final String? originalPrice;

  /// Discount percentage if applicable
  final int? discountPercentage;

  /// Whether this is marked as the popular/recommended option
  final bool isPopular;

  /// List of key features included in this product
  final List<String> features;

  /// Platform-specific product identifier (App Store/Google Play)
  final String? platformProductId;

  /// Check if this product has a discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Get the savings text if there's a discount
  String? get savingsText {
    if (!hasDiscount) return null;
    return 'Save $discountPercentage%';
  }

  /// Create a copy with updated values
  SubscriptionProduct copyWith({
    String? id,
    SubscriptionTier? tier,
    String? title,
    String? description,
    String? price,
    String? currency,
    String? period,
    String? originalPrice,
    int? discountPercentage,
    bool? isPopular,
    List<String>? features,
    String? platformProductId,
  }) {
    return SubscriptionProduct(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isPopular: isPopular ?? this.isPopular,
      features: features ?? this.features,
      platformProductId: platformProductId ?? this.platformProductId,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tier': tier.name,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'period': period,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'isPopular': isPopular,
      'features': features,
      'platformProductId': platformProductId,
    };
  }

  /// Create from JSON
  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) {
    return SubscriptionProduct(
      id: json['id'] as String,
      tier: SubscriptionTier.fromString(json['tier'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      currency: json['currency'] as String,
      period: json['period'] as String,
      originalPrice: json['originalPrice'] as String?,
      discountPercentage: json['discountPercentage'] as int?,
      isPopular: json['isPopular'] as bool? ?? false,
      features: List<String>.from(json['features'] as List? ?? []),
      platformProductId: json['platformProductId'] as String?,
    );
  }

  /// Create default Mystic monthly product
  factory SubscriptionProduct.mysticMonthly() {
    return const SubscriptionProduct(
      id: 'mystic_monthly',
      tier: SubscriptionTier.mystic,
      title: 'Mystic Monthly',
      description: 'Complete tarot experience without limits',
      price: '\$4.99',
      currency: 'USD',
      period: 'monthly',
      isPopular: true,
      features: [
        'Unlimited AI readings',
        'All tarot spreads',
        'All four guides',
        'Unlimited journal entries',
        'Ad-free experience',
        'Unlimited manual interpretations',
      ],
      platformProductId: 'com.lunanul.mystic.monthly',
    );
  }

  /// Create default Oracle monthly product
  factory SubscriptionProduct.oracleMonthly() {
    return const SubscriptionProduct(
      id: 'oracle_monthly',
      tier: SubscriptionTier.oracle,
      title: 'Oracle Monthly',
      description: 'Premium features and advanced capabilities',
      price: '\$9.99',
      currency: 'USD',
      period: 'monthly',
      features: [
        'Everything in Mystic',
        'AI-generated audio readings',
        'Personalized journal prompts',
        'Advanced tarot spreads',
        'Custom themes and card backs',
        'Early access to new features',
      ],
      platformProductId: 'com.lunanul.oracle.monthly',
    );
  }

  /// Create default Mystic yearly product with discount
  factory SubscriptionProduct.mysticYearly() {
    return const SubscriptionProduct(
      id: 'mystic_yearly',
      tier: SubscriptionTier.mystic,
      title: 'Mystic Yearly',
      description: 'Complete tarot experience - best value!',
      price: '\$49.99',
      currency: 'USD',
      period: 'yearly',
      originalPrice: '\$59.88',
      discountPercentage: 17,
      features: [
        'Unlimited AI readings',
        'All tarot spreads',
        'All four guides',
        'Unlimited journal entries',
        'Ad-free experience',
        'Unlimited manual interpretations',
        'Save 17% vs monthly',
      ],
      platformProductId: 'com.lunanul.mystic.yearly',
    );
  }

  /// Create default Oracle yearly product with discount
  factory SubscriptionProduct.oracleYearly() {
    return const SubscriptionProduct(
      id: 'oracle_yearly',
      tier: SubscriptionTier.oracle,
      title: 'Oracle Yearly',
      description: 'Premium experience - maximum value!',
      price: '\$99.99',
      currency: 'USD',
      period: 'yearly',
      originalPrice: '\$119.88',
      discountPercentage: 17,
      features: [
        'Everything in Mystic',
        'AI-generated audio readings',
        'Personalized journal prompts',
        'Advanced tarot spreads',
        'Custom themes and card backs',
        'Early access to new features',
        'Save 17% vs monthly',
      ],
      platformProductId: 'com.lunanul.oracle.yearly',
    );
  }

  /// Get all default subscription products
  static List<SubscriptionProduct> getDefaultProducts() {
    return [
      SubscriptionProduct.mysticMonthly(),
      SubscriptionProduct.mysticYearly(),
      SubscriptionProduct.oracleMonthly(),
      SubscriptionProduct.oracleYearly(),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionProduct &&
        other.id == id &&
        other.tier == tier &&
        other.price == price &&
        other.period == period;
  }

  @override
  int get hashCode {
    return Object.hash(id, tier, price, period);
  }

  @override
  String toString() {
    return 'SubscriptionProduct(id: $id, tier: $tier, price: $price/$period)';
  }
}
