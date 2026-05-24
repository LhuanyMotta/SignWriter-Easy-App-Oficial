import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dictionary_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/sign_model.dart';
import '../../theme/app_spacing.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late DictionaryViewModel _viewModel;
  final HomeViewModel _homeViewModel = HomeViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<DictionaryViewModel>(context, listen: false);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _viewModel.search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Dicionário',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<DictionaryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: primary),
              );
            }

            return Column(
              children: [
                Container(
                  padding: AppSpacing.all(context, 16),
                  color: cardColor,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF222A33)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar sinais...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark ? Colors.grey[400] : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: isDark ? Colors.grey[400] : Colors.grey,
                                    ),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.value(context, 16)),
                      SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.categories.length,
                          itemBuilder: (context, index) {
                            final category = viewModel.categories[index];
                            final isSelected =
                                category == viewModel.selectedCategory;

                            return Padding(
                              padding: AppSpacing.only(context, right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                selectedColor: primary,
                                backgroundColor: isDark
                                    ? const Color(0xFF222A33)
                                    : Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isDark
                                          ? Colors.grey[300]
                                          : const Color(0xFF666666),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                onSelected: (_) {
                                  viewModel.filterByCategory(category);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: viewModel.signs.isEmpty
                      ? _buildEmptyState(context)
                      : GridView.builder(
                          padding: AppSpacing.all(context, 16),
                          itemCount: viewModel.signs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            return _buildSignCard(
                              context,
                              viewModel.signs[index],
                              viewModel,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) => _homeViewModel.onBottomNavTapped(index, context),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildSignCard(
    BuildContext context,
    SignModel sign,
    DictionaryViewModel viewModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => viewModel.openSignDetails(context, sign),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF222A33)
                          : const Color(0xFFF7F7F7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        sign.signImagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.sign_language,
                            size: 50,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        sign.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: sign.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => viewModel.toggleFavorite(sign.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.all(context, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sign.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.value(context, 4)),
                  Text(
                    sign.description ?? 'Sem descrição',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.value(context, 8)),
                  Container(
                    padding: AppSpacing.symmetric(context, horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sign.category,
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Nenhum sinal encontrado',
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
