import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson_block_model.dart';
import '../models/lesson_section_model.dart';

/// CRUD editorial mínimo. No-op seguro se RLS/tabelas não estiverem prontas.
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
    } catch (_) {
      try {
        final rows = await _supabase
            .from('lessons')
            .select()
            .inFilter('status', ['draft', 'published'])
            .order('order_index');
        return rows
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } catch (_) {
        return const [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> listCategories() async {
    try {
      final rows = await _supabase
          .from('lesson_categories')
          .select('id, title_pt, title, order_index')
          .order('order_index');
      return rows
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Cria módulo (categoria). Retorna id ou null se write falhar.
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
        'description_pt': description,
        'icon': icon,
        'color': color,
        'order_index': orderIndex,
      });
      return categoryId;
    } catch (_) {
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
      }).eq('id', categoryId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Remove módulo e conteúdo filho (lições/seções/exercícios) quando possível.
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
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    try {
      try {
        await _supabase
            .from('lesson_exercises')
            .delete()
            .eq('lesson_id', lessonId);
      } catch (_) {}
      try {
        await _supabase
            .from('lesson_sections')
            .delete()
            .eq('lesson_id', lessonId);
      } catch (_) {}
      await _supabase.from('lessons').delete().eq('id', lessonId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cria lição + seções a partir dos blocos editados.
  Future<String?> createLesson({
    required String categoryId,
    required String title,
    required String summary,
    required String body,
    String status = 'draft',
    List<String> objectives = const [],
    List<LessonSectionModel> sections = const [],
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
        'summary_pt': summary,
        'estimated_minutes': 5,
        'difficulty_pt': 'Iniciante',
        'order_index': 999,
        'status': status,
        'created_by': user.id,
        'objectives_pt': objectives,
        'references_pt': <String>[],
        'related_sign_ids': <String>[],
      });

      await _replaceSections(
        lessonId: lessonId,
        sections: sections.isNotEmpty
            ? sections
            : [
                LessonSectionModel(title: 'Conteúdo', body: body),
              ],
      );

      return lessonId;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateLesson({
    required String lessonId,
    required String title,
    required String summary,
    required String body,
    required String status,
    List<String> objectives = const [],
    List<LessonSectionModel> sections = const [],
  }) async {
    try {
      await _supabase.from('lessons').update({
        'title_pt': title,
        'summary_pt': summary,
        'status': status,
        'objectives_pt': objectives,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', lessonId);

      await _replaceSections(
        lessonId: lessonId,
        sections: sections.isNotEmpty
            ? sections
            : [
                LessonSectionModel(title: 'Conteúdo', body: body),
              ],
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _replaceSections({
    required String lessonId,
    required List<LessonSectionModel> sections,
  }) async {
    try {
      await _supabase.from('lesson_sections').delete().eq('lesson_id', lessonId);
    } catch (_) {}

    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      await _supabase.from('lesson_sections').insert({
        'lesson_id': lessonId,
        'title_pt': section.title,
        'body_pt': section.body,
        'bullets_pt': section.bullets,
        'highlight_pt': section.highlight,
        'order_index': i + 1,
      });
    }
  }

  /// Agrupa blocos visuais em seções para gravar no Supabase.
  static List<LessonSectionModel> sectionsFromBlocks(
    List<LessonBlockModel> blocks,
  ) {
    final sections = <LessonSectionModel>[];
    String title = '';
    String body = '';
    List<String> bullets = [];
    String? highlight;

    void flush() {
      if (title.trim().isEmpty &&
          body.trim().isEmpty &&
          bullets.isEmpty &&
          (highlight == null || highlight!.trim().isEmpty)) {
        return;
      }
      sections.add(
        LessonSectionModel(
          title: title,
          body: body,
          bullets: bullets,
          highlight: highlight,
        ),
      );
      title = '';
      body = '';
      bullets = [];
      highlight = null;
    }

    for (final block in blocks) {
      switch (block.type) {
        case LessonBlockType.heading:
          flush();
          title = block.title;
          break;
        case LessonBlockType.text:
          body = body.isEmpty ? block.body : '$body\n\n${block.body}';
          break;
        case LessonBlockType.bullets:
          bullets = [...bullets, ...block.bullets];
          break;
        case LessonBlockType.highlight:
          highlight = block.body;
          break;
        case LessonBlockType.image:
        case LessonBlockType.signwriting:
        case LessonBlockType.comparison:
          break;
      }
    }
    flush();
    return sections;
  }
}
