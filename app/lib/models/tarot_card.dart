import 'dart:convert';
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
    );
  }

  /// Get the current meaning based on card orientation
  String get currentMeaning => isReversed ? reversedMeaning : uprightMeaning;

  /// Get the display name with orientation indicator
  String get displayName => isReversed ? '$name (Reversed)' : name;

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
