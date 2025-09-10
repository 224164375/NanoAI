import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/character_model.dart';

class CharacterNotifier extends StateNotifier<CharacterModel?> {
  CharacterNotifier() : super(null) {
    _loadSelectedCharacter();
  }

  Future<void> _loadSelectedCharacter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final characterId = prefs.getString('selected_character_id');
      
      if (characterId != null) {
        final character = Characters.getById(characterId);
        if (character != null) {
          state = character;
        } else {
          state = Characters.defaultCharacter;
        }
      } else {
        state = Characters.defaultCharacter;
      }
    } catch (e) {
      state = Characters.defaultCharacter;
    }
  }

  Future<void> selectCharacter(CharacterModel character) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_character_id', character.id);
      state = character;
    } catch (e) {
      // Handle error silently, keep current state
    }
  }

  CharacterModel get currentCharacter => state ?? Characters.defaultCharacter;
}

final selectedCharacterProvider = StateNotifierProvider<CharacterNotifier, CharacterModel?>((ref) {
  return CharacterNotifier();
});

final allCharactersProvider = Provider<List<CharacterModel>>((ref) {
  return Characters.all;
});
