import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/services/learning_image_cache_io.dart';

void main() {
  late Directory directory;
  late HttpServer server;
  late String url;
  var requests = 0;
  final png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aD1sAAAAASUVORK5CYII=');

  setUp(() async {
    requests = 0;
    directory = await Directory.systemTemp.createTemp('learning-cache-test-');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    url = 'http://127.0.0.1:${server.port}/image.png';
    server.listen((request) async {
      requests++;
      if (request.uri.path == '/missing') {
        request.response.statusCode = 404;
      } else if (request.uri.path == '/html') {
        request.response.headers.contentType = ContentType.html;
        request.response.write('<html>error</html>');
      } else {
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(png);
      }
      await request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    await directory.delete(recursive: true);
  });

  test('imagem continua disponível sem rede após recriar o cache', () async {
    final cache = LearningImageCache.forTesting(directory: directory);
    final path = await cache.resolve(url);
    expect(path, isNotNull);
    expect(await File(path!).readAsBytes(), png);
    await server.close(force: true);
    final reopened = LearningImageCache.forTesting(directory: directory);
    expect(await reopened.resolve(url), path);
    expect(requests, 1);
  });

  test('prefetch e exibição simultâneos não duplicam o download', () async {
    final cache = LearningImageCache.forTesting(directory: directory);
    final paths = await Future.wait([cache.resolve(url), cache.resolve(url)]);
    await cache.prefetchAll([url, url]);
    expect(paths[0], paths[1]);
    expect(paths[0], isNotNull);
    expect(requests, 1);
  });

  test('erro HTTP e HTML não criam uma imagem offline falsa', () async {
    final cache = LearningImageCache.forTesting(directory: directory);
    final origin = Uri.parse(url).origin;
    expect(await cache.resolve('$origin/missing'), isNull);
    expect(await cache.resolve('$origin/html'), isNull);
    expect(await cache.resolve('file:///private/file.png'), isNull);
    final files = await directory.list(recursive: true).where((entry) => entry is File).toList();
    expect(files, isEmpty);
  });
}
