class AppConfig {
  static const String appName = 'NanoAI';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.nanoai.flutter';
  
  // API Configuration
  static const String baseUrl = 'https://api.nanoai.com';
  static const String mongoConnectionString = 'mongodb://localhost:27017/nanoai';
  
  // Character Configuration
  static const Map<String, dynamic> characters = {
    'nano': {
      'name': 'Nano',
      'nameAr': 'نانو',
      'type': 'anime_girl',
      'voice': 'female_ar',
      'color': '#FF69B4',
      'personality': 'friendly_helpful',
    },
    'naruto': {
      'name': 'Naruto',
      'nameAr': 'ناروتو',
      'type': 'anime_boy',
      'voice': 'male_ar',
      'color': '#FF8C00',
      'personality': 'energetic_brave',
    },
  };
  
  // AI Modes
  static const Map<String, String> aiModes = {
    'local': 'Local Mode',
    'connected': 'Connected Mode',
    'hybrid': 'Hybrid Mode',
  };
  
  // Voice Settings
  static const Map<String, dynamic> voiceSettings = {
    'speechRate': 0.8,
    'pitch': 1.0,
    'volume': 1.0,
    'language': 'ar-SA',
  };
  
  // Animation Settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // Database Settings
  static const String dbName = 'nanoai.db';
  static const int dbVersion = 1;
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];
}
