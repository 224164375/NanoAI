import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message_model.dart';
import '../models/character_model.dart';

enum AIMode { local, connected, hybrid }

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();
  
  static AIService get instance => _instance;
  
  GenerativeModel? _geminiModel;
  AIMode _currentMode = AIMode.hybrid;
  String? _apiKey;
  
  // Local responses in Arabic
  final Map<String, List<String>> _localResponses = {
    'greeting': [
      'مرحباً! أنا نانو، مساعدك الذكي. كيف يمكنني مساعدتك اليوم؟',
      'أهلاً وسهلاً! أنا هنا لمساعدتك في أي شيء تحتاجه.',
      'السلام عليكم! أنا نانو، سعيدة بلقائك. ما الذي يمكنني فعله لك؟',
    ],
    'help': [
      'يمكنني مساعدتك في العديد من الأمور: الإجابة على الأسئلة، المحادثة، تقديم المعلومات، والمزيد!',
      'أنا هنا لأساعدك! يمكنني الدردشة معك، الإجابة على استفساراتك، أو تقديم المساعدة في مواضيع مختلفة.',
      'بإمكاني مساعدتك في الكثير من الأشياء. فقط اسألني عن أي موضوع تريد معرفة المزيد عنه!',
    ],
    'thanks': [
      'العفو! سعيدة بأنني استطعت مساعدتك.',
      'لا شكر على واجب! أنا هنا دائماً لمساعدتك.',
      'أهلاً وسهلاً! هذا واجبي ومتعتي.',
    ],
    'goodbye': [
      'وداعاً! أتطلع للحديث معك مرة أخرى قريباً.',
      'إلى اللقاء! كان من دواعي سروري التحدث معك.',
      'مع السلامة! لا تتردد في العودة إلي في أي وقت.',
    ],
    'default': [
      'هذا سؤال مثير للاهتمام! دعني أفكر في الأمر...',
      'أفهم ما تقصده. هل يمكنك توضيح أكثر؟',
      'هذا موضوع شيق! أخبرني المزيد عن رأيك.',
    ],
  };
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key');
    
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _geminiModel = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey!,
      );
    }
    
    final modeIndex = prefs.getInt('ai_mode') ?? 2; // Default to hybrid
    _currentMode = AIMode.values[modeIndex];
  }
  
  Future<void> setAPIKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey);
    
    if (apiKey.isNotEmpty) {
      _geminiModel = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
    }
  }
  
  Future<void> setAIMode(AIMode mode) async {
    _currentMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ai_mode', mode.index);
  }
  
  AIMode get currentMode => _currentMode;
  
  Future<String> generateResponse(
    String message,
    CharacterModel character,
    List<MessageModel> conversationHistory,
  ) async {
    switch (_currentMode) {
      case AIMode.local:
        return _generateLocalResponse(message, character);
      case AIMode.connected:
        return await _generateConnectedResponse(message, character, conversationHistory);
      case AIMode.hybrid:
        return await _generateHybridResponse(message, character, conversationHistory);
    }
  }
  
  String _generateLocalResponse(String message, CharacterModel character) {
    final lowerMessage = message.toLowerCase();
    
    // Detect intent based on keywords
    if (_containsAny(lowerMessage, ['مرحبا', 'أهلا', 'السلام', 'hello', 'hi'])) {
      return _getRandomResponse('greeting', character);
    } else if (_containsAny(lowerMessage, ['مساعدة', 'help', 'ساعدني'])) {
      return _getRandomResponse('help', character);
    } else if (_containsAny(lowerMessage, ['شكرا', 'thanks', 'thank you'])) {
      return _getRandomResponse('thanks', character);
    } else if (_containsAny(lowerMessage, ['وداعا', 'bye', 'goodbye', 'مع السلامة'])) {
      return _getRandomResponse('goodbye', character);
    } else {
      return _getRandomResponse('default', character);
    }
  }
  
  Future<String> _generateConnectedResponse(
    String message,
    CharacterModel character,
    List<MessageModel> conversationHistory,
  ) async {
    if (_geminiModel == null) {
      return 'عذراً، لم يتم تكوين مفتاح API. يرجى إضافة مفتاح Gemini API في الإعدادات.';
    }
    
    try {
      // Build context with character personality
      final context = _buildCharacterContext(character, conversationHistory);
      final prompt = '$context\n\nالمستخدم: $message\n${character.name}:';
      
      final content = [Content.text(prompt)];
      final response = await _geminiModel!.generateContent(content);
      
      return response.text ?? _generateLocalResponse(message, character);
    } catch (e) {
      // Fallback to local response on error
      return _generateLocalResponse(message, character);
    }
  }
  
  Future<String> _generateHybridResponse(
    String message,
    CharacterModel character,
    List<MessageModel> conversationHistory,
  ) async {
    // Try connected first, fallback to local
    if (_geminiModel != null) {
      try {
        return await _generateConnectedResponse(message, character, conversationHistory);
      } catch (e) {
        // If connected fails, use local
        return _generateLocalResponse(message, character);
      }
    } else {
      // No API key, use local
      return _generateLocalResponse(message, character);
    }
  }
  
  String _buildCharacterContext(CharacterModel character, List<MessageModel> history) {
    final personality = character.id == 'nano' 
        ? 'أنت نانو، فتاة أنمي ذكية ومفيدة. تتحدثين بطريقة ودودة ومرحة. تحبين مساعدة الآخرين وتجيبين بالعربية دائماً.'
        : 'أنت ناروتو، شاب أنمي نشيط وشجاع. تتحدث بحماس وتشجع الآخرين. تحب المغامرات وتجيب بالعربية دائماً.';
    
    final recentHistory = history.take(5).map((msg) => 
        '${msg.isUser ? "المستخدم" : character.name}: ${msg.content}'
    ).join('\n');
    
    return '''$personality

المحادثة السابقة:
$recentHistory

تعليمات:
- أجب بالعربية فقط
- كن ${character.id == 'nano' ? 'ودودة ومفيدة' : 'متحمساً ومشجعاً'}
- اجعل الإجابة قصيرة ومفيدة
- تفاعل مع السياق السابق للمحادثة''';
  }
  
  String _getRandomResponse(String category, CharacterModel character) {
    final responses = _localResponses[category] ?? _localResponses['default']!;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % responses.length;
    var response = responses[randomIndex];
    
    // Customize response based on character
    if (character.id == 'naruto') {
      response = response.replaceAll('نانو', 'ناروتو');
      response = response.replaceAll('سعيدة', 'سعيد');
      response = response.replaceAll('مساعدك', 'مساعدك');
    }
    
    return response;
  }
  
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
  
  // Get available AI modes with descriptions
  Map<AIMode, Map<String, String>> getAIModes() {
    return {
      AIMode.local: {
        'name': 'الوضع المحلي',
        'nameEn': 'Local Mode',
        'description': 'يعمل بدون إنترنت مع ردود محفوظة مسبقاً',
        'descriptionEn': 'Works offline with pre-saved responses',
      },
      AIMode.connected: {
        'name': 'الوضع المتصل',
        'nameEn': 'Connected Mode',
        'description': 'يستخدم الذكاء الاصطناعي المتقدم عبر الإنترنت',
        'descriptionEn': 'Uses advanced AI through internet connection',
      },
      AIMode.hybrid: {
        'name': 'الوضع المختلط',
        'nameEn': 'Hybrid Mode',
        'description': 'يجمع بين الوضعين حسب توفر الإنترنت',
        'descriptionEn': 'Combines both modes based on internet availability',
      },
    };
  }
}
