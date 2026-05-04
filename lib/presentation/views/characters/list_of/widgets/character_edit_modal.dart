import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/models/character_entity.dart';
import '../../../../controllers/characters_view_model.dart';

class CharacterEditModal extends StatefulWidget {
  final Character character;
  final CharactersViewModel viewModel;

  const CharacterEditModal({
    super.key,
    required this.character,
    required this.viewModel,
  });

  @override
  State<CharacterEditModal> createState() => _CharacterEditModalState();
}

class _CharacterEditModalState extends State<CharacterEditModal> {
  late TextEditingController _nameController;
  late TextEditingController _levelController;
  late TextEditingController _threatController;
  late TextEditingController _attackController;
  late TextEditingController _healthController;
  late TextEditingController _starsController;

  late CharacterClass _selectedClass;
  late CharacterRarity _selectedRarity;
  late CharacterAlignment _selectedAlignment;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character.name);
    _levelController = TextEditingController(
      text: widget.character.level.toString(),
    );
    _threatController = TextEditingController(
      text: widget.character.threat.toString(),
    );
    _attackController = TextEditingController(
      text: widget.character.attack.toString(),
    );
    _healthController = TextEditingController(
      text: widget.character.health.toString(),
    );
    _starsController = TextEditingController(
      text: widget.character.stars.toString(),
    );

    _selectedClass = widget.character.characterClass;
    _selectedRarity = widget.character.rarity;
    _selectedAlignment = widget.character.alignment;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _threatController.dispose();
    _attackController.dispose();
    _healthController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  void _saveCharacter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedCharacter = widget.character.copyWith(
        name: _nameController.text,
        level: int.parse(_levelController.text),
        threat: int.parse(_threatController.text),
        attack: int.parse(_attackController.text),
        health: int.parse(_healthController.text),
        stars: int.parse(_starsController.text),
        characterClass: _selectedClass,
        rarity: _selectedRarity,
        alignment: _selectedAlignment,
        updatedAt: DateTime.now(),
      );

      widget.viewModel.commands.updateCharacterCommand.parameter = (
        character: updatedCharacter,
      );
      await widget.viewModel.commands.updateCharacterCommand.execute();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personagem atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar ${widget.character.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CharacterClass>(
                      value: _selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Classe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      items: CharacterClass.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedClass = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<CharacterRarity>(
                      value: _selectedRarity,
                      decoration: InputDecoration(
                        labelText: 'Raridade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      items: CharacterRarity.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRarity = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Alignment
              DropdownButtonFormField<CharacterAlignment>(
                value: _selectedAlignment,
                decoration: InputDecoration(
                  labelText: 'Alinhamento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                items: CharacterAlignment.values
                    .map(
                      (a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAlignment = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Level, Threat, Attack Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _levelController,
                      decoration: InputDecoration(
                        labelText: 'Nível',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        final level = int.tryParse(value!);
                        if (level == null || level < 1 || level > 80) {
                          return 'De 1 a 80';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _threatController,
                      decoration: InputDecoration(
                        labelText: 'Ameaça',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        if (int.tryParse(value!) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _attackController,
                      decoration: InputDecoration(
                        labelText: 'Ataque',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        if (int.tryParse(value!) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Health and Stars Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _healthController,
                      decoration: InputDecoration(
                        labelText: 'Vida',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        if (int.tryParse(value!) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _starsController,
                      decoration: InputDecoration(
                        labelText: 'Estrelas',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        final stars = int.tryParse(value!);
                        if (stars == null || stars < 1 || stars > 14) {
                          return 'De 1 a 14';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCharacter,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
