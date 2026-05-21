import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sign_model.dart';

class DictionaryViewModel extends ChangeNotifier {
  List<SignModel> _signs = [];
  List<SignModel> _filteredSigns = [];

  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  bool _isLoading = false;

  List<String> _categories = ['Todos'];

  List<SignModel> get signs => _filteredSigns;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  List<String> get categories => _categories;

  DictionaryViewModel() {
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('signs_dictionary')
          .select()
          .order('created_at', ascending: true);

      _signs = response
          .map<SignModel>((item) => SignModel.fromMap(item))
          .toList();

      final categorySet = _signs.map((sign) => sign.category).toSet().toList();
      categorySet.sort();

      _categories = ['Todos', ...categorySet];
      _filteredSigns = List.from(_signs);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dicionário: $e');

      _isLoading = false;
      _signs = [];
      _filteredSigns = [];
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredSigns = _signs.where((sign) {
      final matchesCategory =
          _selectedCategory == 'Todos' || sign.category == _selectedCategory;

      final searchLower = _searchQuery.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          sign.name.toLowerCase().contains(searchLower) ||
          (sign.description?.toLowerCase().contains(searchLower) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();

    notifyListeners();
  }

  void openSignDetails(BuildContext context, SignModel sign) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(sign.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sign.signImagePath.isNotEmpty)
                Image.network(
                  sign.signImagePath,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.sign_language, size: 80);
                  },
                ),
              const SizedBox(height: 12),
              Text(sign.description ?? 'Sem descrição'),
              const SizedBox(height: 8),
              Text(
                sign.category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D78BB),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void toggleFavorite(String signId) {
    final index = _signs.indexWhere((sign) => sign.id == signId);

    if (index >= 0) {
      _signs[index].isFavorite = !_signs[index].isFavorite;

      final filteredIndex =
          _filteredSigns.indexWhere((sign) => sign.id == signId);

      if (filteredIndex >= 0) {
        _filteredSigns[filteredIndex].isFavorite = _signs[index].isFavorite;
      }

      notifyListeners();
    }
  }
}