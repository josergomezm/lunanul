import 'dart:convert';
import 'dart:ui';
import 'enums.dart';
import 'card_position.dart';
import '../utils/date_time_localizations.dart';

/// Represents a complete tarot reading with all its components
class Reading {
  final String id;
  final DateTime createdAt;
  final ReadingTopic topic;
  final SpreadType spreadType;
  final List<CardPosition> cards;
  final String? userReflection;
  final bool isSaved;
  final String? title; // Optional custom title for the reading
  final GuideType? selectedGuide; // Selected guide for this reading

  const Reading({
    required this.id,
    required this.createdAt,
    required this.topic,
    required this.spreadType,
    required this.cards,
    this.userReflection,
    this.isSaved = false,
    this.title,
    this.selectedGuide,
  });

  /// Create a copy of this reading with some properties changed
  Reading copyWith({
    String? id,
    DateTime? createdAt,
    ReadingTopic? topic,
    SpreadType? spreadType,
    List<CardPosition>? cards,
    String? userReflection,
    bool? isSaved,
    String? title,
    GuideType? selectedGuide,
  }) {
    return Reading(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      topic: topic ?? this.topic,
      spreadType: spreadType ?? this.spreadType,
      cards: cards ?? this.cards,
      userReflection: userReflection ?? this.userReflection,
      isSaved: isSaved ?? this.isSaved,
      title: title ?? this.title,
      selectedGuide: selectedGuide ?? this.selectedGuide,
    );
  }

  /// Get display title for the reading
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return '${topic.displayName} - ${spreadType.displayName}';
  }

  /// Get formatted date string (deprecated - use getFormattedDate with locale)
  @Deprecated('Use getFormattedDate(locale) instead for proper localization')
  String get formattedDate {
    return getFormattedDate(const Locale('en'));
  }

  /// Get localized formatted date string
  String getFormattedDate(Locale locale) {
    return DateTimeLocalizations.formatReadingDate(createdAt, locale);
  }

  /// Get a summary of the reading
  String get summary {
    if (cards.isEmpty) return 'No cards drawn';

    final cardNames = cards.map((cp) => cp.card.name).take(3).join(', ');
    final remaining = cards.length > 3 ? ' and ${cards.length - 3} more' : '';

    return '$cardNames$remaining';
  }

  /// Check if reading has user reflection
  bool get hasReflection =>
      userReflection != null && userReflection!.isNotEmpty;

  /// Get all unique cards in the reading (without duplicates)
  List<String> get uniqueCardIds {
    return cards.map((cp) => cp.card.id).toSet().toList();
  }

  /// Get cards by their position order
  List<CardPosition> get orderedCards {
    final sortedCards = List<CardPosition>.from(cards);
    sortedCards.sort((a, b) => a.order.compareTo(b.order));
    return sortedCards;
  }

  /// Check if this reading can be shared
  bool get canBeShared => isSaved && cards.isNotEmpty;

  /// Validate reading data
  bool get isValid {
    return id.isNotEmpty &&
        cards.isNotEmpty &&
        cards.length == spreadType.cardCount &&
        cards.every((cp) => cp.isValid);
  }

  /// Get reading statistics
  Map<String, dynamic> get statistics {
    final majorArcanaCount = cards.where((cp) => cp.card.isMajorArcana).length;
    final reversedCount = cards.where((cp) => cp.card.isReversed).length;
    final suits = cards.map((cp) => cp.card.suit).toSet();

    return {
      'totalCards': cards.length,
      'majorArcanaCount': majorArcanaCount,
      'minorArcanaCount': cards.length - majorArcanaCount,
      'reversedCount': reversedCount,
      'uprightCount': cards.length - reversedCount,
      'uniqueSuits': suits.length,
      'suits': suits.map((s) => s.name).toList(),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'topic': topic.name,
      'spreadType': spreadType.name,
      'cards': cards.map((cp) => cp.toJson()).toList(),
      'userReflection': userReflection,
      'isSaved': isSaved,
      'title': title,
      'selectedGuide': selectedGuide?.name,
    };
  }

  /// Create from JSON
  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      topic: ReadingTopic.fromString(json['topic'] as String),
      spreadType: SpreadType.fromString(json['spreadType'] as String),
      cards: (json['cards'] as List)
          .map(
            (cardJson) =>
                CardPosition.fromJson(cardJson as Map<String, dynamic>),
          )
          .toList(),
      userReflection: json['userReflection'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
      title: json['title'] as String?,
      selectedGuide: json['selectedGuide'] != null
          ? GuideType.fromString(json['selectedGuide'] as String)
          : null,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory Reading.fromJsonString(String jsonString) {
    return Reading.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reading(id: $id, topic: ${topic.name}, spread: ${spreadType.name}, cards: ${cards.length})';
  }
}
