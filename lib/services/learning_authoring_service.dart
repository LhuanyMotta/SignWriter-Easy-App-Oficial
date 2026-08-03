import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson_block_model.dart';
import '../models/lesson_save_result.dart';

/// CRUD editorial sobre o CMS (`lesson_blocks`). Escrita sujeita a RLS/`user_roles`.
class LearningAuthoringService {
  LearningAuthoringService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  bool get isAuthenticated => _supabase.auth.currentUser != null;

  Future<List<Map<String, dynamic>>> listMyDrafts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const [];

    try {
      final rows = await _supabase
          .from('lessons')
          .select()
          .eq('created_by', user.id)
          .order('updated_at', ascending: false);
      return rows
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on PostgrestException catch (error, stack) {
      debugPrint('listMyDrafts: $error\n$stack');
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> listCategories() async {
    try {
      final rows = await _supabase
          .from('lesson_categories')
          .select('id, title_pt, order_index, status')
          .order('order_index');
      return rows
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on PostgrestException catch (error, stack) {
      debugPrint('listCategories: $error\n$stack');
      return const [];
    }
  }

  Future<String?> createCategory({
    required String title,
    required String description,
    String icon = 'school',
    String color = '#2D78BB',
    int orderIndex = 999,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final categoryId =
        'cat-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 6)}';

    try {
      await _supabase.from('lesson_categories').insert({
        'id': categoryId,
        'title_pt': title,
        'title_en': title,
        'description_pt': description,
        'description_en': description,
        'icon': icon,
        'color': color,
        'order_index': orderIndex,
        'status': 'draft',
        'created_by': user.id,
      });
      return categoryId;
    } on PostgrestException catch (error, stack) {
      debugPrint('createCategory RLS/erro: $error\n$stack');
      return null;
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    required String title,
    required String description,
  }) async {
    try {
      final updated = await _supabase
          .from('lesson_categories')
          .update({
            'title_pt': title,
            'description_pt': description,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', categoryId)
          .select('id')
          .maybeSingle();
      return updated != null;
    } catch (error, stack) {
      debugPrint('updateCategory: $error\n$stack');
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      // As relações internas usam ON DELETE CASCADE. O banco executa a
      // exclusão completa em uma única transação.
      final deleted = await _supabase
          .from('lesson_categories')
          .delete()
          .eq('id', categoryId)
          .select('id')
          .maybeSingle();
      return deleted != null;
    } catch (error, stack) {
      debugPrint('deleteCategory: $error\n$stack');
      return false;
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    try {
      final deleted = await _supabase
          .from('lessons')
          .delete()
          .eq('id', lessonId)
          .select('id')
          .maybeSingle();
      return deleted != null;
    } catch (error, stack) {
      debugPrint('deleteLesson: $error\n$stack');
      return false;
    }
  }

  Future<LessonSaveResult> createLesson({
    required String categoryId,
    required String title,
    required String summary,
    required String body,
    String status = 'draft',
    List<String> objectives = const [],
    List<LessonBlockModel> blocks = const [],
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const LessonSaveResult.failed();

    final lessonId =
        'les-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 6)}';
    final effectiveBlocks = blocks.isNotEmpty
        ? blocks
        : [
            LessonBlockModel(
              id: '$lessonId-heading',
              lessonId: lessonId,
              type: LessonBlockType.heading,
              title: 'Conteúdo',
              orderIndex: 0,
            ),
            LessonBlockModel(
              id: '$lessonId-text',
              lessonId: lessonId,
              type: LessonBlockType.text,
              body: body,
              orderIndex: 1,
            ),
          ];

    return runCreateLessonWorkflow(
      lessonId: lessonId,
      requestedStatus: status,
      insertDraft: () async {
        // Toda nova lição nasce como rascunho. A publicação só acontece
        // depois que seus blocos foram persistidos com sucesso.
        await _supabase.from('lessons').insert({
          'id': lessonId,
          'category_id': categoryId,
          'title_pt': title,
          'title_en': title,
          'summary_pt': summary,
          'summary_en': summary,
          'estimated_minutes': 5,
          'difficulty_pt': 'Iniciante',
          'difficulty_en': 'Beginner',
          'order_index': 999,
          'status': 'draft',
          'created_by': user.id,
          'objectives_pt': objectives,
          'objectives_en': objectives,
          'references_pt': <String>[],
          'related_sign_ids': <String>[],
        });
      },
      saveBlocks: () =>
          _saveBlocksSafely(lessonId: lessonId, blocks: effectiveBlocks),
      publishCategory: () => _publishCategory(categoryId),
      publishLesson: () async {
        final published = await _supabase
            .from('lessons')
            .update({
              'status': 'published',
              'published_at': DateTime.now().toUtc().toIso8601String(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', lessonId)
            .select('id')
            .maybeSingle();
        if (published == null) {
          throw StateError(
              'A publicação da lição não alterou nenhum registro.');
        }
      },
      cleanupIncompleteDraft: () => deleteLesson(lessonId),
    );
  }

  @visibleForTesting
  Future<LessonSaveResult> runCreateLessonWorkflow({
    required String lessonId,
    required String requestedStatus,
    required Future<void> Function() insertDraft,
    required Future<void> Function() saveBlocks,
    required Future<void> Function() publishCategory,
    required Future<void> Function() publishLesson,
    required Future<bool> Function() cleanupIncompleteDraft,
  }) async {
    var draftInserted = false;
    var blocksSaved = false;

    try {
      await insertDraft();
      draftInserted = true;
      await saveBlocks();
      blocksSaved = true;

      if (requestedStatus == 'published') {
        try {
          await publishCategory();
          await publishLesson();
        } catch (error, stack) {
          // O conteúdo completo continua disponível ao autor como rascunho.
          debugPrint('createLesson publicação: $error\n$stack');
          return LessonSaveResult.draftPreserved(lessonId: lessonId);
        }
      }

      return LessonSaveResult.saved(
        lessonId: lessonId,
        status: requestedStatus,
      );
    } catch (error, stack) {
      debugPrint('createLesson: $error\n$stack');
      // Só compensa uma inserção confirmada que ainda não possui todos os
      // blocos. Uma falha de INSERT nunca pode apagar uma lição homônima.
      if (draftInserted && !blocksSaved) {
        try {
          final cleaned = await cleanupIncompleteDraft();
          if (!cleaned) {
            debugPrint('createLesson: não foi possível limpar $lessonId');
          }
        } catch (cleanupError, cleanupStack) {
          debugPrint(
            'createLesson limpeza: $cleanupError\n$cleanupStack',
          );
        }
      }
      return const LessonSaveResult.failed();
    }
  }

  Future<bool> updateLesson({
    required String lessonId,
    required String categoryId,
    required String title,
    required String summary,
    required String body,
    required String status,
    List<String> objectives = const [],
    List<LessonBlockModel> blocks = const [],
  }) async {
    try {
      final effectiveBlocks = blocks.isNotEmpty
          ? blocks
          : [
              LessonBlockModel(
                id: '$lessonId-text',
                lessonId: lessonId,
                type: LessonBlockType.text,
                body: body,
                orderIndex: 0,
              ),
            ];

      // Grava os novos blocos antes de mudar o status da lição. Uma falha
      // preserva os blocos anteriores e não publica conteúdo incompleto.
      await _saveBlocksSafely(lessonId: lessonId, blocks: effectiveBlocks);
      if (status == 'published') {
        await _publishCategory(categoryId);
      }

      final updated = await _supabase
          .from('lessons')
          .update({
            'title_pt': title,
            'summary_pt': summary,
            'status': status,
            'objectives_pt': objectives,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            if (status == 'published')
              'published_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', lessonId)
          .select('id')
          .maybeSingle();
      return updated != null;
    } catch (error, stack) {
      debugPrint('updateLesson: $error\n$stack');
      return false;
    }
  }

  Future<void> _publishCategory(String categoryId) async {
    if (categoryId.isEmpty) return;
    final published = await _supabase
        .from('lesson_categories')
        .update({
          'status': 'published',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', categoryId)
        .select('id')
        .maybeSingle();
    if (published == null) {
      throw StateError('A publicação do módulo não alterou nenhum registro.');
    }
  }

  Future<void> _saveBlocksSafely({
    required String lessonId,
    required List<LessonBlockModel> blocks,
  }) async {
    final existingRows = await _supabase
        .from('lesson_blocks')
        .select('id')
        .eq('lesson_id', lessonId);
    final existingIds = existingRows
        .map((row) => row['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final rows = buildBlockRowsForLesson(lessonId: lessonId, blocks: blocks);
    final desiredIds = rows.map((row) => row['id']!.toString()).toSet();

    // O upsert em lote é uma única instrução no Postgres. Se falhar, os
    // blocos existentes continuam disponíveis.
    if (rows.isNotEmpty) {
      await _supabase.from('lesson_blocks').upsert(rows);
    }

    // Só remove blocos antigos depois que todos os novos foram gravados.
    for (final obsoleteId in existingIds.difference(desiredIds)) {
      final deleted = await _supabase
          .from('lesson_blocks')
          .delete()
          .eq('lesson_id', lessonId)
          .eq('id', obsoleteId)
          .select('id')
          .maybeSingle();
      if (deleted == null) {
        throw StateError('O bloco $obsoleteId não pôde ser removido.');
      }
    }
  }

  @visibleForTesting
  List<Map<String, dynamic>> buildBlockRowsForLesson({
    required String lessonId,
    required List<LessonBlockModel> blocks,
  }) {
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final typeName =
          block.type == LessonBlockType.unknown ? 'text' : block.type.name;
      final originalId = block.id.trim();
      final blockId = originalId.isEmpty
          ? '$lessonId-block-$i'
          : originalId.startsWith('$lessonId-')
              ? originalId
              : '$lessonId-$originalId';
      rows.add({
        'id': blockId,
        'lesson_id': lessonId,
        'type': typeName,
        'title_pt': block.title,
        'title_en': block.title,
        'body_pt': block.body,
        'body_en': block.body,
        'bullets_pt': block.bullets,
        'bullets_en': block.bullets,
        'caption_pt': block.caption,
        'caption_en': block.caption,
        'media_id': block.mediaId,
        'media_url': block.mediaUrl,
        'media_asset': block.mediaAsset,
        'fsw': block.fsw,
        'swu': block.swu,
        'payload': block.payload,
        'order_index': block.orderIndex != 0 ? block.orderIndex : i,
      });
    }
    return rows;
  }
}
