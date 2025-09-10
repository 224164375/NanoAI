import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/voice_service.dart';
import '../../core/models/character_model.dart';

class VoiceState {
  final bool isSpeaking;
  final bool isListening;
  final bool isInitialized;
  final String? error;
  final String? lastRecognizedText;

  const VoiceState({
    required this.isSpeaking,
    required this.isListening,
    required this.isInitialized,
    this.error,
    this.lastRecognizedText,
  });

  VoiceState copyWith({
    bool? isSpeaking,
    bool? isListening,
    bool? isInitialized,
    String? error,
    String? lastRecognizedText,
  }) {
    return VoiceState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      lastRecognizedText: lastRecognizedText ?? this.lastRecognizedText,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  VoiceNotifier() : super(const VoiceState(
    isSpeaking: false,
    isListening: false,
    isInitialized: false,
  )) {
    _initialize();
  }

  final VoiceService _voiceService = VoiceService.instance;

  Future<void> _initialize() async {
    try {
      if (!_voiceService.isInitialized) {
        await _voiceService.initialize();
      }
      
      // Listen to voice service streams
      _voiceService.speakingStream.listen((isSpeaking) {
        state = state.copyWith(isSpeaking: isSpeaking);
      });
      
      _voiceService.listeningStream.listen((isListening) {
        state = state.copyWith(isListening: isListening);
      });
      
      _voiceService.speechResultStream.listen((text) {
        state = state.copyWith(lastRecognizedText: text);
      });
      
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> speak(String text, {CharacterModel? character}) async {
    try {
      await _voiceService.speak(text, character: character);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _voiceService.stop();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> startListening({String? localeId}) async {
    try {
      await _voiceService.startListening(localeId: localeId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopListening() async {
    try {
      await _voiceService.stopListening();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _voiceService.setSpeechRate(rate);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _voiceService.setPitch(pitch);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _voiceService.setVolume(volume);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      await _voiceService.setLanguage(language);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String? consumeRecognizedText() {
    final text = state.lastRecognizedText;
    state = state.copyWith(lastRecognizedText: null);
    return text;
  }

  // Getters for voice settings
  double get speechRate => _voiceService.speechRate;
  double get pitch => _voiceService.pitch;
  double get volume => _voiceService.volume;
  String get language => _voiceService.language;
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});
