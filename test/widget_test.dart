// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signwriter_facil/main.dart';
import 'package:signwriter_facil/viewmodels/app_settings_viewmodel.dart';

void main() {
  testWidgets('Carrega app sem quebrar', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(appSettings: AppSettingsViewModel()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
