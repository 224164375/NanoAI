import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/character_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  static DatabaseService get instance => _instance;
  
  late Box<MessageModel> _messagesBox;
  late Box<ConversationModel> _conversationsBox;
  late Box<Map> _settingsBox;
  
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();
  
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MessageModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(MessageTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ConversationModelAdapter());
      }
      
      // Open boxes
      _messagesBox = await Hive.openBox<MessageModel>('messages');
      _conversationsBox = await Hive.openBox<ConversationModel>('conversations');
      _settingsBox = await Hive.openBox<Map>('settings');
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }
  
  // Message operations
  Future<String> saveMessage(MessageModel message) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      await _messagesBox.put(message.id, message);
      return message.id;
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }
  
  Future<MessageModel?> getMessage(String id) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      return _messagesBox.get(id);
    } catch (e) {
      throw Exception('Failed to get message: $e');
    }
  }
  
  Future<List<MessageModel>> getMessages({
    String? conversationId,
    int? limit,
    int? offset,
  }) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      var messages = _messagesBox.values.toList();
      
      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply pagination
      if (offset != null) {
        messages = messages.skip(offset).toList();
      }
      if (limit != null) {
        messages = messages.take(limit).toList();
      }
      
      return messages;
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }
  
  Future<void> deleteMessage(String id) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      await _messagesBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
  
  // Conversation operations
  Future<String> saveConversation(ConversationModel conversation) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      await _conversationsBox.put(conversation.id, conversation);
      return conversation.id;
    } catch (e) {
      throw Exception('Failed to save conversation: $e');
    }
  }
  
  Future<ConversationModel?> getConversation(String id) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      return _conversationsBox.get(id);
    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }
  
  Future<List<ConversationModel>> getConversations({
    String? characterId,
    int? limit,
    int? offset,
  }) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      var conversations = _conversationsBox.values.toList();
      
      // Filter by character if specified
      if (characterId != null) {
        conversations = conversations
            .where((conv) => conv.characterId == characterId)
            .toList();
      }
      
      // Sort by updated date (newest first)
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Apply pagination
      if (offset != null) {
        conversations = conversations.skip(offset).toList();
      }
      if (limit != null) {
        conversations = conversations.take(limit).toList();
      }
      
      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }
  
  Future<void> deleteConversation(String id) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      // Get conversation to find associated messages
      final conversation = await getConversation(id);
      if (conversation != null) {
        // Delete all messages in this conversation
        for (final messageId in conversation.messageIds) {
          await deleteMessage(messageId);
        }
      }
      
      // Delete the conversation
      await _conversationsBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }
  
  // Create new conversation
  Future<ConversationModel> createConversation({
    required String characterId,
    String? title,
  }) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      final now = DateTime.now();
      final conversation = ConversationModel(
        id: _uuid.v4(),
        title: title ?? 'New Conversation',
        createdAt: now,
        updatedAt: now,
        characterId: characterId,
        messageIds: [],
      );
      
      await saveConversation(conversation);
      return conversation;
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }
  
  // Add message to conversation
  Future<void> addMessageToConversation(
    String conversationId,
    MessageModel message,
  ) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      // Save the message
      await saveMessage(message);
      
      // Update conversation
      final conversation = await getConversation(conversationId);
      if (conversation != null) {
        final updatedConversation = conversation.copyWith(
          messageIds: [...conversation.messageIds, message.id],
          updatedAt: DateTime.now(),
        );
        await saveConversation(updatedConversation);
      }
    } catch (e) {
      throw Exception('Failed to add message to conversation: $e');
    }
  }
  
  // Get messages for a specific conversation
  Future<List<MessageModel>> getConversationMessages(String conversationId) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      final conversation = await getConversation(conversationId);
      if (conversation == null) return [];
      
      final messages = <MessageModel>[];
      for (final messageId in conversation.messageIds) {
        final message = await getMessage(messageId);
        if (message != null) {
          messages.add(message);
        }
      }
      
      // Sort by timestamp (oldest first for conversation view)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return messages;
    } catch (e) {
      throw Exception('Failed to get conversation messages: $e');
    }
  }
  
  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      await _settingsBox.put(key, {'value': value});
    } catch (e) {
      throw Exception('Failed to save setting: $e');
    }
  }
  
  Future<T?> getSetting<T>(String key) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      final setting = _settingsBox.get(key);
      return setting?['value'] as T?;
    } catch (e) {
      throw Exception('Failed to get setting: $e');
    }
  }
  
  Future<void> deleteSetting(String key) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      await _settingsBox.delete(key);
    } catch (e) {
      throw Exception('Failed to delete setting: $e');
    }
  }
  
  // Utility methods
  Future<void> clearAllData() async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      await _messagesBox.clear();
      await _conversationsBox.clear();
      await _settingsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
  
  Future<Map<String, int>> getStatistics() async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      return {
        'totalMessages': _messagesBox.length,
        'totalConversations': _conversationsBox.length,
        'totalSettings': _settingsBox.length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
  
  // Search functionality
  Future<List<MessageModel>> searchMessages(String query) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      final messages = _messagesBox.values
          .where((message) => 
              message.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return messages;
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }
  
  // Export/Import functionality
  Future<Map<String, dynamic>> exportData() async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      final messages = _messagesBox.values.map((m) => m.toJson()).toList();
      final conversations = _conversationsBox.values.map((c) => c.toJson()).toList();
      final settings = <String, dynamic>{};
      
      for (final key in _settingsBox.keys) {
        final setting = _settingsBox.get(key);
        if (setting != null) {
          settings[key] = setting['value'];
        }
      }
      
      return {
        'messages': messages,
        'conversations': conversations,
        'settings': settings,
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
  
  Future<void> importData(Map<String, dynamic> data) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    
    try {
      // Clear existing data
      await clearAllData();
      
      // Import messages
      if (data['messages'] != null) {
        for (final messageJson in data['messages']) {
          final message = MessageModel.fromJson(messageJson);
          await saveMessage(message);
        }
      }
      
      // Import conversations
      if (data['conversations'] != null) {
        for (final conversationJson in data['conversations']) {
          final conversation = ConversationModel.fromJson(conversationJson);
          await saveConversation(conversation);
        }
      }
      
      // Import settings
      if (data['settings'] != null) {
        for (final entry in (data['settings'] as Map<String, dynamic>).entries) {
          await saveSetting(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
