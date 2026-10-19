import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Cache persistente das imagens do conteúdo pedagógico.
///
/// O arquivo é guardado no diretório de suporte do aplicativo, portanto
/// continua disponível depois de fechar o app ou reiniciar o celular.
class LearningImageCache {
  factory LearningImageCache() => _instance;

  LearningImageCache._() : _directory = null;

  @visibleForTesting
  LearningImageCache.forTesting({required Directory directory})
      : _directory = directory;

  final Directory? _directory;
  static const _maxImageBytes = 12 * 1024 * 1024;

  static final LearningImageCache _instance = LearningImageCache._();
  final Map<String, Future<String?>> _inFlight = {};

  Future<String?> resolve(String url) {
    final normalized = url.trim();
    if (normalized.isEmpty) return Future.value(null);
    return _inFlight.putIfAbsent(normalized, () async {
      try {
        return await _resolve(normalized);
      } catch (error, stack) {
        debugPrint('Falha ao armazenar imagem offline: $error\n$stack');
        return null;
      } finally {
        _inFlight.remove(normalized);
      }
    });
  }

  Future<void> prefetchAll(Iterable<String> urls) async {
    final unique = urls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList(growable: false);

    // Limita a concorrência para não sobrecarregar celulares mais simples.
    const batchSize = 4;
    for (var start = 0; start < unique.length; start += batchSize) {
      final end =
          start + batchSize < unique.length ? start + batchSize : unique.length;
      await Future.wait(unique.sublist(start, end).map(resolve));
    }
  }

  Future<String?> _resolve(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    final supportDirectory = _directory ?? await getApplicationSupportDirectory();
    final directory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}learning-images',
    );
    await directory.create(recursive: true);

    final file = File(
      '${directory.path}${Platform.pathSeparator}${_stableKey(url)}.cache',
    );
    if (await _isUsable(file)) return file.path;

    final temporary = File('${file.path}.download');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response = await request.close().timeout(
            const Duration(seconds: 15),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final contentType = response.headers.contentType?.mimeType ?? '';
      if ((contentType.isNotEmpty &&
              !contentType.startsWith('image/') &&
              contentType != 'application/octet-stream') ||
          response.contentLength > _maxImageBytes) {
        return null;
      }
      final sink = temporary.openWrite();
      var received = 0;
      try {
        await for (final chunk in response.timeout(const Duration(seconds: 20))) {
          received += chunk.length;
          if (received > _maxImageBytes) {
            throw StateError('Imagem excede o limite do cache.');
          }
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }
      if (!await _isUsable(temporary)) {
        if (await temporary.exists()) await temporary.delete();
        return null;
      }

      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
      return file.path;
    } on TimeoutException {
      return await _isUsable(file) ? file.path : null;
    } finally {
      client.close(force: true);
      if (await temporary.exists()) {
        try {
          await temporary.delete();
        } catch (_) {
          // Outro resolve concorrente pode ter concluído o rename.
        }
      }
    }
  }

  Future<bool> _isUsable(File file) async {
    return await file.exists() && await file.length() > 0;
  }

  String _stableKey(String value) {
    var first = 0x811c9dc5;
    var second = 0x9747b28c;
    for (final codeUnit in value.codeUnits) {
      first = ((first ^ codeUnit) * 0x01000193) & 0xffffffff;
      second = ((second * 33) ^ codeUnit) & 0xffffffff;
    }
    return '${first.toRadixString(16)}_${second.toRadixString(16)}';
  }
}
