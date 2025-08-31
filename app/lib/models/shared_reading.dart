import 'dart:convert';
import 'dart:ui';
import 'reading.dart';
import '../utils/date_time_localizations.dart';

/// Represents a reading shared between friends
class SharedReading {
  final String id;
  final String readingId;
  final String sharedByUserId;
  final String sharedWithUserId;
  final DateTime sharedAt;
  final Reading reading;
  final List<ChatMessage> messages;

  const SharedReading({
    required this.id,
    required this.readingId,
    required this.sharedByUserId,
    required this.sharedWithUserId,
    required this.sharedAt,
    required this.reading,
    this.messages = const [],
  });

  /// Create a copy of this shared reading with some properties changed
  SharedReading copyWith({
    String? id,
    String? readingId,
    String? sharedByUserId,
    String? sharedWithUserId,
    DateTime? sharedAt,
    Reading? reading,
    List<ChatMessage>? messages,
  }) {
    return SharedReading(
      id: id ?? this.id,
      readingId: readingId ?? this.readingId,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      sharedWithUserId: sharedWithUserId ?? this.sharedWithUserId,
      sharedAt: sharedAt ?? this.sharedAt,
      reading: reading ?? this.reading,
      messages: messages ?? this.messages,
    );
  }

  /// Add a new message to the conversation
  SharedReading addMessage(ChatMessage message) {
    final newMessages = List<ChatMessage>.from(messages);
    newMessages.add(message);
    newMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return copyWith(messages: newMessages);
  }

  /// Get the latest message
  ChatMessage? get latestMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Check if there are unread messages for a specific user
  bool hasUnreadMessagesFor(String userId) {
    return messages.any(
      (msg) => msg.senderUserId != userId && !msg.isReadBy(userId),
    );
  }

  /// Get unread message count for a specific user
  int getUnreadCountFor(String userId) {
    return messages
        .where((msg) => msg.senderUserId != userId && !msg.isReadBy(userId))
        .length;
  }

  /// Get formatted share date (deprecated - use getFormattedShareDate with locale)
  @Deprecated(
    'Use getFormattedShareDate(locale) instead for proper localization',
  )
  String get formattedShareDate {
    return getFormattedShareDate(const Locale('en'));
  }

  /// Get localized formatted share date
  String getFormattedShareDate(Locale locale) {
    return DateTimeLocalizations.formatReadingDate(sharedAt, locale);
  }

  /// Validate shared reading data
  bool get isValid {
    return id.isNotEmpty &&
        readingId.isNotEmpty &&
        sharedByUserId.isNotEmpty &&
        sharedWithUserId.isNotEmpty &&
        sharedByUserId != sharedWithUserId &&
        reading.isValid;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'readingId': readingId,
      'sharedByUserId': sharedByUserId,
      'sharedWithUserId': sharedWithUserId,
      'sharedAt': sharedAt.toIso8601String(),
      'reading': reading.toJson(),
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory SharedReading.fromJson(Map<String, dynamic> json) {
    return SharedReading(
      id: json['id'] as String,
      readingId: json['readingId'] as String,
      sharedByUserId: json['sharedByUserId'] as String,
      sharedWithUserId: json['sharedWithUserId'] as String,
      sharedAt: DateTime.parse(json['sharedAt'] as String),
      reading: Reading.fromJson(json['reading'] as Map<String, dynamic>),
      messages: (json['messages'] as List? ?? [])
          .map(
            (msgJson) => ChatMessage.fromJson(msgJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory SharedReading.fromJsonString(String jsonString) {
    return SharedReading.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SharedReading(id: $id, reading: ${reading.displayTitle}, messages: ${messages.length})';
  }
}

/// Represents a chat message in a shared reading conversation
class ChatMessage {
  final String id;
  final String senderUserId;
  final String message;
  final DateTime sentAt;
  final List<String> readByUserIds;

  const ChatMessage({
    required this.id,
    required this.senderUserId,
    required this.message,
    required this.sentAt,
    this.readByUserIds = const [],
  });

  /// Create a copy of this message with some properties changed
  ChatMessage copyWith({
    String? id,
    String? senderUserId,
    String? message,
    DateTime? sentAt,
    List<String>? readByUserIds,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderUserId: senderUserId ?? this.senderUserId,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      readByUserIds: readByUserIds ?? this.readByUserIds,
    );
  }

  /// Mark message as read by a user
  ChatMessage markAsReadBy(String userId) {
    if (readByUserIds.contains(userId)) return this;

    final newReadByUserIds = List<String>.from(readByUserIds);
    newReadByUserIds.add(userId);
    return copyWith(readByUserIds: newReadByUserIds);
  }

  /// Check if message is read by a specific user
  bool isReadBy(String userId) {
    return readByUserIds.contains(userId);
  }

  /// Get formatted time string (deprecated - use getFormattedTime with locale)
  @Deprecated('Use getFormattedTime(locale) instead for proper localization')
  String get formattedTime {
    return getFormattedTime(const Locale('en'));
  }

  /// Get localized formatted time string
  String getFormattedTime(Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inMinutes < 1) {
      return locale.languageCode == 'es' ? 'Ahora mismo' : 'Just now';
    } else if (difference.inHours < 1) {
      if (locale.languageCode == 'es') {
        return 'hace ${difference.inMinutes}m';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } else if (difference.inDays < 1) {
      if (locale.languageCode == 'es') {
        return 'hace ${difference.inHours}h';
      } else {
        return '${difference.inHours}h ago';
      }
    } else {
      return DateTimeLocalizations.getShortDateFormatter(locale).format(sentAt);
    }
  }

  /// Validate message data
  bool get isValid {
    return id.isNotEmpty &&
        senderUserId.isNotEmpty &&
        message.trim().isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUserId': senderUserId,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'readByUserIds': readByUserIds,
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderUserId: json['senderUserId'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readByUserIds: List<String>.from(json['readByUserIds'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $senderUserId, message: ${message.substring(0, message.length.clamp(0, 50))}...)';
  }
}
