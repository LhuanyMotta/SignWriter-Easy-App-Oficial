import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/progress_viewmodel.dart';
import '../../theme/app_spacing.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu Progresso'),
          backgroundColor: const Color(0xFF2D78BB),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<ProgressViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: AppSpacing.all(context, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo geral
                  _buildProgressSummary(viewModel),
                  
                  SizedBox(height: AppSpacing.value(context, 24)),
                  
                  // Estatísticas
                  Text(
                    '📊 Estatísticas de Estudo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: AppSpacing.value(context, 16)),
                  
                  _buildStudyStatsGrid(viewModel),
                  
                  SizedBox(height: AppSpacing.value(context, 24)),
                  
                  // Progresso por categoria
                  Text(
                    '📚 Progresso por Categoria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: AppSpacing.value(context, 16)),
                  
                  ...viewModel.categoryProgress.map((category) {
                    return _buildCategoryCard(category);
                  }).toList(),
                  
                  SizedBox(height: AppSpacing.value(context, 24)),
                  
                  // Conquistas
                  Text(
                    '🏆 Conquistas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: AppSpacing.value(context, 16)),
                  
                  _buildAchievementsSection(viewModel),
                  
                  SizedBox(height: AppSpacing.value(context, 32)),
                  
                  // Botões de ação
                  _buildActionButtons(context, viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSummary(ProgressViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: AppSpacing.all(context, 20),
        child: Column(
          children: [
            const Text(
              'Seu Progresso Geral',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D78BB),
              ),
            ),
            SizedBox(height: AppSpacing.value(context, 16)),
            
            // Barra de progresso
            LinearProgressIndicator(
              value: viewModel.overallProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D78BB)),
              borderRadius: BorderRadius.circular(10),
              minHeight: 20,
            ),
            SizedBox(height: AppSpacing.value(context, 12)),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(viewModel.overallProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${viewModel.usageData['sinaisAprendidos']} sinais aprendidos',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyStatsGrid(ProgressViewModel viewModel) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Dias Consecutivos',
          value: '${viewModel.usageData['diasConsecutivos']}',
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Horas de Estudo',
          value: '${viewModel.usageData['totalHorasEstudo']}h',
          icon: Icons.timer,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Exercícios',
          value: '${viewModel.usageData['exerciciosCompletados']}',
          icon: Icons.check_circle,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Média Diária',
          value: '${viewModel.averageStudyTime.toStringAsFixed(0)}min',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: AppSpacing.all(context, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: AppSpacing.value(context, 8)),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: AppSpacing.value(context, 4)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final String name = category['name'] as String;
    final double progress = category['progress'] as double;
    final Color color = category['color'] as Color;
    
    return Card(
      margin: AppSpacing.only(context, bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: AppSpacing.all(context, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: AppSpacing.symmetric(context, horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.value(context, 12)),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(6),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(ProgressViewModel viewModel) {
    final unlockedCount = viewModel.unlockedAchievementsCount;
    final totalCount = viewModel.achievements.length;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: AppSpacing.all(context, 16),
        child: Column(
          children: [
            // Cabeçalho das conquistas
            Container(
              padding: AppSpacing.all(context, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D78BB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFF2D78BB), size: 32),
                  SizedBox(width: AppSpacing.value(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conquistas Desbloqueadas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: AppSpacing.value(context, 4)),
                        Text(
                          '$unlockedCount de $totalCount conquistas',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: AppSpacing.value(context, 8)),
                        LinearProgressIndicator(
                          value: viewModel.achievementsPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D78BB)),
                          borderRadius: BorderRadius.circular(6),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.value(context, 16)),
            
            // Lista de conquistas
            ...viewModel.achievements.map((achievement) {
              final bool unlocked = achievement['unlocked'] as bool;
              final IconData icon = achievement['icon'] as IconData;
              
              return Container(
                margin: AppSpacing.only(context, bottom: 8),
                padding: AppSpacing.all(context, 12),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.green[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unlocked ? Colors.green[100]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: unlocked ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    SizedBox(width: AppSpacing.value(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: unlocked ? Colors.green[800] : Colors.grey,
                            ),
                          ),
                          SizedBox(height: AppSpacing.value(context, 2)),
                          Text(
                            achievement['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: unlocked ? Colors.green[600] : Colors.grey,
                            ),
                          ),
                          if (unlocked && achievement['date'] != null)
                            Padding(
                              padding: AppSpacing.only(context, top: 4),
                              child: Text(
                                'Desbloqueado: ${achievement['date']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      unlocked ? Icons.check_circle : Icons.lock,
                      color: unlocked ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProgressViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => viewModel.shareProgress(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D78BB),
              foregroundColor: Colors.white,
              padding: AppSpacing.symmetric(context, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar Progresso'),
          ),
        ),
        SizedBox(width: AppSpacing.value(context, 12)),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => viewModel.exportProgressData(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D78BB),
              padding: AppSpacing.symmetric(context, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2D78BB)),
              ),
            ),
            icon: const Icon(Icons.download),
            label: const Text('Exportar Dados'),
          ),
        ),
      ],
    );
  }
}
