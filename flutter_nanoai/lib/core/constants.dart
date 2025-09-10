class AppConstants {
  // App Information
  static const String appName = 'NanoAI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart AI Assistant with Arabic Support';
  
  // Database
  static const String messagesBox = 'messages';
  static const String conversationsBox = 'conversations';
  static const String settingsBox = 'settings';
  
  // API Configuration
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Voice Settings
  static const double defaultSpeechRate = 0.5;
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 0.8;
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double avatarSize = 60.0;
  
  // Animation Durations
  static const int shortAnimation = 300;
  static const int mediumAnimation = 500;
  static const int longAnimation = 800;
  
  // Character IDs
  static const String nanoCharacterId = 'nano';
  static const String narutoCharacterId = 'naruto';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'ar'];
  static const String defaultLanguage = 'ar';
  
  // Error Messages
  static const String networkError = 'Network connection error';
  static const String apiError = 'API service unavailable';
  static const String voiceError = 'Voice service error';
  static const String storageError = 'Storage access error';
}
