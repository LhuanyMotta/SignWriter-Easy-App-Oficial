import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sign_model.dart';
import '../views/screens/practice_quiz_screen.dart';

class LearnPracticeViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<SignModel> _allSigns = [];

  List<Map<String, dynamic>> categories = [];

  List<Map<String, dynamic>> recommendedExercises = [];

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  LearnPracticeViewModel() {
    loadLearningData();
  }

  Future<void> loadLearningData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final signsResponse = await _supabase
          .from('signs_dictionary')
          .select()
          .order('created_at', ascending: true);

      _allSigns = signsResponse.map<SignModel>((item) {
        return SignModel(
          id: item['id'].toString(),
          name: item['title'] ?? 'Sem nome',
          description: item['description'],
          signImagePath: item['image_url'] ?? '',
          category: item['category'] ?? 'Sem categoria',
          createdAt: DateTime.tryParse(
                  item['created_at'] ?? DateTime.now().toString()) ??
              DateTime.now(),
        );
      }).toList();

      final categoriesMap = <String, List<SignModel>>{};

      for (final sign in _allSigns) {
        categoriesMap.putIfAbsent(sign.category, () => []);
        categoriesMap[sign.category]!.add(sign);
      }

      categories = categoriesMap.entries.map((entry) {
        return {
          'title': entry.key,
          'icon': Icons.school,
          'color': const Color(0xFF2D78BB),
          'progress': 0.0,
          'lessons': entry.value.length,
          'lessonsCompleted': 0,
          'signs': entry.value,
        };
      }).toList();

      recommendedExercises = categories.take(3).map((category) {
        return {
          'title': category['title'],
          'description':
              'Pratique sinais da categoria ${category['title']}',
          'duration': '5 min',
          'isNew': true,
          'signs': category['signs'],
        };
      }).toList();

      await _loadProgress();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar aprendizado: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProgress() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final progressResponse = await _supabase
        .from('learning_progress')
        .select()
        .eq('user_id', user.id);

    final completedIds = progressResponse
        .where((item) => item['completed'] == true)
        .map<String>((item) => item['sign_id'].toString())
        .toSet();

    for (final category in categories) {
      final signs = category['signs'] as List<SignModel>;

      int completed = signs
          .where((sign) => completedIds.contains(sign.id))
          .length;

      category['lessonsCompleted'] = completed;

      category['progress'] =
          signs.isEmpty ? 0.0 : completed / signs.length;
    }

    notifyListeners();
  }

  double get overallProgress {
    if (categories.isEmpty) return 0.0;

    double total = 0;

    for (var category in categories) {
      total += category['progress'] as double;
    }

    return total / categories.length;
  }

  void openCategory(BuildContext context, int index) {
    final category = categories[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          title: category['title'],
          signs: List<SignModel>.from(category['signs']),
        ),
      ),
    );
  }

  void startExercise(BuildContext context, int index) {
    final exercise = recommendedExercises[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          title: exercise['title'],
          signs: List<SignModel>.from(exercise['signs']),
        ),
      ),
    );
  }
}