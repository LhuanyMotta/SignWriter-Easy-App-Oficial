import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';

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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(context, viewModel),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Categorias'),
                  const SizedBox(height: 16),
                  _buildCategoriesGrid(context, viewModel),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Recomendados para Você'),
                  const SizedBox(height: 16),
                  _buildRecommendedExercises(context, viewModel),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) => _homeViewModel.onBottomNavTapped(index, context),
          items: const [
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final category = viewModel.categories[index];
        final progress = category['progress'] as double;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => viewModel.openCategory(context, index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: Theme.of(context).colorScheme.primary,
                  size: 34,
                ),
                const Spacer(),
                Text(
                  category['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      isDark ? Colors.grey[800] : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
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
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 14),
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
                    const SizedBox(height: 4),
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