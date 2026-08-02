import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/utils/friendly_error.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/states/app_empty_state.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/states/app_error_state.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/states/app_loading_state.dart';

void main() {
  testWidgets('AppLoadingState mostra indicador e mensagem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLoadingState(message: 'Carregando sinais...')),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Carregando sinais...'), findsOneWidget);
  });

  testWidgets('AppErrorState oferece retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorState(
            message: 'Sem conexão',
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.text('Não foi possível carregar'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
  });

  testWidgets('AppEmptyState mostra ação', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.search_off,
            title: 'Nenhum resultado',
            message: 'Limpe os filtros',
            actionLabel: 'Limpar',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Limpar'));
    expect(tapped, isTrue);
  });

  test('friendlyError traduz rede e timeout', () {
    expect(
      friendlyError(Exception('SocketException: network failed')),
      'Verifique sua conexão com a internet.',
    );
    expect(
      friendlyError(Exception('timeout waiting')),
      'A operação demorou mais que o esperado. Tente novamente.',
    );
    expect(
      friendlyError(Exception('something weird')),
      'Não foi possível concluir a operação. Tente novamente.',
    );
  });
}
