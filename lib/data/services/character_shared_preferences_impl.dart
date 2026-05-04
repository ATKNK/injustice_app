import 'dart:convert';

import '../../core/failure/failure.dart';
import '../../core/typedefs/types_defs.dart';
import 'character_local_storage_interface.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/patterns/result.dart';

final class CharacterSharedPreferencesService
    implements ICharacterLocalStorage {
  // Chave de armazenamento para os personagens
  static const String _storageKey = 'characters';

  @override
  Future<CharacterResult> updateCharacter(Character c) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((item) => item.id == c.id);
          if (index == -1) {
            return Error(
              ApiLocalFailure('Personagem não encontrado para atualização'),
            );
          }

          final updatedCharacters = [...characters];
          updatedCharacters[index] = c;
          await _saveCharacters(updatedCharacters);
          return Success(c);
        },
        onFailure: (Failure errorValue) {
          return Error(
            ApiLocalFailure('Erro ao atualizar personagem: $errorValue'),
          );
        },
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((item) => item.id == id);
          if (index == -1) {
            return Error(
              ApiLocalFailure('Personagem não encontrado para remoção'),
            );
          }

          final deletedCharacter = characters[index];
          final updatedCharacters = characters
              .where((item) => item.id != id)
              .toList();
          await _saveCharacters(updatedCharacters);
          return Success(deletedCharacter);
        },
        onFailure: (Failure errorValue) {
          return Error(
            ApiLocalFailure('Erro ao remover personagem: $errorValue'),
          );
        },
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao remover personagem: $e'));
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getString(_storageKey);

      if (result == null || result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;

      final characters = decoded
          .map((e) => CharacterMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((item) => item.id == id);
          if (index == -1) {
            return Error(
              ApiLocalFailure('Personagem não encontrado para obter por id'),
            );
          }

          return Success(characters[index]);
        },
        onFailure: (Failure errorValue) {
          return Error(
            ApiLocalFailure('Erro ao obter personagem por id: $errorValue'),
          );
        },
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao obter personagem por id: $e'));
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final updatedCharacters = [...characters, character];
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async {
          if (failure is EmptyResultFailure) {
            await _saveCharacters([character]);
            return Success(character);
          }

          return Error(ApiLocalFailure('Erro ao salvar personagem'));
        },
      );
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar personagem: $e'),
      );
    }
  }

  /// Salva os personagens no storage
  Future<void> _saveCharacters(List<Character> characters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        characters.map((c) => CharacterMapper.toMap(c)).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      throw ApiLocalFailure('Erro ao salvar personagens: $e');
    }
  }
}
