import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
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
  final MessageType type;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.characterId,
    this.type = MessageType.text,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      characterId: json['characterId'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
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
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? characterId,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      characterId: characterId ?? this.characterId,
      type: type ?? this.type,
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
  
  @HiveField(4)
  error,
}

// Conversation model for grouping messages
@HiveType(typeId: 2)
class ConversationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final String characterId;

  @HiveField(5)
  final List<String> messageIds;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.characterId,
    required this.messageIds,
    this.metadata,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      characterId: json['characterId'] ?? '',
      messageIds: List<String>.from(json['messageIds'] ?? []),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'characterId': characterId,
      'messageIds': messageIds,
      'metadata': metadata,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? characterId,
    List<String>? messageIds,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      characterId: characterId ?? this.characterId,
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
