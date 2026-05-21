import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sign_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<SignModel> _favorites = [];
  List<SignModel> _filteredFavorites = [];

  List<String> _categories = ['Todos'];

  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  bool _isLoading = false;

  List<SignModel> get favorites => _filteredFavorites;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  FavoritesViewModel() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        _favorites = [];
        _filteredFavorites = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('favorite_signs')
          .select('''
            sign_id,
            signs_dictionary (
              id,
              title,
              description,
              category,
              image_url,
              created_at
            )
          ''')
          .eq('user_id', user.id);

      _favorites = response.map<SignModel>((item) {
        final sign = item['signs_dictionary'];

        return SignModel(
          id: sign['id'].toString(),
          name: sign['title'] ?? 'Sem nome',
          description: sign['description'],
          signImagePath: sign['image_url'] ?? '',
          category: sign['category'] ?? 'Sem categoria',
          createdAt: DateTime.tryParse(
                  sign['created_at'] ?? DateTime.now().toString()) ??
              DateTime.now(),
          isFavorite: true,
        );
      }).toList();

      final categorySet =
          _favorites.map((sign) => sign.category).toSet().toList();

      categorySet.sort();

      _categories = ['Todos', ...categorySet];

      _filteredFavorites = List.from(_favorites);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');

      _favorites = [];
      _filteredFavorites = [];

      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredFavorites = _favorites.where((sign) {
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

  Future<void> removeFavorite(String id) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return;

      await _supabase
          .from('favorite_signs')
          .delete()
          .eq('user_id', user.id)
          .eq('sign_id', id);

      _favorites.removeWhere((sign) => sign.id == id);
      _filteredFavorites.removeWhere((sign) => sign.id == id);

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao remover favorito: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return;

      await _supabase
          .from('favorite_signs')
          .delete()
          .eq('user_id', user.id);

      _favorites.clear();
      _filteredFavorites.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao limpar favoritos: $e');
    }
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
              Image.network(
                sign.signImagePath,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(sign.description ?? 'Sem descrição'),
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
}