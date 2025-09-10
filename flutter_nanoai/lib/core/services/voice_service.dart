import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_model.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();
  
  static VoiceService get instance => _instance;
  
  late FlutterTts _flutterTts;
  late SpeechToText _speechToText;
  
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  
  // Voice settings
  double _speechRate = 0.8;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _language = 'ar-SA';
  
  // Stream controllers for state updates
  final StreamController<bool> _speakingController = StreamController<bool>.broadcast();
  final StreamController<bool> _listeningController = StreamController<bool>.broadcast();
  final StreamController<String> _speechResultController = StreamController<String>.broadcast();
  
  // Getters for streams
  Stream<bool> get speakingStream => _speakingController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<String> get speechResultStream => _speechResultController.stream;
  
  // Getters for state
  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize TTS
      _flutterTts = FlutterTts();
      await _setupTts();
      
      // Initialize Speech to Text
      _speechToText = SpeechToText();
      await _setupSpeechToText();
      
      // Load saved settings
      await _loadSettings();
      
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Voice service initialization error: $e');
      }
    }
  }
  
  Future<void> _setupTts() async {
    // Set up TTS callbacks
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _speakingController.add(true);
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _speakingController.add(false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      _speakingController.add(false);
      if (kDebugMode) {
        print('TTS Error: $msg');
      }
    });
    
    // Configure TTS settings
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);
  }
  
  Future<void> _setupSpeechToText() async {
    // Request microphone permission
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
    
    // Initialize speech to text
    final available = await _speechToText.initialize(
      onError: (error) {
        _isListening = false;
        _listeningController.add(false);
        if (kDebugMode) {
          print('Speech recognition error: $error');
        }
      },
      onStatus: (status) {
        if (kDebugMode) {
          print('Speech recognition status: $status');
        }
      },
    );
    
    if (!available) {
      throw Exception('Speech recognition not available');
    }
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble('voice_speech_rate') ?? 0.8;
    _pitch = prefs.getDouble('voice_pitch') ?? 1.0;
    _volume = prefs.getDouble('voice_volume') ?? 1.0;
    _language = prefs.getString('voice_language') ?? 'ar-SA';
    
    // Apply loaded settings
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);
  }
  
  Future<void> speak(String text, {CharacterModel? character}) async {
    if (!_isInitialized || text.isEmpty) return;
    
    try {
      // Stop any current speech
      await stop();
      
      // Adjust voice settings based on character
      if (character != null) {
        await _applyCharacterVoice(character);
      }
      
      // Speak the text
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('Speak error: $e');
      }
    }
  }
  
  Future<void> _applyCharacterVoice(CharacterModel character) async {
    // Adjust voice parameters based on character
    if (character.id == 'nano') {
      // Female voice settings
      await _flutterTts.setPitch(1.2); // Higher pitch for female
      await _flutterTts.setSpeechRate(0.9); // Slightly faster
    } else if (character.id == 'naruto') {
      // Male voice settings
      await _flutterTts.setPitch(0.8); // Lower pitch for male
      await _flutterTts.setSpeechRate(1.0); // Normal speed
    }
  }
  
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _speakingController.add(false);
    } catch (e) {
      if (kDebugMode) {
        print('Stop speaking error: $e');
      }
    }
  }
  
  Future<void> startListening({String? localeId}) async {
    if (!_isInitialized || _isListening) return;
    
    try {
      // Stop any current speech
      await stop();
      
      // Start listening
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _speechResultController.add(result.recognizedWords);
            stopListening();
          }
        },
        localeId: localeId ?? _language,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: false,
      );
      
      _isListening = true;
      _listeningController.add(true);
    } catch (e) {
      _isListening = false;
      _listeningController.add(false);
      if (kDebugMode) {
        print('Start listening error: $e');
      }
    }
  }
  
  Future<void> stopListening() async {
    if (!_isInitialized || !_isListening) return;
    
    try {
      await _speechToText.stop();
      _isListening = false;
      _listeningController.add(false);
    } catch (e) {
      if (kDebugMode) {
        print('Stop listening error: $e');
      }
    }
  }
  
  // Settings methods
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    await _saveSettings();
  }
  
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
    await _saveSettings();
  }
  
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _flutterTts.setVolume(volume);
    await _saveSettings();
  }
  
  Future<void> setLanguage(String language) async {
    _language = language;
    await _flutterTts.setLanguage(language);
    await _saveSettings();
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('voice_speech_rate', _speechRate);
    await prefs.setDouble('voice_pitch', _pitch);
    await prefs.setDouble('voice_volume', _volume);
    await prefs.setString('voice_language', _language);
  }
  
  // Getters for current settings
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get language => _language;
  
  // Get available languages
  Future<List<dynamic>> getLanguages() async {
    if (!_isInitialized) return [];
    return await _flutterTts.getLanguages ?? [];
  }
  
  // Get available voices
  Future<List<dynamic>> getVoices() async {
    if (!_isInitialized) return [];
    return await _flutterTts.getVoices ?? [];
  }
  
  // Check if speech recognition is available
  Future<bool> isSpeechRecognitionAvailable() async {
    return await _speechToText.initialize();
  }
  
  // Get available locales for speech recognition
  List<LocaleName> getAvailableLocales() {
    return _speechToText.locales;
  }
  
  void dispose() {
    _speakingController.close();
    _listeningController.close();
    _speechResultController.close();
  }
}
