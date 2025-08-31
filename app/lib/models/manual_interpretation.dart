import 'enums.dart';
import 'tarot_card.dart';

/// Represents a manual interpretation session where user selects their own cards
class ManualInterpretation {
  final String id;
  final DateTime createdAt;
  final ReadingTopic topic;
  final List<ManualCardPosition> selectedCards;
  final String? userNotes;
  final bool isSaved;

  const ManualInterpretation({
    required this.id,
    required this.createdAt,
    required this.topic,
    required this.selectedCards,
    this.userNotes,
    this.isSaved = false,
  });

  /// Create a copy with some properties changed
  ManualInterpretation copyWith({
    String? id,
    DateTime? createdAt,
    ReadingTopic? topic,
    List<ManualCardPosition>? selectedCards,
    String? userNotes,
    bool? isSaved,
  }) {
    return ManualInterpretation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      topic: topic ?? this.topic,
      selectedCards: selectedCards ?? this.selectedCards,
      userNotes: userNotes ?? this.userNotes,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  /// Get display title for the interpretation
  String get displayTitle => '${topic.displayName} Manual Reading';

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get summary of selected cards
  String get summary {
    if (selectedCards.isEmpty) return 'No cards selected';

    final cardNames = selectedCards
        .map((cp) => cp.card.name)
        .take(3)
        .join(', ');
    final remaining = selectedCards.length > 3
        ? ' and ${selectedCards.length - 3} more'
        : '';

    return '$cardNames$remaining';
  }

  /// Check if interpretation has user notes
  bool get hasNotes => userNotes != null && userNotes!.isNotEmpty;

  /// Check if interpretation is complete (has cards and interpretations)
  bool get isComplete =>
      selectedCards.isNotEmpty &&
      selectedCards.every((cp) => cp.interpretation.isNotEmpty);

  /// Get all unique cards in the interpretation
  List<String> get uniqueCardIds {
    return selectedCards.map((cp) => cp.card.id).toSet().toList();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'topic': topic.name,
      'selectedCards': selectedCards.map((cp) => cp.toJson()).toList(),
      'userNotes': userNotes,
      'isSaved': isSaved,
    };
  }

  /// Create from JSON
  factory ManualInterpretation.fromJson(Map<String, dynamic> json) {
    return ManualInterpretation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      topic: ReadingTopic.fromString(json['topic'] as String),
      selectedCards: (json['selectedCards'] as List)
          .map(
            (cardJson) =>
                ManualCardPosition.fromJson(cardJson as Map<String, dynamic>),
          )
          .toList(),
      userNotes: json['userNotes'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManualInterpretation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Represents a card position in a manual interpretation
class ManualCardPosition {
  final TarotCard card;
  final String positionName;
  final String interpretation;
  final int order;

  const ManualCardPosition({
    required this.card,
    required this.positionName,
    required this.interpretation,
    required this.order,
  });

  /// Create a copy with some properties changed
  ManualCardPosition copyWith({
    TarotCard? card,
    String? positionName,
    String? interpretation,
    int? order,
  }) {
    return ManualCardPosition(
      card: card ?? this.card,
      positionName: positionName ?? this.positionName,
      interpretation: interpretation ?? this.interpretation,
      order: order ?? this.order,
    );
  }

  /// Check if this position is valid
  bool get isValid {
    return positionName.isNotEmpty && interpretation.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'card': card.toJson(),
      'positionName': positionName,
      'interpretation': interpretation,
      'order': order,
    };
  }

  /// Create from JSON
  factory ManualCardPosition.fromJson(Map<String, dynamic> json) {
    return ManualCardPosition(
      card: TarotCard.fromJson(json['card'] as Map<String, dynamic>),
      positionName: json['positionName'] as String,
      interpretation: json['interpretation'] as String,
      order: json['order'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManualCardPosition &&
        other.card == card &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(card, order);
}
