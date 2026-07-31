import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/written_sign_model.dart';
import 'written_sign_preview_policy.dart';

/// Erros de regra de negócio / persistência de sinais autorais.
class WrittenSignsException implements Exception {
  final String message;
  const WrittenSignsException(this.message);

  @override
  String toString() => message;
}

/// Abstração remota para permitir testes sem PostgREST real.
abstract class WrittenSignsRemoteStore {
  User? get currentUser;

  Future<List<Map<String, dynamic>>> fetchForUser(String userId);

  Future<Map<String, dynamic>> insert(Map<String, dynamic> row);

  Future<Map<String, dynamic>?> update({
    required String id,
    required String userId,
    required Map<String, dynamic> row,
  });

  Future<List<Map<String, dynamic>>> delete({
    required String id,
    required String userId,
  });
}

class _SupabaseWrittenSignsRemoteStore implements WrittenSignsRemoteStore {
  _SupabaseWrittenSignsRemoteStore(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<List<Map<String, dynamic>>> fetchForUser(String userId) async {
    final response = await _client
        .from('written_signs')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> row) async {
    final response =
        await _client.from('written_signs').insert(row).select().single();
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Map<String, dynamic>?> update({
    required String id,
    required String userId,
    required Map<String, dynamic> row,
  }) async {
    final response = await _client
        .from('written_signs')
        .update(row)
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .maybeSingle();
    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> delete({
    required String id,
    required String userId,
  }) async {
    final response = await _client
        .from('written_signs')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .select();
    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}

/// Persistência de sinais autorais em `written_signs` (RLS por proprietário).
class WrittenSignsService {
  WrittenSignsService({
    SupabaseClient? supabase,
    WrittenSignsRemoteStore? store,
    DateTime Function()? clock,
  })  : _store = store ??
            _SupabaseWrittenSignsRemoteStore(
              supabase ?? Supabase.instance.client,
            ),
        _clock = clock ?? (() => DateTime.now().toUtc());

  final WrittenSignsRemoteStore _store;
  final DateTime Function() _clock;

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}$',
  );

  static bool isValidUuid(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _uuidRegex.hasMatch(value.trim());
  }

  User _requireUser() {
    final user = _store.currentUser;
    if (user == null) {
      throw const WrittenSignsException('Usuário não autenticado');
    }
    return user;
  }

  Future<List<WrittenSignModel>> getWrittenSigns() async {
    final user = _requireUser();
    final rows = await _store.fetchForUser(user.id);
    return rows.map(WrittenSignModel.fromMap).toList();
  }

  Future<WrittenSignModel> createWrittenSign(WrittenSignModel sign) async {
    final user = _requireUser();
    if (sign.id.trim().isNotEmpty) {
      throw const WrittenSignsException(
        'Criação exige id vazio; id preenchido não pode ser usado em create.',
      );
    }

    final preview = WrittenSignPreviewPolicy.normalizeAndValidate(
      sign.previewPngBase64,
    );
    final payload = buildCreatePayload(
      sign: sign,
      authenticatedUserId: user.id,
      previewPngBase64: preview,
    );
    final row = await _store.insert(payload);
    return WrittenSignModel.fromMap(row);
  }

  Future<WrittenSignModel> updateWrittenSign(WrittenSignModel sign) async {
    final user = _requireUser();
    if (!isValidUuid(sign.id)) {
      throw const WrittenSignsException(
        'Atualização exige um UUID válido; id inválido não cria nova linha.',
      );
    }

    final preview = WrittenSignPreviewPolicy.normalizeAndValidate(
      sign.previewPngBase64,
    );
    final payload = buildUpdatePayload(
      sign: sign,
      previewPngBase64: preview,
      updatedAtUtc: _clock(),
    );
    final row = await _store.update(
      id: sign.id,
      userId: user.id,
      row: payload,
    );
    if (row == null) {
      throw const WrittenSignsException(
        'Sinal não encontrado ou sem permissão para editar.',
      );
    }
    return WrittenSignModel.fromMap(row);
  }

  /// Fachada: id vazio → create; UUID válido → update; id inválido → erro.
  Future<WrittenSignModel> saveWrittenSign(WrittenSignModel sign) async {
    if (sign.id.trim().isEmpty) {
      return createWrittenSign(sign);
    }
    if (isValidUuid(sign.id)) {
      return updateWrittenSign(sign);
    }
    throw const WrittenSignsException(
      'Id do sinal inválido. Não é possível salvar sem UUID válido.',
    );
  }

  Future<void> deleteWrittenSign(String id) async {
    final user = _requireUser();
    if (!isValidUuid(id)) {
      throw const WrittenSignsException(
        'Exclusão exige um UUID válido.',
      );
    }

    final deleted = await _store.delete(id: id, userId: user.id);
    if (deleted.length != 1) {
      throw const WrittenSignsException(
        'Sinal não encontrado ou sem permissão para excluir.',
      );
    }
  }

  /// Payload de insert: sem id/created_at/updated_at; user_id = auth.
  static Map<String, dynamic> buildCreatePayload({
    required WrittenSignModel sign,
    required String authenticatedUserId,
    required String? previewPngBase64,
  }) {
    final payload = <String, dynamic>{
      'user_id': authenticatedUserId,
      'title': sign.title,
      'gloss_pt': sign.glossPt,
      'description': sign.description,
      'category': sign.category,
      'tags': List<String>.from(sign.tags),
      'fsw': sign.fsw,
      'swu': sign.swu,
      'layout_json': sign.layoutJson,
      'preview_png_base64': previewPngBase64,
      'status': sign.status,
    };
    if (sign.publishedAt != null) {
      payload['published_at'] = sign.publishedAt!.toUtc().toIso8601String();
    }
    return payload;
  }

  /// Payload de update: não altera created_at nem user_id.
  static Map<String, dynamic> buildUpdatePayload({
    required WrittenSignModel sign,
    required String? previewPngBase64,
    required DateTime updatedAtUtc,
  }) {
    return <String, dynamic>{
      'title': sign.title,
      'gloss_pt': sign.glossPt,
      'description': sign.description,
      'category': sign.category,
      'tags': List<String>.from(sign.tags),
      'fsw': sign.fsw,
      'swu': sign.swu,
      'layout_json': sign.layoutJson,
      'preview_png_base64': previewPngBase64,
      'status': sign.status,
      'updated_at': updatedAtUtc.toUtc().toIso8601String(),
      'published_at': sign.publishedAt?.toUtc().toIso8601String(),
    };
  }
}
