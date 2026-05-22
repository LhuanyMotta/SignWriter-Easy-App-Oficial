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
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text(
            'Aprender e Praticar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF2D78BB),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SafeArea(
          child: Consumer<LearnPracticeViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressCard(viewModel),
                    const SizedBox(height: 24),

                    const Text(
                      'Categorias',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D78BB),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCategoriesGrid(viewModel),

                    const SizedBox(height: 24),

                    const Text(
                      'Recomendados para Você',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D78BB),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildRecommendedExercises(viewModel),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
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

  Widget _buildProgressCard(LearnPracticeViewModel viewModel) {
    final progress = viewModel.overallProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D78BB),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
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

  Widget _buildCategoriesGrid(LearnPracticeViewModel viewModel) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
                  color: category['color'] as Color,
                  size: 34,
                ),
                const Spacer(),
                Text(
                  category['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    category['color'] as Color,
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

  Widget _buildRecommendedExercises(LearnPracticeViewModel viewModel) {
    return Column(
      children: viewModel.recommendedExercises.asMap().entries.map((entry) {
        final index = entry.key;
        final exercise = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF2D78BB),
                child: Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['description'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => viewModel.startExercise(context, index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D78BB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Iniciar'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}