import 'dart:convert';
import 'tarot_card.dart';

/// Represents a tarot card in a specific position within a reading
class CardPosition {
  final TarotCard card;
  final String positionName;
  final String positionMeaning;
  final String aiInterpretation;
  final int order; // Position order in the spread (0-based)

  const CardPosition({
    required this.card,
    required this.positionName,
    required this.positionMeaning,
    required this.aiInterpretation,
    required this.order,
  });

  /// Create a copy of this card position with some properties changed
  CardPosition copyWith({
    TarotCard? card,
    String? positionName,
    String? positionMeaning,
    String? aiInterpretation,
    int? order,
  }) {
    return CardPosition(
      card: card ?? this.card,
      positionName: positionName ?? this.positionName,
      positionMeaning: positionMeaning ?? this.positionMeaning,
      aiInterpretation: aiInterpretation ?? this.aiInterpretation,
      order: order ?? this.order,
    );
  }

  /// Get a combined interpretation including position context
  String get fullInterpretation {
    return '$positionMeaning\n\n${card.currentMeaning}\n\n$aiInterpretation';
  }

  /// Validate card position data
  bool get isValid {
    return card.isValid &&
        positionName.isNotEmpty &&
        positionMeaning.isNotEmpty &&
        order >= 0;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'card': card.toJson(),
      'positionName': positionName,
      'positionMeaning': positionMeaning,
      'aiInterpretation': aiInterpretation,
      'order': order,
    };
  }

  /// Create from JSON
  factory CardPosition.fromJson(Map<String, dynamic> json) {
    return CardPosition(
      card: TarotCard.fromJson(json['card'] as Map<String, dynamic>),
      positionName: json['positionName'] as String,
      positionMeaning: json['positionMeaning'] as String,
      aiInterpretation: json['aiInterpretation'] as String,
      order: json['order'] as int,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory CardPosition.fromJsonString(String jsonString) {
    return CardPosition.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardPosition &&
        other.card == card &&
        other.positionName == positionName &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(card, positionName, order);

  @override
  String toString() {
    return 'CardPosition(card: ${card.name}, position: $positionName, order: $order)';
  }
}
