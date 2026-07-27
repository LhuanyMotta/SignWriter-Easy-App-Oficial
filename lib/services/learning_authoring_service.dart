import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson_block_model.dart';

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
      await _supabase.from('lesson_categories').update({
        'title_pt': title,
        'description_pt': description,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', categoryId);
      return true;
    } on PostgrestException catch (error, stack) {
      debugPrint('updateCategory: $error\n$stack');
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      final lessons = await _supabase
          .from('lessons')
          .select('id')
          .eq('category_id', categoryId);

      for (final row in lessons) {
        final lessonId = row['id']?.toString();
        if (lessonId == null || lessonId.isEmpty) continue;
        await deleteLesson(lessonId);
      }

      await _supabase.from('lesson_categories').delete().eq('id', categoryId);
      return true;
    } on PostgrestException catch (error, stack) {
      debugPrint('deleteCategory: $error\n$stack');
      return false;
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    try {
      await _supabase.from('lesson_exercises').delete().eq('lesson_id', lessonId);
      await _supabase.from('lesson_blocks').delete().eq('lesson_id', lessonId);
      await _supabase.from('lesson_sources').delete().eq('lesson_id', lessonId);
      await _supabase.from('lesson_media').delete().eq('lesson_id', lessonId);
      await _supabase.from('lessons').delete().eq('id', lessonId);
      return true;
    } on PostgrestException catch (error, stack) {
      debugPrint('deleteLesson: $error\n$stack');
      return false;
    }
  }

  Future<String?> createLesson({
    required String categoryId,
    required String title,
    required String summary,
    required String body,
    String status = 'draft',
    List<String> objectives = const [],
    List<LessonBlockModel> blocks = const [],
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final lessonId =
        'les-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 6)}';

    try {
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
        'status': status,
        'created_by': user.id,
        'objectives_pt': objectives,
        'objectives_en': objectives,
        'references_pt': <String>[],
        'related_sign_ids': <String>[],
      });

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

      await _replaceBlocks(lessonId: lessonId, blocks: effectiveBlocks);
      if (status == 'published') {
        await _publishCategory(categoryId);
      }
      return lessonId;
    } on PostgrestException catch (error, stack) {
      debugPrint('createLesson: $error\n$stack');
      return null;
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
      await _supabase.from('lessons').update({
        'title_pt': title,
        'summary_pt': summary,
        'status': status,
        'objectives_pt': objectives,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        if (status == 'published')
          'published_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', lessonId);

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

      await _replaceBlocks(lessonId: lessonId, blocks: effectiveBlocks);
      if (status == 'published') {
        await _publishCategory(categoryId);
      }
      return true;
    } on PostgrestException catch (error, stack) {
      debugPrint('updateLesson: $error\n$stack');
      return false;
    }
  }

  Future<void> _publishCategory(String categoryId) async {
    if (categoryId.isEmpty) return;
    try {
      await _supabase.from('lesson_categories').update({
        'status': 'published',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', categoryId);
    } on PostgrestException catch (error, stack) {
      debugPrint('_publishCategory: $error\n$stack');
    }
  }

  Future<void> _replaceBlocks({
    required String lessonId,
    required List<LessonBlockModel> blocks,
  }) async {
    await _supabase.from('lesson_blocks').delete().eq('lesson_id', lessonId);

    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final typeName = block.type == LessonBlockType.unknown
          ? 'text'
          : block.type.name;
      rows.add({
        'id': block.id.isNotEmpty ? block.id : '$lessonId-block-$i',
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

    if (rows.isNotEmpty) {
      await _supabase.from('lesson_blocks').insert(rows);
    }
  }
}
