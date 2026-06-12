import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/sign_model.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/l10n.dart';

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<FavoritesViewModel>().setAllLabel(context.l10n.favoritesAll);
    _viewModel = Provider.of<FavoritesViewModel>(context, listen: false);
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
          title: Text(
            context.l10n.bottomFavorites,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Consumer<FavoritesViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: viewModel.favorites.isEmpty
                      ? null
                      : () => _confirmClearAll(context),
                );
              },
            ),
          ],
        ),
        body: Consumer<FavoritesViewModel>(
          builder: (context, viewModel, child) {
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
                            hintText: context.l10n.favoritesSearchHint,
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
                            final selected =
                                category == viewModel.selectedCategory;

                            return Padding(
                              padding: AppSpacing.only(context, right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: selected,
                                selectedColor: primary,
                                backgroundColor: isDark
                                    ? const Color(0xFF222A33)
                                    : Colors.white,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                  fontWeight: selected
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
                Expanded(child: _buildContent(context, viewModel)),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) => _homeViewModel.onBottomNavTapped(index, context),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: context.l10n.bottomHome),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: context.l10n.bottomFavorites),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: context.l10n.bottomProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FavoritesViewModel viewModel) {
    final primary = Theme.of(context).colorScheme.primary;

    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (viewModel.favorites.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: AppSpacing.all(context, 16),
      itemCount: viewModel.favorites.length,
      itemBuilder: (context, index) {
        final sign = viewModel.favorites[index];
        return Padding(
          padding: AppSpacing.only(context, bottom: 16),
          child: _buildFavoriteCard(context, sign, viewModel),
        );
      },
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    SignModel sign,
    FavoritesViewModel viewModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => viewModel.openSignDetails(context, sign),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 82,
              height: 82,
              margin: AppSpacing.all(context, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222A33) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  sign.signImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.sign_language,
                      size: 40,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppSpacing.symmetric(context, vertical: 12),
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
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.value(context, 8)),
                    Container(
                      padding: AppSpacing.symmetric(context, horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        sign.category,
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _confirmRemoveFavorite(context, sign, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.all(context, 32),
        child: Text(
          context.l10n.favoritesEmpty,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _confirmRemoveFavorite(
    BuildContext context,
    SignModel sign,
    FavoritesViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.favoritesRemoveTitle),
        content: Text(context.l10n.favoritesRemoveContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.removeFavorite(sign.id);
              Navigator.pop(context);
            },
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final viewModel = Provider.of<FavoritesViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.favoritesClearTitle),
        content: Text(context.l10n.favoritesClearContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.clearAllFavorites();
              Navigator.pop(context);
            },
            child: Text(context.l10n.clear),
          ),
        ],
      ),
    );
  }
}
