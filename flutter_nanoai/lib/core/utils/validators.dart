class Validators {
  static String? validateApiKey(String? value) {
    if (value == null || value.isEmpty) {
      return 'API key is required';
    }
    if (value.length < 10) {
      return 'API key must be at least 10 characters';
    }
    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.trim().length > 1000) {
      return 'Message is too long (max 1000 characters)';
    }
    return null;
  }

  static String? validateConversationTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (value.trim().length > 50) {
      return 'Title is too long (max 50 characters)';
    }
    return null;
  }

  static bool isValidLanguageCode(String code) {
    return ['en', 'ar'].contains(code);
  }

  static bool isValidVoiceRate(double rate) {
    return rate >= 0.1 && rate <= 2.0;
  }

  static bool isValidVoicePitch(double pitch) {
    return pitch >= 0.5 && pitch <= 2.0;
  }

  static bool isValidVoiceVolume(double volume) {
    return volume >= 0.0 && volume <= 1.0;
  }
}
