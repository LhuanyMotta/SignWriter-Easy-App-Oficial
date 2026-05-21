import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/sign_model.dart';

/// Tela de Favoritos
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesViewModel _viewModel;
  final HomeViewModel _homeViewModel = HomeViewModel();
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
          title: const Text(
            'Meus Favoritos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2D78BB),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Consumer<FavoritesViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  onPressed: viewModel.favorites.isEmpty 
                      ? null 
                      : () => _confirmClearAll(context),
                  tooltip: 'Limpar todos os favoritos',
                );
              },
            ),
          ],
        ),
        body: Consumer<FavoritesViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Barra de pesquisa e filtros
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Barra de pesquisa
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar favoritos...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Filtros de categoria horizontal
                      if (viewModel.categories.isNotEmpty)
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.categories.length,
                            itemBuilder: (context, index) {
                              final category = viewModel.categories[index];
                              final isSelected = category == viewModel.selectedCategory;
                              
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: 8,
                                  left: index == 0 ? 0 : 8,
                                ),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF2D78BB),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF666666),
                                    fontSize: 14,
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
                        ),
                    ],
                  ),
                ),
                
                // Lista de favoritos
                Expanded(
                  child: _buildContent(viewModel),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            _homeViewModel.onBottomNavTapped(index, context);
          },
          selectedItemColor: const Color(0xFF2D78BB),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
  
  // Conteúdo principal (lista ou estado vazio)
  Widget _buildContent(FavoritesViewModel viewModel) {
    if (viewModel.favorites.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.favorites.length,
      itemBuilder: (context, index) {
        final sign = viewModel.favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFavoriteCard(sign, viewModel),
        );
      },
    );
  }
  
  // Card de favorito individual
  Widget _buildFavoriteCard(SignModel sign, FavoritesViewModel viewModel) {
    return InkWell(
  borderRadius: BorderRadius.circular(12),
  onTap: () => viewModel.openSignDetails(context, sign),
  child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem do sinal
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                sign.signImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.sign_language,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Informações do sinal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sign.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sign.description ?? 'Sem descrição',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D78BB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sign.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2D78BB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botão de favorito
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => _confirmRemoveFavorite(context, sign, viewModel),
          ),
          const SizedBox(width: 8),
        ],
      ),
  ),
    );
  }
  
  // Estado vazio quando não há favoritos
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum favorito encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Remover dos favoritos'),
        content: Text('Deseja remover "${sign.name}" dos seus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2D78BB),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.removeFavorite(sign.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${sign.name} removido dos favoritos'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  action: SnackBarAction(
                    label: 'Desfazer',
                    textColor: Colors.white,
                    onPressed: () {
                      // Implementação futura para desfazer ação
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Limpar favoritos'),
        content: const Text('Deseja remover todos os itens dos seus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2D78BB),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final viewModel = Provider.of<FavoritesViewModel>(context, listen: false);
              viewModel.clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos os favoritos foram removidos'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}