import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/written_sign_model.dart';

/// Persistência de sinais autorais em `written_signs` (RLS por proprietário).
class WrittenSignsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static final List<WrittenSignModel> _localSigns = [];

  Future<List<WrittenSignModel>> getWrittenSigns() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('written_signs')
          .select()
          .eq('user_id', user.id)
          .order('updated_at', ascending: false);

      return response
          .map<WrittenSignModel>(
            (item) => WrittenSignModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on PostgrestException catch (error, stack) {
      debugPrint('getWrittenSigns remoto falhou, usando local: $error\n$stack');
      return _localForUser(user.id);
    } catch (error, stack) {
      debugPrint('getWrittenSigns erro: $error\n$stack');
      return _localForUser(user.id);
    }
  }

  Future<void> saveWrittenSign(WrittenSignModel sign) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final localSign = sign.copyWith(userId: user.id);
    final index = _localSigns.indexWhere((item) => item.id == localSign.id);
    if (index >= 0) {
      _localSigns[index] = localSign;
    } else {
      _localSigns.add(localSign);
    }

    final payload = _toRemotePayload(localSign);
    try {
      await _supabase.from('written_signs').upsert(payload);
    } on PostgrestException catch (error, stack) {
      debugPrint('saveWrittenSign RLS/erro (mantido local): $error\n$stack');
    }
  }

  Future<void> deleteWrittenSign(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    _localSigns.removeWhere((sign) => sign.id == id && sign.userId == user.id);

    try {
      await _supabase
          .from('written_signs')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } on PostgrestException catch (error, stack) {
      debugPrint('deleteWrittenSign: $error\n$stack');
    }
  }

  List<WrittenSignModel> _localForUser(String userId) {
    return _localSigns.where((sign) => sign.userId == userId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Map<String, dynamic> _toRemotePayload(WrittenSignModel sign) {
    return {
      'id': sign.id,
      'user_id': sign.userId,
      'title': sign.title,
      'gloss_pt': sign.glossPt,
      'description': sign.description,
      'category': sign.category,
      'tags': sign.tags,
      'fsw': sign.fsw,
      'swu': sign.swu,
      'layout_json': sign.layoutJson,
      'preview_png_base64': sign.previewPngBase64,
      'status': sign.status,
      'created_at': sign.createdAt.toIso8601String(),
      'updated_at': sign.updatedAt.toIso8601String(),
      'published_at': sign.publishedAt?.toIso8601String(),
    };
  }
}
