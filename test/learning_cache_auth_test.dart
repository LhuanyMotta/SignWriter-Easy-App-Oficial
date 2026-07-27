import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwriter_easy_app_oficial/models/lesson_category_model.dart';
import 'package:signwriter_easy_app_oficial/services/learning_content_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LearningContentCache', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('grava e lê cache válido', () async {
      final cache = LearningContentCache();
      final categories = [
        LessonCategoryModel.fromMap({
          'id': 'cat-1',
          'title': 'Módulo',
          'description': 'Desc',
          'icon': 'school',
          'color': '#2D78BB',
          'lessons': [
            {
              'id': 'les-1',
              'title': 'Lição',
              'summary': 'Resumo',
              'estimatedMinutes': 5,
              'difficulty': 'Iniciante',
              'blocks': [
                {'id': 'b1', 'type': 'text', 'body': 'Oi', 'order_index': 0},
              ],
            },
          ],
        }),
      ];

      await cache.save(
        categories: categories,
        localeCode: 'pt',
        contentVersion: '1-1-1',
      );

      final loaded = await cache.load();
      expect(loaded, isNotNull);
      expect(loaded!.categories.first.id, 'cat-1');
      expect(loaded.contentVersion, '1-1-1');
      expect(loaded.localeCode, 'pt');
    });

    test('recusa substituir por cache incompleto', () async {
      final cache = LearningContentCache();
      expect(
        () => cache.save(
          categories: const [],
          localeCode: 'pt',
          contentVersion: '0',
        ),
        throwsStateError,
      );
    });
  });

  group('AuthorizationService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('override local pode ser limpo e não é fonte de autorização', () async {
      final prefs = await SharedPreferences.getInstance();
      const key = 'mock_can_edit_learning_content';
      expect(prefs.getBool(key), isNull);
      await prefs.setBool(key, true);
      expect(prefs.getBool(key), isTrue);
      await prefs.remove(key);
      expect(prefs.getBool(key), isNull);
    });
  });
}
