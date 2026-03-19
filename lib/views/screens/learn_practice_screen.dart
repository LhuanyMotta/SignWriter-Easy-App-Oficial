import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/learn_practice_viewmodel.dart';
import '../../theme/app_theme.dart';

/// Tela de Aprender e Praticar (compatível com o ViewModel fornecido)
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
                _buildProgressSection(),
                SizedBox(height: 24 * spacing),
                Text('Categorias', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 16 * spacing),
                _buildCategoriesGrid(),
                SizedBox(height: 24 * spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recomendados para Você', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        // Passa o ViewModel para a nova rota para evitar ProviderNotFoundError
                        final vm = Provider.of<LearnPracticeViewModel>(context, listen: false);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RecommendedAllScreen(vm: vm)),
                        );
                      },
                      child: const Text('Ver Todos'),
                    ),
                  ],
                ),
                SizedBox(height: 8 * spacing),
                _buildRecommendedExercises(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Consumer<LearnPracticeViewModel>(builder: (context, vm, _) {
      final theme = Theme.of(context);
      final spacing = theme.extension<AppThemeTokens>()?.spacingScale ?? 1.0;
      final progress = (vm.overallProgress).clamp(0.0, 1.0);
      return Container(
        padding: EdgeInsets.all(16 * spacing),
        decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Seu Progresso',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12 * spacing),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
              minHeight: 10,
            ),
          ),
          SizedBox(height: 8 * spacing),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${(progress * 100).toInt()}% Concluído',
              style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600),
            ),
            Text(
              'Continue Aprendendo',
              style: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.8)),
            ),
          ]),
        ]),
      );
    });
  }

  Widget _buildCategoriesGrid() {
    return Consumer<LearnPracticeViewModel>(builder: (context, vm, _) {
      final categories = vm.categories;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> category = Map<String, dynamic>.from(categories[index] as Map);
          final progress = (category['progress'] as double?)?.clamp(0.0, 1.0) ?? 0.0;
          final title = category['title'] as String? ?? 'Categoria';
          final lessons = category['lessons'] as int? ?? 0;
          final lessonsCompleted = category['lessonsCompleted'] as int? ?? 0;
          final icon = category['icon'] as IconData? ?? Icons.book;
          final color = category['color'] as Color? ?? Theme.of(context).colorScheme.primary;

          return GestureDetector(
            onTap: () {
              try {
                vm.openCategory(context, index);
              } catch (_) {}
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(category: category, categoryIndex: index),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2)),
              ]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
                  Text(
                    '$lessonsCompleted/$lessons',
                    style: TextStyle(
                      color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
                const Spacer(),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ]),
            ),
          );
        },
      );
    });
  }

  Widget _buildRecommendedExercises() {
    return Consumer<LearnPracticeViewModel>(builder: (context, vm, _) {
      final items = vm.recommendedExercises;
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final exercise = Map<String, dynamic>.from(items[index] as Map);
          final title = exercise['title'] as String? ?? 'Exercício';
          final desc = exercise['description'] as String? ?? '';
          final duration = exercise['duration'] as String? ?? '';
          final isNew = exercise['isNew'] as bool? ?? false;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                if (isNew) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)), child: const Text('NOVO', style: TextStyle(color: Colors.white, fontSize: 10))),
              ]),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    desc,
                    style: TextStyle(
                      color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ]),
                ]),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  try {
                    vm.startExercise(context, index);
                  } catch (_) {}
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(lessonTitle: title, lessonContent: desc),
                    ),
                  );
                },
                child: const Text('Iniciar'),
              ),
            ),
          );
        },
      );
    });
  }
}

/// Category detail (independent placeholder)
class CategoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> category;
  final int categoryIndex;

  const CategoryDetailScreen({required this.category, required this.categoryIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final title = category['title'] as String? ?? 'Categoria';
    final lessons = category['lessons'] as int? ?? 0;
    final completed = category['lessonsCompleted'] as int? ?? 0;
    final color = category['color'] as Color? ?? Theme.of(context).colorScheme.primary;
    final icon = category['icon'] as IconData? ?? Icons.book;

    final List<Map<String, String>> lessonList = List.generate(lessons, (i) {
      return {
        'title': 'Lição ${i + 1}',
        'subtitle': i < completed ? 'Concluída' : 'Não iniciada',
        'content': 'Conteúdo da Lição ${i + 1} de $title. (placeholder)',
      };
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  '$completed de $lessons lições concluídas',
                  style: TextStyle(
                    color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: lessonList.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final item = lessonList[i];
                final done = item['subtitle'] == 'Concluída';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: done ? color : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: done
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  title: Text(item['title']!),
                  subtitle: Text(item['subtitle']!),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(lessonTitle: item['title']!, lessonContent: item['content']!),
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

/// Lesson placeholder
class LessonScreen extends StatelessWidget {
  final String lessonTitle;
  final String lessonContent;

  const LessonScreen({required this.lessonTitle, required this.lessonContent, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lessonTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lessonTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          Expanded(child: SingleChildScrollView(child: Text(lessonContent, style: const TextStyle(fontSize: 16)))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lição concluída (placeholder)')));
                  Navigator.of(context).pop();
                },
                child: const Text('Concluir Lição'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// RecommendedAllScreen recebe o ViewModel por parâmetro para evitar Provider errors
class RecommendedAllScreen extends StatelessWidget {
  final LearnPracticeViewModel vm;
  const RecommendedAllScreen({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    final items = vm.recommendedExercises;
    return Scaffold(
      appBar: AppBar(title: const Text('Recomendados para Você')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final exercise = Map<String, dynamic>.from(items[i] as Map);
            final title = exercise['title'] as String? ?? 'Exercício';
            final desc = exercise['description'] as String? ?? '';
            final duration = exercise['duration'] as String? ?? '';
            final isNew = exercise['isNew'] as bool? ?? false;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))), if (isNew) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)), child: const Text('NOVO', style: TextStyle(color: Colors.white, fontSize: 10)))]),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 6),
                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      duration,
                      style: TextStyle(
                        color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ]),
                ]),
                trailing: ElevatedButton(
                  onPressed: () {
                    try {
                      vm.startExercise(context, i);
                    } catch (_) {}
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(lessonTitle: title, lessonContent: desc),
                      ),
                    );
                  },
                  child: const Text('Iniciar'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
