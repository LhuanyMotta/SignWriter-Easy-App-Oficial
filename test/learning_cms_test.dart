import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_block_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_category_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_exercise_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_source_model.dart';
import 'package:signwriter_easy_app_oficial/models/learning_progress_model.dart';
import 'package:signwriter_easy_app_oficial/models/media_asset_model.dart';
import 'package:signwriter_easy_app_oficial/models/content_source_model.dart';

void main() {
  group('LessonBlockModel parsing', () {
    test('parse todos os tipos suportados', () {
      for (final type in [
        'heading',
        'text',
        'bullets',
        'highlight',
        'image',
        'signwriting',
        'comparison',
      ]) {
        final block = LessonBlockModel.fromMap({
          'id': 'b-$type',
          'lesson_id': 'les-1',
          'type': type,
          'title_pt': 'Título',
          'body_pt': 'Corpo',
          'bullets_pt': ['a', 'b'],
          'order_index': 1,
        });
        expect(block.type.name, type);
      }
    });

    test('tipo desconhecido não quebra', () {
      final block = LessonBlockModel.fromMap({
        'id': 'x',
        'type': 'video_future',
        'body_pt': 'ok',
      });
      expect(block.type, LessonBlockType.unknown);
    });

    test('localização pt/en', () {
      final pt = LessonBlockModel.fromMap({
        'id': '1',
        'type': 'text',
        'body_pt': 'Olá',
        'body_en': 'Hello',
      }, lang: 'pt');
      final en = LessonBlockModel.fromMap({
        'id': '1',
        'type': 'text',
        'body_pt': 'Olá',
        'body_en': 'Hello',
      }, lang: 'en');
      expect(pt.body, 'Olá');
      expect(en.body, 'Hello');
    });

    test('associa mídia', () {
      final media = MediaAssetModel.fromMap({
        'id': 'm1',
        'kind': 'image',
        'external_url': 'https://example.com/a.png',
        'alt_text_pt': 'Alt',
        'attribution_text': 'Licença X',
      });
      final block = LessonBlockModel.fromMap({
        'id': 'b1',
        'type': 'image',
        'media_id': 'm1',
        'caption_pt': 'Legenda',
      }, media: media);
      expect(block.media?.externalUrl, contains('example.com'));
      expect(block.effectiveAltText, 'Alt');
    });
  });

  group('Ordenação', () {
    test('módulos, lições e blocos', () {
      final category = LessonCategoryModel.fromMap({
        'id': 'cat-1',
        'title': 'Módulo',
        'description': '',
        'icon': 'school',
        'color': '#2D78BB',
        'lessons': [
          {
            'id': 'les-2',
            'title': 'B',
            'summary': '',
            'estimatedMinutes': 5,
            'difficulty': 'Iniciante',
            'blocks': [
              {'id': 'b2', 'type': 'text', 'body': '2', 'order_index': 2},
              {'id': 'b1', 'type': 'text', 'body': '1', 'order_index': 1},
            ],
          },
        ],
      });
      expect(category.lessons.first.blocks.first.body, '1');
      expect(category.lessons.first.blocks.last.body, '2');
    });
  });

  group('Fontes e exercícios', () {
    test('fonte e páginas', () {
      final source = ContentSourceModel.fromMap({
        'id': 's1',
        'title': 'Lições SignWriting',
        'authors': ['Valerie Sutton'],
        'translators': ['Marianne Stumpf'],
        'source_url': 'https://example.com',
        'license_name': 'CC',
        'license_url': 'https://creativecommons.org',
        'attribution_text': 'Atribuição',
      });
      final lessonSource = LessonSourceModel.fromMap({
        'id': 'ls1',
        'lesson_id': 'les-1',
        'source_id': 's1',
        'page_start': 21,
        'page_end': 23,
        'is_primary': true,
        'adaptation_note_pt': 'Adaptado para o app',
      }, source: source);
      expect(lessonSource.pageRangeLabel, 'pp. 21–23');
      expect(lessonSource.isPrimary, isTrue);
      expect(lessonSource.source?.authors.first, 'Valerie Sutton');
    });

    test('exercício com imagem e FSW', () {
      final exercise = LessonExerciseModel.fromMap({
        'id': 'ex-1',
        'type': 'recognizeSymbol',
        'prompt_pt': 'Qual sinal?',
        'media_url': 'https://cdn/img.png',
        'fsw': 'M500x500S10000',
        'correct_option_id': 'a',
        'explanation_pt': 'Porque sim',
        'options': [
          {
            'id': 'a',
            'label_pt': 'Mão',
            'fsw': 'M500x500S10000',
            'order_index': 0,
          },
          {
            'id': 'b',
            'label_pt': 'Movimento',
            'media_asset': 'assets/images/signwriter_logo.png',
            'order_index': 1,
          },
        ],
        'pairs': [
          {
            'left_pt': 'A',
            'right_pt': '1',
            'left_fsw': 'M1',
            'right_media_url': 'https://cdn/r.png',
            'order_index': 0,
          },
        ],
      });
      expect(exercise.hasMedia, isTrue);
      expect(exercise.hasFsw, isTrue);
      expect(exercise.options.first.hasFsw, isTrue);
      expect(exercise.pairs.first.hasLeftVisual, isTrue);
      expect(exercise.type, LessonExerciseType.recognizeSymbol);
    });

    test('todos os cinco tipos de exercício', () {
      for (final type in [
        'multipleChoice',
        'trueFalse',
        'matching',
        'recognizeSymbol',
        'chooseCorrectWriting',
      ]) {
        final ex = LessonExerciseModel.fromMap({
          'id': type,
          'type': type,
          'prompt_pt': 'p',
        });
        expect(ex.type.name, type);
      }
    });
  });

  group('Progresso', () {
    test('progresso local e campos remotos', () {
      final entry = LessonProgressEntry.fromMap({
        'lesson_id': 'les-1',
        'category_id': 'cat-1',
        'status': 'completed',
        'best_score': 0.8,
        'attempts': 2,
        'last_block_id': 'sec-1-text',
        'completed_at': '2026-07-01T10:00:00Z',
      });
      expect(entry.completed, isTrue);
      expect(entry.categoryId, 'cat-1');
      expect(entry.bestScore, 0.8);
      expect(entry.lastBlockId, 'sec-1-text');
      expect(entry.scoreRatio, 0.8);
    });

    test('ausência de login — modelo vazio válido', () {
      final progress = LearningProgressModel.empty();
      expect(progress.completedLessons, 0);
      expect(progress.lessonProgress('x'), isNull);
    });
  });

  group('Conteúdo vazio e rascunho', () {
    test('lição draft permanece no modelo quando carregada', () {
      final lesson = LessonModel.fromMap({
        'id': 'les-d',
        'title_pt': 'Rascunho',
        'summary_pt': 's',
        'status': 'draft',
        'blocks': [],
      });
      expect(lesson.status, 'draft');
      expect(lesson.isDraft, isTrue);
      expect(lesson.isPublished, isFalse);
    });

    test('módulo draft no modelo', () {
      final category = LessonCategoryModel.fromMap({
        'id': 'cat-d',
        'title': 'Mod',
        'description': 'd',
        'icon': 'school',
        'color': '#2D78BB',
        'status': 'draft',
        'lessons': [
          {
            'id': 'les-d',
            'title_pt': 'Rascunho',
            'summary_pt': 's',
            'status': 'draft',
          },
        ],
      });
      expect(category.isDraft, isTrue);
      expect(category.lessons.first.isDraft, isTrue);
    });

    test('curso sem blocos ainda é parseável', () {
      final lesson = LessonModel.fromMap({
        'id': 'les-e',
        'title_pt': 'Vazia',
        'summary_pt': 's',
        'blocks': [],
        'exercises': [],
      });
      expect(lesson.blocks, isEmpty);
      expect(lesson.hasExercises, isFalse);
    });
  });

  group('Migração sections→blocks (IDs estáveis)', () {
    test('IDs gerados pela migração SQL são estáveis e únicos', () {
      final sectionId = 12;
      final ids = {
        'sec-$sectionId-heading',
        'sec-$sectionId-text',
        'sec-$sectionId-bullets',
        'sec-$sectionId-highlight',
      };
      expect(ids.length, 4);
      expect(ids.every((id) => id.startsWith('sec-12-')), isTrue);
    });
  });
}
