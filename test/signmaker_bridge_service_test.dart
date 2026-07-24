import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/models/signmaker_result.dart';
import 'package:signwriter_easy_app_oficial/services/signmaker_bridge_service.dart';

void main() {
  final bridge = SignMakerBridgeService();

  group('SignMakerBridgeService.isValidFsw', () {
    test('aceita FSW de exemplo', () {
      const fsw =
          'AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475';
      expect(bridge.isValidFsw(fsw), isTrue);
    });

    test('rejeita vazio e SW-MVP', () {
      expect(bridge.isValidFsw(''), isFalse);
      expect(bridge.isValidFsw('SW-MVP:hand-open@0.5,0.5,r0,m0'), isFalse);
    });
  });

  group('SignMakerBridgeService.parseHostMessage', () {
    test('parseia save com fsw válido e png data URL', () {
      final pngBytes = base64Encode(List<int>.generate(8, (i) => i));
      final event = bridge.parseHostMessage(
        '{"signmaker":"save","fsw":"M500x500S10011500x500","swu":"x",'
        '"png":"data:image/png;base64,$pngBytes"}',
      );
      expect(event.kind, SignMakerHostEventKind.save);
      expect(event.result?.fsw, 'M500x500S10011500x500');
      expect(event.result?.previewPngBase64, pngBytes);
      expect(event.result?.previewPngBytes, isNotNull);
    });

    test('ignora tipos desconhecidos', () {
      final event = bridge.parseHostMessage('{"signmaker":"explode","cmd":"rm"}');
      expect(event.kind, SignMakerHostEventKind.ignored);
    });

    test('save com FSW inválido vira erro', () {
      final event = bridge.parseHostMessage(
        '{"signmaker":"save","fsw":"SW-MVP:x","swu":""}',
      );
      expect(event.kind, SignMakerHostEventKind.error);
      expect(event.errorCode, 'invalid_fsw');
    });
  });

  test('encodeLoadMessage inclui ui e alphabet padrão', () {
    final raw = bridge.encodeLoadMessage();
    expect(raw, contains('"ui":"ptBR"'));
    expect(raw, contains('"alphabet":"bzs"'));
  });

  test('SignMakerResult.normalizePngBase64 remove prefixo data URL', () {
    expect(
      SignMakerResult.normalizePngBase64('data:image/png;base64,abc123'),
      'abc123',
    );
    expect(SignMakerResult.normalizePngBase64('abc123'), 'abc123');
    expect(SignMakerResult.normalizePngBase64(null), isNull);
  });
}
