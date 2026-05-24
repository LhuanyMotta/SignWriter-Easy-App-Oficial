import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../theme/app_spacing.dart';

class LearnPracticeScreen extends StatefulWidget {
  const LearnPracticeScreen({super.key});

  @override
  State<LearnPracticeScreen> createState() => _LearnPracticeScreenState();
}

class _LearnPracticeScreenState extends State<LearnPracticeScreen> {
  late LearnPracticeViewModel _viewModel;
  final HomeViewModel _homeViewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<LearnPracticeViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Aprender e Praticar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<LearnPracticeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: primary),
              );
            }

            return SingleChildScrollView(
              padding: AppSpacing.all(context, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(context, viewModel),
                  SizedBox(height: AppSpacing.value(context, 24)),
                  _sectionTitle(context, 'Categorias'),
                  SizedBox(height: AppSpacing.value(context, 16)),
                  _buildCategoriesGrid(context, viewModel),
                  SizedBox(height: AppSpacing.value(context, 24)),
                  _sectionTitle(context, 'Recomendados para Você'),
                  SizedBox(height: AppSpacing.value(context, 16)),
                  _buildRecommendedExercises(context, viewModel),
                ],
              ),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    LearnPracticeViewModel viewModel,
  ) {
    final progress = viewModel.overallProgress;

    return Container(
      width: double.infinity,
      padding: AppSpacing.all(context, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu Progresso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 16)),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: AppSpacing.value(context, 10)),
          Text(
            '${(progress * 100).toInt()}% concluído',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(
  BuildContext context,
  LearnPracticeViewModel viewModel,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return LayoutBuilder(
    builder: (context, constraints) {
      final spacing = AppSpacing.value(context, 16);
      final cardWidth = (constraints.maxWidth - spacing) / 2;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: viewModel.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final progress = category['progress'] as double;

          return SizedBox(
            width: cardWidth,
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => viewModel.openCategory(context, index),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: AppSpacing.value(context, 180),
                  ),
                  padding: AppSpacing.all(context, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: Theme.of(context).colorScheme.primary,
                        size: AppSpacing.value(context, 34),
                      ),

                      Text(
                        category['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF333333),
                        ),
                        textAlign: TextAlign.left,
                        softWrap: true,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: AppSpacing.value(context, 6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}

  Widget _buildRecommendedExercises(
    BuildContext context,
    LearnPracticeViewModel viewModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: viewModel.recommendedExercises.asMap().entries.map((entry) {
        final index = entry.key;
        final exercise = entry.value;

        return Container(
          margin: AppSpacing.only(context, bottom: 14),
          padding: AppSpacing.all(context, 16),
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
              CircleAvatar(
                backgroundColor: primary,
                child: const Icon(Icons.school, color: Colors.white),
              ),
              SizedBox(width: AppSpacing.value(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: AppSpacing.value(context, 4)),
                    Text(
                      exercise['description'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => viewModel.startExercise(context, index),
                child: const Text('Iniciar'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
