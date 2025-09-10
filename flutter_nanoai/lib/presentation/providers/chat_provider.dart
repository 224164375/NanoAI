import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/message_model.dart';
import '../../core/models/character_model.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/database_service.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isGenerating;
  final String? currentConversationId;
  final String? error;

  const ChatState({
    required this.messages,
    required this.isGenerating,
    this.currentConversationId,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isGenerating,
    String? currentConversationId,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState(
    messages: [],
    isGenerating: false,
  ));

  final AIService _aiService = AIService.instance;
  final DatabaseService _databaseService = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  Future<void> initializeChat(CharacterModel character) async {
    try {
      // Create new conversation
      final conversation = await _databaseService.createConversation(
        characterId: character.id,
        title: 'محادثة مع ${character.getDisplayName(true)}',
      );

      state = state.copyWith(
        currentConversationId: conversation.id,
        messages: [],
      );

      // Send welcome message
      final welcomeMessage = MessageModel(
        id: _uuid.v4(),
        content: character.getGreetings(true).first,
        isUser: false,
        timestamp: DateTime.now(),
        characterId: character.id,
      );

      await addMessage(welcomeMessage);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMessage(MessageModel message) async {
    try {
      // Add to local state
      state = state.copyWith(
        messages: [...state.messages, message],
      );

      // Save to database
      await _databaseService.saveMessage(message);

      // Add to conversation if exists
      if (state.currentConversationId != null) {
        await _databaseService.addMessageToConversation(
          state.currentConversationId!,
          message,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> generateResponse(String userMessage, CharacterModel character) async {
    try {
      state = state.copyWith(isGenerating: true);

      // Generate AI response
      final response = await _aiService.generateResponse(
        userMessage,
        character,
        state.messages,
      );

      // Create AI message
      final aiMessage = MessageModel(
        id: _uuid.v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        characterId: character.id,
      );

      // Add AI message
      await addMessage(aiMessage);

      state = state.copyWith(isGenerating: false);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadConversation(String conversationId) async {
    try {
      final messages = await _databaseService.getConversationMessages(conversationId);
      
      state = state.copyWith(
        messages: messages,
        currentConversationId: conversationId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearChat() async {
    try {
      state = state.copyWith(
        messages: [],
        currentConversationId: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
