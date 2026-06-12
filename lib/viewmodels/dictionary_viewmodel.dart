import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sign_model.dart';

class DictionaryViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<SignModel> _signs = [];
  List<SignModel> _filteredSigns = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool _isLoading = false;

  String _allLabel = 'All';
  List<String> _categories = ['All'];

  List<SignModel> get signs => _filteredSigns;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  List<String> get categories => _categories;

  void setAllLabel(String label) {
    if (_allLabel == label) return;
    _allLabel = label;
    if (_categories.isNotEmpty) _categories[0] = label;
    _selectedCategory = label;
    notifyListeners();
  }

  DictionaryViewModel() {
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;

      final response = await _supabase
          .from('signs_dictionary')
          .select()
          .order('created_at', ascending: true);

      _signs = response
          .map<SignModel>((item) => SignModel.fromMap(item))
          .toList();

      if (user != null) {
        final favoritesResponse = await _supabase
            .from('favorite_signs')
            .select('sign_id')
            .eq('user_id', user.id);

        final favoriteIds = favoritesResponse
            .map<String>((item) => item['sign_id'].toString())
            .toSet();

        for (final sign in _signs) {
          sign.isFavorite = favoriteIds.contains(sign.id);
        }
      }

      final categorySet = _signs.map((sign) => sign.category).toSet().toList();
      categorySet.sort();

      _categories = [_allLabel, ...categorySet];
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
          _selectedCategory == _allLabel || sign.category == _selectedCategory;

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

  Future<void> toggleFavorite(String signId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      debugPrint('Usuário não autenticado');
      return;
    }

    final index = _signs.indexWhere((sign) => sign.id == signId);

    if (index < 0) return;

    final sign = _signs[index];

    try {
      if (sign.isFavorite) {
        await _supabase
            .from('favorite_signs')
            .delete()
            .eq('user_id', user.id)
            .eq('sign_id', signId);

        sign.isFavorite = false;
      } else {
        await _supabase.from('favorite_signs').insert({
          'user_id': user.id,
          'sign_id': signId,
        });

        sign.isFavorite = true;
      }

      final filteredIndex =
          _filteredSigns.indexWhere((item) => item.id == signId);

      if (filteredIndex >= 0) {
        _filteredSigns[filteredIndex].isFavorite = sign.isFavorite;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar favorito: $e');
    }
  }
}