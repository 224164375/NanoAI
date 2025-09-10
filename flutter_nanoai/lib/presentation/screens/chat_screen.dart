import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/message_model.dart';
import '../../core/services/ai_service.dart';
import '../providers/character_provider.dart';
import '../providers/voice_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/character_avatar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final character = ref.read(selectedCharacterProvider);
    if (character != null) {
      ref.read(chatProvider.notifier).initializeChat(character);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final character = ref.read(selectedCharacterProvider);
    if (character == null) return;

    // Create user message
    final userMessage = MessageModel(
      id: _uuid.v4(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      characterId: character.id,
    );

    // Add user message to chat
    await ref.read(chatProvider.notifier).addMessage(userMessage);
    
    // Clear input
    _messageController.clear();
    _messageFocusNode.unfocus();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Generate AI response
    await ref.read(chatProvider.notifier).generateResponse(content, character);
    
    // Scroll to bottom after response
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onVoiceResult(String text) {
    if (text.isNotEmpty) {
      _sendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final character = ref.watch(selectedCharacterProvider);
    final chatState = ref.watch(chatProvider);
    final voiceState = ref.watch(voiceProvider);

    if (character == null) {
      return Scaffold(
        body: Center(
          child: Text(localizations.selectCharacter),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            CharacterAvatar(
              character: character,
              size: 40,
              isAnimated: chatState.isGenerating,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.getDisplayName(localizations.locale.languageCode == 'ar'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  chatState.isGenerating 
                      ? localizations.speaking
                      : localizations.online,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Chat Messages
              Expanded(
                child: chatState.messages.isEmpty
                    ? _buildEmptyState(localizations, character)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          return MessageBubble(
                            message: message,
                            character: character,
                            onSpeak: (text) => ref.read(voiceProvider.notifier).speak(
                              text,
                              character: character,
                            ),
                          ).animate()
                            .fadeIn(delay: (index * 100).ms, duration: 300.ms)
                            .slideY(begin: 0.3, end: 0);
                        },
                      ),
              ),

              // Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    // Voice Input Button
                    VoiceInputButton(
                      onResult: _onVoiceResult,
                      character: character,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Text Input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          decoration: InputDecoration(
                            hintText: localizations.typeMessage,
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: 'Tajawal',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Send Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: chatState.isGenerating
                            ? null
                            : () => _sendMessage(_messageController.text),
                        icon: chatState.isGenerating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations, character) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CharacterAvatar(
            character: character,
            size: 120,
            isAnimated: true,
          ).animate()
            .scale(delay: 200.ms, duration: 600.ms)
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
          
          const SizedBox(height: 24),
          
          Text(
            'مرحباً! أنا ${character.getDisplayName(true)}',
            style: AppTheme.headingStyle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            character.getDescription(true),
            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 32),
          
          Text(
            localizations.typeMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'Tajawal',
            ),
          ).animate()
            .fadeIn(delay: 1200.ms, duration: 600.ms)
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }
}
