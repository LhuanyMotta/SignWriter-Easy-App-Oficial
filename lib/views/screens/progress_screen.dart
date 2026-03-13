import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/progress_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';

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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.progressTitle),
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
            indicatorColor: theme.colorScheme.onPrimary,
            tabs: [
              Tab(text: l10n.summaryTab),
              Tab(text: l10n.categoriesTab),
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
        final spacing = Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;
        final usageData = viewModel.usageData;
        return SingleChildScrollView(
          padding: EdgeInsets.all(16 * spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progresso geral (dados reais serão integrados depois)
              _buildProgressCard(
                title: context.l10n.overallProgress,
                progress: viewModel.overallProgress,
                showPercentage: true,
              ),
              
              SizedBox(height: 24 * spacing),
              
              // Estatísticas (valores zerados até integração real)
              Text(
                context.l10n.statsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16 * spacing),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: context.l10n.streakDays,
                    value: '${usageData['diasConsecutivos']}',
                    icon: Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _buildStatCard(
                    title: context.l10n.studyHours,
                    value: '${usageData['totalHorasEstudo']}',
                    icon: Icons.access_time,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  _buildStatCard(
                    title: context.l10n.exercises,
                    value: '${usageData['exerciciosCompletados']}',
                    icon: Icons.assignment_turned_in,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  _buildStatCard(
                    title: context.l10n.learnedSigns,
                    value: '${usageData['sinaisAprendidos']}',
                    icon: Icons.sign_language,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),

              SizedBox(height: 24 * spacing),
              
              // Gráfico de tempo de estudo
              Text(
                context.l10n.weeklyStudyTime,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8 * spacing),
              Text(
                context.l10n.bestDayPrefix(
                  _localizedDay(viewModel.bestStudyDay),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16 * spacing),
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
          return _buildEmptyState(context.l10n.emptyCategories);
        }
        return ListView.builder(
          padding: EdgeInsets.all(16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
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
      padding: EdgeInsets.all(16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
          
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
                      backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                      strokeWidth: 10,
                    ),
                    Text(
                      showPercentage ? '${(progress * 100).toInt()}%' : '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estrutura mantida com valores zerados até integração real.
                  _ProgressDetail(label: context.l10n.completedLessons, value: '0/0'),
                  SizedBox(height: 8 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
                  _ProgressDetail(label: context.l10n.totalStudyTime, value: '0h 0min'),
                  SizedBox(height: 8 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
                  _ProgressDetail(label: context.l10n.completedExercises, value: '0'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTimeChart(Map<String, double> studyTimeStats) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final weekDay = _dayNameByIndex(group.x.toInt());
              return BarTooltipItem(
                '$weekDay\n${rod.toY.toInt()} min',
                TextStyle(color: theme.colorScheme.onSurface),
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
                  color: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                final text = _dayShortByIndex(value.toInt());
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
                    color: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
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
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
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
      margin: EdgeInsets.only(bottom: 16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
      padding: EdgeInsets.all(16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
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
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
      padding: EdgeInsets.all(16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
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
        style: TextStyle(
          color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
              Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _localizedDay(String day) {
    switch (day) {
      case 'Segunda':
      case 'Monday':
        return context.l10n.monday;
      case 'Terça':
      case 'Tuesday':
        return context.l10n.tuesday;
      case 'Quarta':
      case 'Wednesday':
        return context.l10n.wednesday;
      case 'Quinta':
      case 'Thursday':
        return context.l10n.thursday;
      case 'Sexta':
      case 'Friday':
        return context.l10n.friday;
      case 'Sábado':
      case 'Saturday':
        return context.l10n.saturday;
      case 'Domingo':
      case 'Sunday':
        return context.l10n.sunday;
      default:
        return context.l10n.noData;
    }
  }

  String _dayNameByIndex(int index) {
    switch (index) {
      case 0:
        return context.l10n.monday;
      case 1:
        return context.l10n.tuesday;
      case 2:
        return context.l10n.wednesday;
      case 3:
        return context.l10n.thursday;
      case 4:
        return context.l10n.friday;
      case 5:
        return context.l10n.saturday;
      case 6:
        return context.l10n.sunday;
      default:
        return '';
    }
  }

  String _dayShortByIndex(int index) {
    switch (index) {
      case 0:
        return context.l10n.mondayShort;
      case 1:
        return context.l10n.tuesdayShort;
      case 2:
        return context.l10n.wednesdayShort;
      case 3:
        return context.l10n.thursdayShort;
      case 4:
        return context.l10n.fridayShort;
      case 5:
        return context.l10n.saturdayShort;
      case 6:
        return context.l10n.sundayShort;
      default:
        return '';
    }
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
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