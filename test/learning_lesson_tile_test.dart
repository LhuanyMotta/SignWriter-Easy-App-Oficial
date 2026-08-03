import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_category_model.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_model.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/learning/learning_lesson_tile.dart';

const _category = LessonCategoryModel(
  id: 'cat-1',
  title: 'Módulo',
  description: 'Descrição',
  iconKey: 'school',
  colorHex: '#2D78BB',
);

LessonModel _longLesson() => const LessonModel(
      id: 'les-1',
      title: 'Uma lição com um título muito longo para validar telas pequenas',
      summary: 'Resumo',
      estimatedMinutes: 999,
      difficulty: 'Uma dificuldade muito longa',
      status: 'draft',
    );

Widget _wrap({
  required double width,
  required double textScale,
  required bool canEdit,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 700),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: LearningLessonTile(
              lesson: _longLesson(),
              category: _category,
              isCompleted: false,
              isInProgress: true,
              isLast: false,
              canEdit: canEdit,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('não estoura em 320 px com texto ampliado', (tester) async {
    await tester.pumpWidget(
      _wrap(width: 320, textScale: 2, canEdit: true),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Rascunho'), findsOneWidget);
  });

  testWidgets('remove metadados redundantes do card', (tester) async {
    await tester.pumpWidget(
      _wrap(width: 375, textScale: 1, canEdit: false),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('999 min'), findsNothing);
    expect(find.textContaining('exerc.'), findsNothing);
    expect(find.text('Uma dificuldade muito longa'), findsNothing);
  });
}
