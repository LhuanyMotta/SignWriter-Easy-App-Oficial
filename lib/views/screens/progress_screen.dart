import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/progress_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

/// Tela de Progresso do usuário
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProgressViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProgressViewModel();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seu Progresso'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _viewModel.shareProgress(context),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _viewModel.exportProgressData(context),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Resumo'),
              Tab(text: 'Categorias'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSummaryTab(),
            _buildCategoriesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<ProgressViewModel>(
      builder: (context, viewModel, child) {
        final usageData = viewModel.usageData;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progresso geral (dados reais serão integrados depois)
              _buildProgressCard(
                title: 'Progresso Geral',
                progress: viewModel.overallProgress,
                showPercentage: true,
              ),
              
              const SizedBox(height: 24),
              
              // Estatísticas (valores zerados até integração real)
              Text(
                'Estatísticas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Dias Consecutivos',
                    value: '${usageData['diasConsecutivos']}',
                    icon: Icons.calendar_today,
                    color: const Color(0xFF2D78BB),
                  ),
                  _buildStatCard(
                    title: 'Horas de Estudo',
                    value: '${usageData['totalHorasEstudo']}',
                    icon: Icons.access_time,
                    color: const Color(0xFF4EB1F0),
                  ),
                  _buildStatCard(
                    title: 'Exercícios',
                    value: '${usageData['exerciciosCompletados']}',
                    icon: Icons.assignment_turned_in,
                    color: const Color(0xFF4EB1F0),
                  ),
                  _buildStatCard(
                    title: 'Sinais Aprendidos',
                    value: '${usageData['sinaisAprendidos']}',
                    icon: Icons.sign_language,
                    color: const Color(0xFF2D78BB),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
              // Gráfico de tempo de estudo
              Text(
                'Tempo de Estudo Semanal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Melhor dia: ${viewModel.bestStudyDay}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildStudyTimeChart(viewModel.studyTimeStats),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<ProgressViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.categoryProgress.isEmpty) {
          return _buildEmptyState('Sem categorias com progresso ainda.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.categoryProgress.length,
          itemBuilder: (context, index) {
            final category = viewModel.categoryProgress[index];
            return _buildCategoryProgressItem(category);
          },
        );
      },
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double progress,
    bool showPercentage = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Indicador de progresso circular
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 10,
                    ),
                    Text(
                      showPercentage ? '${(progress * 100).toInt()}%' : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // Estrutura mantida com valores zerados até integração real.
                  _ProgressDetail(label: 'Aulas completadas', value: '0/0'),
                  SizedBox(height: 8),
                  _ProgressDetail(label: 'Tempo total de estudo', value: '0h 0min'),
                  SizedBox(height: 8),
                  _ProgressDetail(label: 'Exercícios concluídos', value: '0'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTimeChart(Map<String, double> studyTimeStats) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay = '';
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Segunda';
                  break;
                case 1:
                  weekDay = 'Terça';
                  break;
                case 2:
                  weekDay = 'Quarta';
                  break;
                case 3:
                  weekDay = 'Quinta';
                  break;
                case 4:
                  weekDay = 'Sexta';
                  break;
                case 5:
                  weekDay = 'Sábado';
                  break;
                case 6:
                  weekDay = 'Domingo';
                  break;
              }
              return BarTooltipItem(
                '$weekDay\n${rod.toY.toInt()} min',
                const TextStyle(color: Colors.black),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'Seg';
                    break;
                  case 1:
                    text = 'Ter';
                    break;
                  case 2:
                    text = 'Qua';
                    break;
                  case 3:
                    text = 'Qui';
                    break;
                  case 4:
                    text = 'Sex';
                    break;
                  case 5:
                    text = 'Sáb';
                    break;
                  case 6:
                    text = 'Dom';
                    break;
                }
                return Text(text, style: style);
              },
              reservedSize: 25,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 20 != 0) return const Text('');
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: [
          _buildBarGroup(0, studyTimeStats['Segunda'] ?? 0),
          _buildBarGroup(1, studyTimeStats['Terça'] ?? 0),
          _buildBarGroup(2, studyTimeStats['Quarta'] ?? 0),
          _buildBarGroup(3, studyTimeStats['Quinta'] ?? 0),
          _buildBarGroup(4, studyTimeStats['Sexta'] ?? 0),
          _buildBarGroup(5, studyTimeStats['Sábado'] ?? 0),
          _buildBarGroup(6, studyTimeStats['Domingo'] ?? 0),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Theme.of(context).colorScheme.primary,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgressItem(Map<String, dynamic> category) {
    final String name = category['name'] as String;
    final double progress = category['progress'] as double;
    final Color color = category['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(10),
            minHeight: 10,
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
} 

class _ProgressDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}