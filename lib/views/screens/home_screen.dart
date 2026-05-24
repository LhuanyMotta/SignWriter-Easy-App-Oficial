import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'profile_screen.dart';
import '../../theme/app_spacing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeViewModel _viewModel = HomeViewModel();

  int _currentBottomIndex = 0;
  late TabController _tabController;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? const Color(0xFF08111F) : const Color(0xFFF5F7FB);

  Color get cardColor =>
      isDark ? const Color(0xFF121C2B) : Colors.white;

  Color get textColor =>
      isDark ? Colors.white : const Color(0xFF1E1E1E);

  Color get subtitleColor =>
      isDark ? Colors.white70 : Colors.black54;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D78BB),
        elevation: 0,
        title: const Text(
          'SignWriter Fácil',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(child: FittedBox(child: Text('Início'))),
            Tab(child: FittedBox(child: Text('Dicionário'))),
            Tab(child: FittedBox(child: Text('Traduzir'))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildDictionaryTab(),
          _buildTranslateTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        backgroundColor: isDark ? const Color(0xFF101826) : Colors.white,
        selectedItemColor: const Color(0xFF2D78BB),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
          _viewModel.onBottomNavTapped(index, context);
        },
        items: [
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
    );
  }

  Widget _buildHomeTab() {
  final List<Map<String, dynamic>> features = [
    {
      'title': 'Aprender e Praticar',
      'icon': Icons.school,
      'color': const Color(0xFF2D78BB),
      'onTap': () =>
          _viewModel.navigateToLearnAndPractice(context),
    },
    {
      'title': 'Escrever Sinais',
      'icon': Icons.edit_document,
      'color': const Color(0xFF4EB1F0),
      'onTap': () =>
          _viewModel.navigateToWriteSigns(context),
    },
    {
      'title': 'Traduzir Sinais',
      'icon': Icons.translate,
      'color': const Color(0xFF2D78BB),
      'onTap': () =>
          _viewModel.navigateToTranslateSigns(context),
    },
    {
      'title': 'Dicionário',
      'icon': Icons.book,
      'color': const Color(0xFF4EB1F0),
      'onTap': () =>
          _viewModel.navigateToDictionary(context),
    },
  ];

  return SingleChildScrollView(
    padding: AppSpacing.all(context, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo!',
          style: TextStyle(
            color: const Color(0xFF2D78BB),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: AppSpacing.value(context, 6)),

        Text(
          'O que você deseja fazer hoje?',
          style: TextStyle(
            color: subtitleColor,
            fontSize: 16,
          ),
        ),

        SizedBox(height: AppSpacing.value(context, 26)),

        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = AppSpacing.value(context, 16);
            final cardWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: features.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: Material(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(22),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: item['onTap'] as VoidCallback,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: AppSpacing.value(context, 150),
                        ),
                        padding: AppSpacing.symmetric(
                          context,
                          horizontal: 12,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: AppSpacing.value(context, 42),
                              color: Colors.white,
                            ),
                            SizedBox(height: AppSpacing.value(context, 16)),
                            Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 5,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
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
        ),
      ],
    ),
  );
}

  Widget _buildDictionaryTab() {
    return Padding(
      padding: AppSpacing.all(context, 18),
      child: _buildInfoCard(
        icon: Icons.menu_book,
        title: 'Dicionário de Sinais',
        description: 'Consulte sinais cadastrados no Supabase.',
        buttonText: 'Abrir Dicionário',
        onTap: () => _viewModel.navigateToDictionary(context),
      ),
    );
  }

  Widget _buildTranslateTab() {
    return Padding(
      padding: AppSpacing.all(context, 18),
      child: _buildInfoCard(
        icon: Icons.translate,
        title: 'Traduzir Sinais',
        description: 'Digite uma palavra ou frase para buscar sinais correspondentes.',
        buttonText: 'Abrir Tradutor',
        onTap: () => _viewModel.navigateToTranslateSigns(context),
      ),
    );
  }

  Widget _buildMainButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF2D78BB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 135,
          padding: AppSpacing.all(context, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 34),
              SizedBox(height: AppSpacing.value(context, 12)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.all(context, 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 42, color: const Color(0xFF2D78BB)),
          SizedBox(height: AppSpacing.value(context, 18)),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 10)),
          Text(
            description,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 15,
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D78BB),
                foregroundColor: Colors.white,
                padding: AppSpacing.symmetric(context, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
