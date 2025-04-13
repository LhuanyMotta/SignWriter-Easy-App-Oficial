import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../models/sign_model.dart';

/// Tela de Favoritos
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _viewModel = FavoritesViewModel();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  // Callback para mudanças na pesquisa
  void _onSearchChanged() {
    _viewModel.search(_searchController.text);
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Favoritos'),
          actions: [
            Consumer<FavoritesViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: viewModel.favorites.isEmpty 
                      ? null 
                      : () => _confirmClearAll(context),
                  tooltip: 'Limpar todos os favoritos',
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
            
            // Filtros de categoria
            Consumer<FavoritesViewModel>(
              builder: (context, viewModel, _) {
                return _buildCategoryFilter(viewModel);
              },
            ),
            
            // Lista de favoritos
            Expanded(
              child: Consumer<FavoritesViewModel>(
                builder: (context, viewModel, _) {
                  final favorites = viewModel.favorites;
                  
                  if (favorites.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteItem(favorites[index], viewModel);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Barra de pesquisa com ícone e campo de texto
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar favoritos...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
      ),
    );
  }
  
  // Filtro horizontal de categorias
  Widget _buildCategoryFilter(FavoritesViewModel viewModel) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = category == viewModel.selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  viewModel.filterByCategory(category);
                }
              },
            ),
          );
        },
      ),
    );
  }
  
  // Estado vazio quando não há favoritos
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum favorito encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione sinais aos favoritos para vê-los aqui',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Item da lista de favoritos com ações
  Widget _buildFavoriteItem(SignModel sign, FavoritesViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => viewModel.openSignDetails(context, sign),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Imagem do sinal
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  sign.signImagePath,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.sign_language,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações do sinal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sign.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sign.description ?? 'Sem descrição',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sign.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botão de remover dos favoritos
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _confirmRemoveFavorite(context, sign, viewModel),
                tooltip: 'Remover dos favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Diálogo de confirmação para remover um item dos favoritos
  void _confirmRemoveFavorite(
      BuildContext context, 
      SignModel sign, 
      FavoritesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover dos favoritos'),
        content: Text('Deseja remover "${sign.name}" dos seus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeFavorite(sign.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${sign.name} removido dos favoritos'),
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () {
                      // Implementação futura para desfazer ação
                    },
                  ),
                ),
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
  
  // Diálogo de confirmação para limpar todos os favoritos
  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar favoritos'),
        content: const Text('Deseja remover todos os itens dos seus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final viewModel = Provider.of<FavoritesViewModel>(context, listen: false);
              viewModel.clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todos os favoritos foram removidos')),
              );
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
} 