import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/models/written_sign_model.dart';
import 'package:signwriter_easy_app_oficial/services/written_sign_preview_policy.dart';
import 'package:signwriter_easy_app_oficial/services/written_signs_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// PNG 1×1 válido (IHDR).
final Uint8List _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

/// PNG com IHDR forçado para 600×600 (assinatura + IHDR, resto irrelevante para o parser).
Uint8List _pngWithSize(int width, int height) {
  final bytes = Uint8List.fromList(_tinyPng);
  bytes[16] = (width >> 24) & 0xff;
  bytes[17] = (width >> 16) & 0xff;
  bytes[18] = (width >> 8) & 0xff;
  bytes[19] = width & 0xff;
  bytes[20] = (height >> 24) & 0xff;
  bytes[21] = (height >> 16) & 0xff;
  bytes[22] = (height >> 8) & 0xff;
  bytes[23] = height & 0xff;
  return bytes;
}

class _FakeUser extends User {
  _FakeUser(String id)
      : super(
          id: id,
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.utc(2024, 1, 1).toIso8601String(),
        );
}

class FakeWrittenSignsRemoteStore implements WrittenSignsRemoteStore {
  FakeWrittenSignsRemoteStore({this.userId});

  String? userId;
  final Map<String, Map<String, dynamic>> rows = {};
  Object? nextError;
  int insertCount = 0;

  @override
  User? get currentUser => userId == null ? null : _FakeUser(userId!);

  void _throwIfNeeded() {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchForUser(String uid) async {
    _throwIfNeeded();
    return rows.values
        .where((row) => row['user_id'] == uid)
        .map((row) => Map<String, dynamic>.from(row))
        .toList()
      ..sort(
        (a, b) => (b['updated_at'] as String)
            .compareTo(a['updated_at'] as String),
      );
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> row) async {
    _throwIfNeeded();
    insertCount++;
    final id =
        '11111111-1111-4111-8111-${insertCount.toString().padLeft(12, '0')}';
    final now = DateTime.utc(2026, 7, 29, 12).toIso8601String();
    final saved = {
      ...row,
      'id': id,
      'created_at': now,
      'updated_at': now,
    };
    rows[id] = saved;
    return Map<String, dynamic>.from(saved);
  }

  @override
  Future<Map<String, dynamic>?> update({
    required String id,
    required String userId,
    required Map<String, dynamic> row,
  }) async {
    _throwIfNeeded();
    final existing = rows[id];
    if (existing == null || existing['user_id'] != userId) return null;
    final merged = {
      ...existing,
      ...row,
      'id': id,
      'user_id': existing['user_id'],
      'created_at': existing['created_at'],
    };
    rows[id] = merged;
    return Map<String, dynamic>.from(merged);
  }

  @override
  Future<List<Map<String, dynamic>>> delete({
    required String id,
    required String userId,
  }) async {
    _throwIfNeeded();
    final existing = rows[id];
    if (existing == null || existing['user_id'] != userId) return [];
    rows.remove(id);
    return [Map<String, dynamic>.from(existing)];
  }
}

WrittenSignModel _draftSign({
  String id = '',
  String userId = 'attacker-id',
  String status = WrittenSignModel.statusDraft,
  DateTime? createdAt,
  DateTime? publishedAt,
  String? previewPngBase64,
  List<String> tags = const ['ola', 'teste'],
}) {
  final now = DateTime.utc(2026, 7, 28);
  return WrittenSignModel(
    id: id,
    userId: userId,
    title: 'Olá',
    glossPt: 'OLA',
    category: 'Cumprimentos',
    tags: tags,
    fsw: 'M500x500S10011500x500',
    swu: 'x',
    previewPngBase64: previewPngBase64 ?? base64Encode(_tinyPng),
    status: status,
    createdAt: createdAt ?? now,
    updatedAt: now,
    publishedAt: publishedAt,
  );
}

void main() {
  late FakeWrittenSignsRemoteStore store;
  late WrittenSignsService service;
  final fixedClock = DateTime.utc(2026, 7, 29, 18, 30);

  setUp(() {
    store = FakeWrittenSignsRemoteStore(userId: 'user-a');
    service = WrittenSignsService(
      store: store,
      clock: () => fixedClock,
    );
  });

  group('UUID / fachada save', () {
    test('isValidUuid aceita UUID e rejeita epoch', () {
      expect(
        WrittenSignsService.isValidUuid(
          '550e8400-e29b-41d4-a716-446655440000',
        ),
        isTrue,
      );
      expect(WrittenSignsService.isValidUuid('1722190000000'), isFalse);
      expect(WrittenSignsService.isValidUuid(''), isFalse);
    });

    test('saveWrittenSign com id inválido não cria linha', () async {
      expect(
        () => service.saveWrittenSign(_draftSign(id: '1722190000000')),
        throwsA(isA<WrittenSignsException>()),
      );
      expect(store.insertCount, 0);
      expect(store.rows, isEmpty);
    });
  });

  group('auth', () {
    test('deslogado não consulta', () async {
      store.userId = null;
      expect(
        () => service.getWrittenSigns(),
        throwsA(isA<WrittenSignsException>()),
      );
    });

    test('deslogado não cria', () async {
      store.userId = null;
      expect(
        () => service.createWrittenSign(_draftSign()),
        throwsA(isA<WrittenSignsException>()),
      );
    });

    test('deslogado não edita', () async {
      store.userId = null;
      expect(
        () => service.updateWrittenSign(
          _draftSign(id: '550e8400-e29b-41d4-a716-446655440000'),
        ),
        throwsA(isA<WrittenSignsException>()),
      );
    });

    test('deslogado não exclui', () async {
      store.userId = null;
      expect(
        () => service.deleteWrittenSign(
          '550e8400-e29b-41d4-a716-446655440000',
        ),
        throwsA(isA<WrittenSignsException>()),
      );
    });
  });

  group('create', () {
    test('retorna UUID do banco e ignora user_id do model', () async {
      final saved = await service.createWrittenSign(
        _draftSign(userId: 'should-not-win'),
      );
      expect(WrittenSignsService.isValidUuid(saved.id), isTrue);
      expect(saved.userId, 'user-a');
      expect(store.rows[saved.id]?['user_id'], 'user-a');
      expect(store.rows[saved.id]?['tags'], isA<List>());
      expect(store.rows[saved.id]?['tags'], ['ola', 'teste']);
      expect(store.rows[saved.id]?.containsKey('id'), isTrue);
      // create payload não envia created_at/updated_at — fake adiciona
      expect(
        WrittenSignsService.buildCreatePayload(
          sign: _draftSign(),
          authenticatedUserId: 'user-a',
          previewPngBase64: base64Encode(_tinyPng),
        ).containsKey('created_at'),
        isFalse,
      );
    });

    test('create com id preenchido falha', () async {
      expect(
        () => service.createWrittenSign(
          _draftSign(id: '550e8400-e29b-41d4-a716-446655440000'),
        ),
        throwsA(isA<WrittenSignsException>()),
      );
      expect(store.insertCount, 0);
    });
  });

  group('update', () {
    test('preserva UUID, status, createdAt e publishedAt', () async {
      const id = '550e8400-e29b-41d4-a716-446655440000';
      final publishedAt = DateTime.utc(2026, 6, 1);
      final createdAt = DateTime.utc(2026, 5, 1);
      store.rows[id] = {
        'id': id,
        'user_id': 'user-a',
        'title': 'Antigo',
        'gloss_pt': 'ANTIGO',
        'description': null,
        'category': 'Geral',
        'tags': <String>[],
        'fsw': 'M500x500S10011500x500',
        'swu': '',
        'layout_json': '[]',
        'preview_png_base64': base64Encode(_tinyPng),
        'status': WrittenSignModel.statusPublished,
        'created_at': createdAt.toIso8601String(),
        'updated_at': createdAt.toIso8601String(),
        'published_at': publishedAt.toIso8601String(),
      };

      final updated = await service.updateWrittenSign(
        _draftSign(
          id: id,
          userId: 'attacker',
          status: WrittenSignModel.statusPublished,
          createdAt: createdAt,
          publishedAt: publishedAt,
        ).copyWith(title: 'Novo título'),
      );

      expect(updated.id, id);
      expect(updated.title, 'Novo título');
      expect(updated.status, WrittenSignModel.statusPublished);
      expect(updated.createdAt.toUtc(), createdAt);
      expect(updated.publishedAt?.toUtc(), publishedAt);
      expect(updated.userId, 'user-a');
      expect(store.insertCount, 0);
      expect(
        store.rows[id]?['updated_at'],
        fixedClock.toIso8601String(),
      );
    });

    test('atualização inexistente não vira insert', () async {
      expect(
        () => service.updateWrittenSign(
          _draftSign(id: '550e8400-e29b-41d4-a716-446655440099'),
        ),
        throwsA(
          isA<WrittenSignsException>().having(
            (e) => e.message,
            'message',
            contains('não encontrado'),
          ),
        ),
      );
      expect(store.insertCount, 0);
    });

    test('id inválido na update não cria linha', () async {
      expect(
        () => service.updateWrittenSign(_draftSign(id: 'not-a-uuid')),
        throwsA(isA<WrittenSignsException>()),
      );
      expect(store.insertCount, 0);
    });
  });

  group('delete', () {
    test('sucesso só com exatamente uma linha do usuário', () async {
      const id = '550e8400-e29b-41d4-a716-446655440000';
      store.rows[id] = {
        'id': id,
        'user_id': 'user-a',
        'title': 'X',
        'gloss_pt': 'X',
        'category': 'Geral',
        'tags': <String>[],
        'fsw': 'M500x500S10011500x500',
        'swu': '',
        'layout_json': '[]',
        'status': 'draft',
        'created_at': fixedClock.toIso8601String(),
        'updated_at': fixedClock.toIso8601String(),
      };

      await service.deleteWrittenSign(id);
      expect(store.rows.containsKey(id), isFalse);
    });

    test('exclusão de zero linhas não retorna sucesso', () async {
      expect(
        () => service.deleteWrittenSign(
          '550e8400-e29b-41d4-a716-446655440000',
        ),
        throwsA(isA<WrittenSignsException>()),
      );
    });
  });

  group('erros remotos e isolamento', () {
    test('falha PostgREST propaga erro', () async {
      store.nextError = const PostgrestException(
        message: 'boom',
        code: 'PGRST000',
      );
      expect(
        () => service.createWrittenSign(_draftSign()),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('dois usuários não leem/alteram sinais um do outro', () async {
      const id = '550e8400-e29b-41d4-a716-446655440000';
      store.rows[id] = {
        'id': id,
        'user_id': 'user-b',
        'title': 'Segredo',
        'gloss_pt': 'SEGREDO',
        'category': 'Geral',
        'tags': <String>[],
        'fsw': 'M500x500S10011500x500',
        'swu': '',
        'layout_json': '[]',
        'status': 'draft',
        'created_at': fixedClock.toIso8601String(),
        'updated_at': fixedClock.toIso8601String(),
      };

      final listed = await service.getWrittenSigns();
      expect(listed, isEmpty);

      expect(
        () => service.updateWrittenSign(_draftSign(id: id)),
        throwsA(isA<WrittenSignsException>()),
      );
      expect(
        () => service.deleteWrittenSign(id),
        throwsA(isA<WrittenSignsException>()),
      );
      expect(store.rows.containsKey(id), isTrue);
    });
  });

  group('preview policy', () {
    test('tags no payload remoto são List, não string JSON', () {
      final payload = WrittenSignsService.buildCreatePayload(
        sign: _draftSign(tags: const ['a', 'b']),
        authenticatedUserId: 'user-a',
        previewPngBase64: base64Encode(_tinyPng),
      );
      expect(payload['tags'], isA<List>());
      expect(payload['tags'], ['a', 'b']);
      expect(payload['tags'], isNot(isA<String>()));
    });

    test('preview acima do limite de tamanho é rejeitado', () {
      final huge = Uint8List(WrittenSignPreviewPolicy.maxDecodedBytes + 1);
      // assinatura PNG mínima para passar decode path até size check
      huge.setAll(0, _tinyPng);
      expect(
        () => WrittenSignPreviewPolicy.normalizeAndValidate(
          base64Encode(huge),
        ),
        throwsA(isA<WrittenSignPreviewException>()),
      );
    });

    test('preview acima de 512px é rejeitado', () {
      expect(
        () => WrittenSignPreviewPolicy.normalizeAndValidate(
          base64Encode(_pngWithSize(600, 600)),
        ),
        throwsA(isA<WrittenSignPreviewException>()),
      );
    });

    test('create rejeita preview grande', () async {
      final huge = Uint8List(WrittenSignPreviewPolicy.maxDecodedBytes + 10);
      huge.setAll(0, _tinyPng);
      expect(
        () => service.createWrittenSign(
          _draftSign(previewPngBase64: base64Encode(huge)),
        ),
        throwsA(isA<WrittenSignPreviewException>()),
      );
      expect(store.insertCount, 0);
    });

    test('remove prefixo data URL', () {
      final pure = WrittenSignPreviewPolicy.normalizeAndValidate(
        'data:image/png;base64,${base64Encode(_tinyPng)}',
      );
      expect(pure, base64Encode(_tinyPng));
    });
  });
}
