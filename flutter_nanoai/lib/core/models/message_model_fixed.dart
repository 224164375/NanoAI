import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class MessageModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isUser;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? characterId;

  @HiveField(5)
  final MessageType messageType;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  const MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.characterId,
    this.messageType = MessageType.text,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      characterId: json['characterId'] as String?,
      messageType: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'characterId': characterId,
      'type': messageType.toString().split('.').last,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? characterId,
    MessageType? messageType,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      characterId: characterId ?? this.characterId,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
  }
}

@HiveType(typeId: 1)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  voice,
  @HiveField(2)
  image,
  @HiveField(3)
  system,
}

@HiveType(typeId: 2)
class ConversationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String characterId;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final List<String> messageIds;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  const ConversationModel({
    required this.id,
    required this.title,
    required this.characterId,
    required this.createdAt,
    required this.updatedAt,
    required this.messageIds,
    this.metadata,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      characterId: json['characterId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messageIds: List<String>.from(json['messageIds'] as List),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'characterId': characterId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageIds': messageIds,
      'metadata': metadata,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? title,
    String? characterId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? messageIds,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      characterId: characterId ?? this.characterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageIds: messageIds ?? this.messageIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversationModel(id: $id, title: $title, characterId: $characterId)';
  }
}
