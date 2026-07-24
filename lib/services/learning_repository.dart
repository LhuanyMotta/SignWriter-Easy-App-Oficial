import 'package:flutter/material.dart';

import '../models/lesson_category_model.dart';
import '../models/lesson_exercise_model.dart';
import 'learning_content_service.dart';

/// Fonte de conteúdo didático. Trocar mock ↔ remoto sem redesenhar telas.
abstract class LearningRepository {
  Future<List<LessonCategoryModel>> loadCategories(Locale locale);
}

/// Preferência: Supabase quando houver lições publicadas; senão JSON local.
class DefaultLearningRepository implements LearningRepository {
  DefaultLearningRepository({
    LearningContentService? contentService,
    this.forceMock = false,
  }) : _contentService = contentService ?? LearningContentService();

  final LearningContentService _contentService;

  /// Quando true, ignora remoto (útil para desenvolver UI offline).
  final bool forceMock;

  @override
  Future<List<LessonCategoryModel>> loadCategories(Locale locale) async {
    if (forceMock) {
      return _enrichWithDemoExercises(
        await _contentService.loadLocalCategories(locale),
      );
    }

    final categories = await _contentService.loadCategories(locale);
    return _enrichWithDemoExercises(categories);
  }

  /// Injeta exercícios visuais de demonstração na 1ª lição sem exercícios.
  List<LessonCategoryModel> _enrichWithDemoExercises(
    List<LessonCategoryModel> categories,
  ) {
    if (categories.isEmpty) return categories;

    return categories.map((category) {
      final lessons = category.lessons.map((lesson) {
        if (lesson.exercises.isNotEmpty) return lesson;
        return lesson.copyWith(
          exercises: [
            LessonExerciseModel(
              id: '${lesson.id}-demo-recognize',
              type: LessonExerciseType.recognizeSymbol,
              prompt:
                  'Observe o símbolo (placeholder) e escolha o que ele representa.',
              mediaAsset: 'assets/images/signwriter_logo.png',
              options: const [
                ExerciseOptionModel(id: 'a', label: 'Configuração de mão'),
                ExerciseOptionModel(id: 'b', label: 'Movimento'),
                ExerciseOptionModel(id: 'c', label: 'Expressão facial'),
                ExerciseOptionModel(id: 'd', label: 'Pontuação'),
              ],
              correctOptionId: 'a',
              explanation:
                  'Neste exercício de demonstração, o placeholder representa uma configuração de mão.',
            ),
            LessonExerciseModel(
              id: '${lesson.id}-demo-writing',
              type: LessonExerciseType.chooseCorrectWriting,
              prompt:
                  'Qual escrita melhor representa o sinal de referência? (demonstração)',
              mediaAsset: 'assets/images/signwriter_logo.png',
              options: const [
                ExerciseOptionModel(
                  id: 'w1',
                  label: 'Opção A',
                  mediaAsset: 'assets/images/signwriter_logo.png',
                ),
                ExerciseOptionModel(
                  id: 'w2',
                  label: 'Opção B',
                  mediaAsset: 'assets/images/signwriter_logo.png',
                ),
                ExerciseOptionModel(
                  id: 'w3',
                  label: 'Opção C',
                  mediaAsset: 'assets/images/signwriter_logo.png',
                ),
              ],
              correctOptionId: 'w1',
              explanation:
                  'Exercício visual de demonstração até o SignBank fornecer FSW real.',
            ),
            LessonExerciseModel(
              id: '${lesson.id}-demo-mc',
              type: LessonExerciseType.multipleChoice,
              prompt:
                  'O SignWriting representa diretamente uma língua de sinais?',
              options: const [
                ExerciseOptionModel(id: 'yes', label: 'Sim'),
                ExerciseOptionModel(id: 'no', label: 'Não'),
              ],
              correctOptionId: 'yes',
              explanation:
                  'SignWriting registra mãos, movimentos, contato e expressões não manuais.',
            ),
          ],
        );
      }).toList();

      return LessonCategoryModel(
        id: category.id,
        title: category.title,
        description: category.description,
        iconKey: category.iconKey,
        colorHex: category.colorHex,
        lessons: lessons,
      );
    }).toList();
  }
}
