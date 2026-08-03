import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_block_model.dart';
import 'package:signwriter_easy_app_oficial/services/learning_authoring_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final service = LearningAuthoringService(
    supabase: SupabaseClient('https://example.supabase.co', 'test-key'),
  );
  const blocks = [
    LessonBlockModel(
      id: 'new-heading-1',
      type: LessonBlockType.heading,
      title: 'Título',
    ),
    LessonBlockModel(
      id: 'new-text-1',
      type: LessonBlockType.text,
      body: 'Conteúdo',
    ),
  ];

  test('IDs de blocos são únicos por lição', () {
    final first = service.buildBlockRowsForLesson(
      lessonId: 'les-1',
      blocks: blocks,
    );
    final second = service.buildBlockRowsForLesson(
      lessonId: 'les-2',
      blocks: blocks,
    );

    expect(first.map((row) => row['id']).toSet().length, blocks.length);
    expect(second.map((row) => row['id']).toSet().length, blocks.length);
    expect(
      first.map((row) => row['id']).toSet().intersection(
            second.map((row) => row['id']).toSet(),
          ),
      isEmpty,
    );
  });

  test('IDs permanecem estáveis ao salvar novamente', () {
    final first = service.buildBlockRowsForLesson(
      lessonId: 'les-1',
      blocks: blocks,
    );
    final savedBlocks = [
      for (final row in first)
        LessonBlockModel(
          id: row['id']! as String,
          type: LessonBlockType.values.byName(row['type']! as String),
        ),
    ];
    final second = service.buildBlockRowsForLesson(
      lessonId: 'les-1',
      blocks: savedBlocks,
    );

    expect(
      second.map((row) => row['id']).toList(),
      first.map((row) => row['id']).toList(),
    );
  });

  test('falha de publicação preserva lição e blocos como rascunho', () async {
    final operations = <String>[];

    final result = await service.runCreateLessonWorkflow(
      lessonId: 'les-1',
      requestedStatus: 'published',
      insertDraft: () async => operations.add('insert'),
      saveBlocks: () async => operations.add('blocks'),
      publishCategory: () async {
        operations.add('publish-category');
        throw Exception('falha de publicação');
      },
      publishLesson: () async => operations.add('publish-lesson'),
      cleanupIncompleteDraft: () async {
        operations.add('cleanup');
        return true;
      },
    );

    expect(result.isDraftPreserved, isTrue);
    expect(result.lessonId, 'les-1');
    expect(result.savedStatus, 'draft');
    expect(
      operations,
      ['insert', 'blocks', 'publish-category'],
    );
  });

  test('falha de insert nunca exclui uma lição homônima', () async {
    var cleanupCalled = false;

    final result = await service.runCreateLessonWorkflow(
      lessonId: 'les-1',
      requestedStatus: 'draft',
      insertDraft: () async => throw Exception('id duplicado'),
      saveBlocks: () async {},
      publishCategory: () async {},
      publishLesson: () async {},
      cleanupIncompleteDraft: () async {
        cleanupCalled = true;
        return true;
      },
    );

    expect(result.canCloseEditor, isFalse);
    expect(cleanupCalled, isFalse);
  });

  test('falha ao gravar blocos limpa apenas o rascunho incompleto', () async {
    var cleanupCalled = false;

    final result = await service.runCreateLessonWorkflow(
      lessonId: 'les-1',
      requestedStatus: 'draft',
      insertDraft: () async {},
      saveBlocks: () async => throw Exception('blocos inválidos'),
      publishCategory: () async {},
      publishLesson: () async {},
      cleanupIncompleteDraft: () async {
        cleanupCalled = true;
        return true;
      },
    );

    expect(result.canCloseEditor, isFalse);
    expect(cleanupCalled, isTrue);
  });
}
