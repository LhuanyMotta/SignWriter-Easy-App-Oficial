import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/write_signs_viewmodel.dart';
import '../../models/sign_model.dart';
import '../widgets/sign_card.dart';
import '../widgets/category_selector.dart';
import '../../theme/app_spacing.dart';

class WriteSignsScreen extends StatefulWidget {
  const WriteSignsScreen({super.key});

  @override
  State<WriteSignsScreen> createState() => _WriteSignsScreenState();
}

class _WriteSignsScreenState extends State<WriteSignsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late WriteSignsViewModel _viewModel;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _viewModel = WriteSignsViewModel();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escrever Sinais'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.all(context, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                SizedBox(height: AppSpacing.value(context, 16)),
                
                Consumer<WriteSignsViewModel>(
                  builder: (context, viewModel, child) {
                    return CategorySelector(
                      categories: viewModel.categories,
                      selectedCategory: viewModel.selectedCategory,
                      onCategorySelected: (category) {
                        viewModel.setCategory(category);
                      },
                    );
                  },
                ),
                
                SizedBox(height: AppSpacing.value(context, 16)),
                Text(
                  'Sinais Recentes',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: AppSpacing.value(context, 8)),
                
                Consumer<WriteSignsViewModel>(
                  builder: (context, viewModel, child) {
                    final signs = _searchQuery.isEmpty 
                        ? viewModel.recentSigns 
                        : viewModel.searchSigns(_searchQuery);
                    
                    if (signs.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text(
                            'Nenhum sinal encontrado. \nCrie um novo sinal!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    
                    return Expanded(
                      child: ListView.builder(
                        itemCount: signs.length,
                        itemBuilder: (context, index) {
                          return SignCard(
                            sign: signs[index],
                            onEdit: () {
                              _editSign(context, signs[index]);
                            },
                            onDelete: () {
                              _confirmDeleteSign(context, signs[index]);
                            },
                            onFavoriteToggle: () {
                              viewModel.toggleFavorite(signs[index].id);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createNewSign(context),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar sinais...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _searchQuery.isNotEmpty
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

  void _createNewSign(BuildContext context) {
    // Aqui implementaremos a criação de um novo sinal
    // No futuro, navegaremos para uma tela de edição
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de criar novo sinal será implementada em breve'),
      ),
    );
  }

  void _editSign(BuildContext context, SignModel sign) {
    // Aqui implementaremos a edição de um sinal existente
    // No futuro, navegaremos para uma tela de edição com o sinal selecionado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar sinal: ${sign.name}'),
      ),
    );
  }

  void _confirmDeleteSign(BuildContext context, SignModel sign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o sinal "${sign.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteSign(sign.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sinal "${sign.name}" excluído com sucesso'),
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escrever Sinais'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nesta tela você pode:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.value(context, 8)),
              Text('• Criar novos sinais em SignWriting'),
              Text('• Editar sinais existentes'),
              Text('• Buscar sinais por nome'),
              Text('• Filtrar sinais por categoria'),
              Text('• Marcar sinais como favoritos'),
              SizedBox(height: AppSpacing.value(context, 16)),
              Text(
                'Como usar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.value(context, 8)),
              Text('1. Utilize o botão + para criar um novo sinal'),
              Text('2. Toque em um sinal existente para visualizá-lo'),
              Text('3. Use os ícones para editar ou excluir sinais'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
} 
