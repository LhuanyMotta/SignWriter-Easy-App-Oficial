import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/written_sign_model.dart';

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
    } catch (_) {
      final localUserSigns = _localSigns
          .where((sign) => sign.userId == user.id)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return localUserSigns;
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

    // Persistência remota temporariamente desativada.
    // Manter este bloco para reativação futura do salvamento no Supabase:
    //
    // final payload = sign.copyWith(userId: user.id).toMap();
    // await _supabase.from('written_signs').upsert(payload);
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
    } catch (_) {
      // Ignore enquanto a tabela remota não estiver disponível.
    }
  }
}
