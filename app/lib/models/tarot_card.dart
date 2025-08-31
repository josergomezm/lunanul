import 'dart:convert';
import 'dart:ui';
import 'enums.dart';

/// Represents a tarot card with all its properties and meanings
class TarotCard {
  final String id;
  final String name;
  final TarotSuit suit;
  final int? number; // null for court cards and some major arcana
  final String imageUrl;
  final List<String> keywords;
  final String uprightMeaning;
  final String reversedMeaning;
  final bool isReversed;

  // Localized content (optional, used when localization is available)
  final String? localizedName;
  final List<String>? localizedKeywords;
  final String? localizedUprightMeaning;
  final String? localizedReversedMeaning;

  const TarotCard({
    required this.id,
    required this.name,
    required this.suit,
    this.number,
    required this.imageUrl,
    required this.keywords,
    required this.uprightMeaning,
    required this.reversedMeaning,
    this.isReversed = false,
    this.localizedName,
    this.localizedKeywords,
    this.localizedUprightMeaning,
    this.localizedReversedMeaning,
  });

  /// Create a copy of this card with some properties changed
  TarotCard copyWith({
    String? id,
    String? name,
    TarotSuit? suit,
    int? number,
    String? imageUrl,
    List<String>? keywords,
    String? uprightMeaning,
    String? reversedMeaning,
    bool? isReversed,
    String? localizedName,
    List<String>? localizedKeywords,
    String? localizedUprightMeaning,
    String? localizedReversedMeaning,
  }) {
    return TarotCard(
      id: id ?? this.id,
      name: name ?? this.name,
      suit: suit ?? this.suit,
      number: number ?? this.number,
      imageUrl: imageUrl ?? this.imageUrl,
      keywords: keywords ?? this.keywords,
      uprightMeaning: uprightMeaning ?? this.uprightMeaning,
      reversedMeaning: reversedMeaning ?? this.reversedMeaning,
      isReversed: isReversed ?? this.isReversed,
      localizedName: localizedName ?? this.localizedName,
      localizedKeywords: localizedKeywords ?? this.localizedKeywords,
      localizedUprightMeaning:
          localizedUprightMeaning ?? this.localizedUprightMeaning,
      localizedReversedMeaning:
          localizedReversedMeaning ?? this.localizedReversedMeaning,
    );
  }

  /// Get the current meaning based on card orientation (localized if available)
  String get currentMeaning {
    if (isReversed) {
      return localizedReversedMeaning ?? reversedMeaning;
    } else {
      return localizedUprightMeaning ?? uprightMeaning;
    }
  }

  /// Get the display name with orientation indicator (localized if available)
  String get displayName {
    final cardName = localizedName ?? name;
    return isReversed ? '$cardName (Reversed)' : cardName;
  }

  /// Get the localized display name with orientation indicator for a specific locale
  String getLocalizedDisplayName(Locale locale, {String? reversedSuffix}) {
    final cardName = localizedName ?? name;
    if (isReversed) {
      final suffix =
          reversedSuffix ??
          (locale.languageCode == 'es' ? ' (Invertida)' : ' (Reversed)');
      return '$cardName$suffix';
    }
    return cardName;
  }

  /// Get the effective name (localized if available, otherwise fallback to original)
  String get effectiveName => localizedName ?? name;

  /// Get the effective keywords (localized if available, otherwise fallback to original)
  List<String> get effectiveKeywords => localizedKeywords ?? keywords;

  /// Get the effective upright meaning (localized if available, otherwise fallback to original)
  String get effectiveUprightMeaning =>
      localizedUprightMeaning ?? uprightMeaning;

  /// Get the effective reversed meaning (localized if available, otherwise fallback to original)
  String get effectiveReversedMeaning =>
      localizedReversedMeaning ?? reversedMeaning;

  /// Create a localized version of this card
  TarotCard withLocalization({
    String? localizedName,
    List<String>? localizedKeywords,
    String? localizedUprightMeaning,
    String? localizedReversedMeaning,
  }) {
    return copyWith(
      localizedName: localizedName,
      localizedKeywords: localizedKeywords,
      localizedUprightMeaning: localizedUprightMeaning,
      localizedReversedMeaning: localizedReversedMeaning,
    );
  }

  /// Check if this card has localized content
  bool get hasLocalization {
    return localizedName != null ||
        localizedKeywords != null ||
        localizedUprightMeaning != null ||
        localizedReversedMeaning != null;
  }

  /// Check if this is a Major Arcana card
  bool get isMajorArcana => suit == TarotSuit.majorArcana;

  /// Check if this is a court card (no number)
  bool get isCourtCard => number == null && !isMajorArcana;

  /// Validate card data
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        imageUrl.isNotEmpty &&
        uprightMeaning.isNotEmpty &&
        reversedMeaning.isNotEmpty &&
        keywords.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'suit': suit.name,
      'number': number,
      'imageUrl': imageUrl,
      'keywords': keywords,
      'uprightMeaning': uprightMeaning,
      'reversedMeaning': reversedMeaning,
      'isReversed': isReversed,
      'localizedName': localizedName,
      'localizedKeywords': localizedKeywords,
      'localizedUprightMeaning': localizedUprightMeaning,
      'localizedReversedMeaning': localizedReversedMeaning,
    };
  }

  /// Create from JSON
  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      id: json['id'] as String,
      name: json['name'] as String,
      suit: TarotSuit.fromString(json['suit'] as String),
      number: json['number'] as int?,
      imageUrl: json['imageUrl'] as String,
      keywords: List<String>.from(json['keywords'] as List),
      uprightMeaning: json['uprightMeaning'] as String,
      reversedMeaning: json['reversedMeaning'] as String,
      isReversed: json['isReversed'] as bool? ?? false,
      localizedName: json['localizedName'] as String?,
      localizedKeywords: json['localizedKeywords'] != null
          ? List<String>.from(json['localizedKeywords'] as List)
          : null,
      localizedUprightMeaning: json['localizedUprightMeaning'] as String?,
      localizedReversedMeaning: json['localizedReversedMeaning'] as String?,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory TarotCard.fromJsonString(String jsonString) {
    return TarotCard.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TarotCard &&
        other.id == id &&
        other.isReversed == isReversed;
  }

  @override
  int get hashCode => Object.hash(id, isReversed);

  @override
  String toString() {
    return 'TarotCard(id: $id, name: $name, suit: ${suit.name}, isReversed: $isReversed)';
  }
}
