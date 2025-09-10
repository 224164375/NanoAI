import 'package:flutter/material.dart';

class CharacterModel {
  final String id;
  final String name;
  final String nameAr;
  final String type;
  final String voice;
  final Color color;
  final String personality;
  final String description;
  final String descriptionAr;
  final String avatarPath;
  final String animationPath;
  final Map<String, dynamic> voiceSettings;
  final List<String> greetings;
  final List<String> greetingsAr;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.type,
    required this.voice,
    required this.color,
    required this.personality,
    required this.description,
    required this.descriptionAr,
    required this.avatarPath,
    required this.animationPath,
    required this.voiceSettings,
    required this.greetings,
    required this.greetingsAr,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      type: json['type'] ?? '',
      voice: json['voice'] ?? '',
      color: Color(int.parse(json['color'].replaceAll('#', '0xFF'))),
      personality: json['personality'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      avatarPath: json['avatarPath'] ?? '',
      animationPath: json['animationPath'] ?? '',
      voiceSettings: Map<String, dynamic>.from(json['voiceSettings'] ?? {}),
      greetings: List<String>.from(json['greetings'] ?? []),
      greetingsAr: List<String>.from(json['greetingsAr'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'type': type,
      'voice': voice,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'personality': personality,
      'description': description,
      'descriptionAr': descriptionAr,
      'avatarPath': avatarPath,
      'animationPath': animationPath,
      'voiceSettings': voiceSettings,
      'greetings': greetings,
      'greetingsAr': greetingsAr,
    };
  }

  CharacterModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? type,
    String? voice,
    Color? color,
    String? personality,
    String? description,
    String? descriptionAr,
    String? avatarPath,
    String? animationPath,
    Map<String, dynamic>? voiceSettings,
    List<String>? greetings,
    List<String>? greetingsAr,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      type: type ?? this.type,
      voice: voice ?? this.voice,
      color: color ?? this.color,
      personality: personality ?? this.personality,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      avatarPath: avatarPath ?? this.avatarPath,
      animationPath: animationPath ?? this.animationPath,
      voiceSettings: voiceSettings ?? this.voiceSettings,
      greetings: greetings ?? this.greetings,
      greetingsAr: greetingsAr ?? this.greetingsAr,
    );
  }

  String getDisplayName(bool isArabic) {
    return isArabic ? nameAr : name;
  }

  String getDescription(bool isArabic) {
    return isArabic ? descriptionAr : description;
  }

  List<String> getGreetings(bool isArabic) {
    return isArabic ? greetingsAr : greetings;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CharacterModel(id: $id, name: $name, nameAr: $nameAr)';
  }
}

// Predefined characters
class Characters {
  static const CharacterModel nano = CharacterModel(
    id: 'nano',
    name: 'Nano',
    nameAr: 'نانو',
    type: 'anime_girl',
    voice: 'female_ar',
    color: Color(0xFFFF69B4),
    personality: 'friendly_helpful',
    description: 'A friendly and helpful AI assistant who loves to chat and help with various tasks.',
    descriptionAr: 'مساعدة ذكية ودودة ومفيدة تحب الدردشة والمساعدة في المهام المختلفة.',
    avatarPath: 'assets/characters/nano_avatar.png',
    animationPath: 'assets/animations/nano_idle.json',
    voiceSettings: {
      'pitch': 1.2,
      'speechRate': 0.9,
      'volume': 1.0,
    },
    greetings: [
      'Hello! I\'m Nano, your AI assistant. How can I help you today?',
      'Hi there! I\'m here to help you with anything you need.',
      'Welcome! I\'m Nano, ready to assist you.',
    ],
    greetingsAr: [
      'مرحباً! أنا نانو، مساعدك الذكي. كيف يمكنني مساعدتك اليوم؟',
      'أهلاً وسهلاً! أنا هنا لمساعدتك في أي شيء تحتاجه.',
      'أهلاً بك! أنا نانو، مستعدة لمساعدتك.',
    ],
  );

  static const CharacterModel naruto = CharacterModel(
    id: 'naruto',
    name: 'Naruto',
    nameAr: 'ناروتو',
    type: 'anime_boy',
    voice: 'male_ar',
    color: Color(0xFFFF8C00),
    personality: 'energetic_brave',
    description: 'An energetic and brave AI assistant who encourages users and loves adventures.',
    descriptionAr: 'مساعد ذكي نشيط وشجاع يشجع المستخدمين ويحب المغامرات.',
    avatarPath: 'assets/characters/naruto_avatar.png',
    animationPath: 'assets/animations/naruto_idle.json',
    voiceSettings: {
      'pitch': 0.8,
      'speechRate': 1.0,
      'volume': 1.0,
    },
    greetings: [
      'Hey! I\'m Naruto, your energetic AI buddy! What adventure shall we go on today?',
      'Yo! Ready for some action? I\'m here to help you achieve anything!',
      'Believe it! I\'m Naruto, and I\'ll help you overcome any challenge!',
    ],
    greetingsAr: [
      'مرحباً! أنا ناروتو، رفيقك الذكي المليء بالطاقة! أي مغامرة سنخوضها اليوم؟',
      'أهلاً! مستعد للعمل؟ أنا هنا لمساعدتك في تحقيق أي شيء!',
      'صدقني! أنا ناروتو، وسأساعدك في التغلب على أي تحدٍ!',
    ],
  );

  static List<CharacterModel> get all => [nano, naruto];

  static CharacterModel? getById(String id) {
    try {
      return all.firstWhere((character) => character.id == id);
    } catch (e) {
      return null;
    }
  }

  static CharacterModel get defaultCharacter => nano;
}
