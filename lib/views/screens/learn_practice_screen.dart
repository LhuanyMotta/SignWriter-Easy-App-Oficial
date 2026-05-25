import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../../theme/app_theme.dart';

/// Tela de Aprender e Praticar
class LearnPracticeScreen extends StatefulWidget {
  const LearnPracticeScreen({super.key});

  @override
  State<LearnPracticeScreen> createState() => _LearnPracticeScreenState();
}

class _LearnPracticeScreenState extends State<LearnPracticeScreen> {
  late LearnPracticeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LearnPracticeViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aprender e Praticar'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Busca será implementada em breve')),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16 * spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 16 * spacing),
                _buildCategoriesGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Consumer<LearnPracticeViewModel>(
      builder: (context, vm, _) {
        final categories = vm.categories;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = Map<String, dynamic>.from(categories[index] as Map);
            final title = category['title'] as String? ?? 'Categoria';
            final icon = category['icon'] as IconData? ?? Icons.book;
            final color = category['color'] as Color? ??
                Theme.of(context).colorScheme.primary;
            final spacing =
                Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;

            return GestureDetector(
              onTap: () {
                vm.openCategory(context, index);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryDetailScreen(
                      category: category,
                      categoryIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16 * spacing),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Detalhe da categoria — conteúdo real será integrado depois
class CategoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> category;
  final int categoryIndex;

  const CategoryDetailScreen({
    required this.category,
    required this.categoryIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = category['title'] as String? ?? 'Categoria';
    final color = category['color'] as Color? ??
        Theme.of(context).colorScheme.primary;
    final icon = category['icon'] as IconData? ?? Icons.book;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'O conteúdo desta categoria será disponibilizado em breve.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                          .extension<AppThemeTokens>()
                          ?.onSurfaceMuted ??
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
