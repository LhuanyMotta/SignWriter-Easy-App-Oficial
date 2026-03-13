import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../l10n/l10n.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/feature_card.dart';

/// Tela inicial do aplicativo
/// Exibe os principais recursos disponíveis em formato de grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel _viewModel = HomeViewModel();
  int _currentIndex = 0;

  // Lista de funcionalidades com informações para exibição
  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.school,
      'color': const Color(0xFF2D78BB),
    },
    {
      'icon': Icons.edit_document,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'icon': Icons.translate,
      'color': const Color(0xFF2D78BB),
    },
    {
      'icon': Icons.chat,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'icon': Icons.book,
      'color': const Color(0xFF2D78BB),
    },
    {
      'icon': Icons.bar_chart,
      'color': const Color(0xFF4EB1F0),
    },
  ];

  // Funções de navegação correspondentes às funcionalidades
  final List<Function(BuildContext)> _navigationFunctions = [];

  @override
  void initState() {
    super.initState();
    // Inicializa a lista de funções de navegação
    _navigationFunctions.addAll([
      _viewModel.navigateToLearnAndPractice,
      _viewModel.navigateToWriteSigns,
      _viewModel.navigateToTranslateSigns,
      _viewModel.navigateToChat,
      _viewModel.navigateToDictionary,
      _viewModel.navigateToProgress,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Engrenagem leva para o perfil, onde ficam as configurações de acessibilidade
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _viewModel.navigateToProfile(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de boas-vindas
              Text(
                l10n.homeWelcome,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeQuestion,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              
              // Grid de funcionalidades usando GridView.builder para código mais conciso
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1, // Ajusta proporção dos cards
                  ),
                  itemCount: _features.length,
                  itemBuilder: (context, index) => FeatureCard(
                    title: _featureTitle(index, l10n),
                    icon: _features[index]['icon'],
                    color: _features[index]['color'],
                    onTap: (ctx) => _navigationFunctions[index](ctx),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _viewModel.onBottomNavTapped(index, context);
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.bottomHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.bottomFavorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.bottomProfile,
          ),
        ],
      ),
    );
  }

  String _featureTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.featureLearnPractice;
      case 1:
        return l10n.featureWriteSigns;
      case 2:
        return l10n.featureTranslateSigns;
      case 3:
        return l10n.featureChat;
      case 4:
        return l10n.featureDictionary;
      case 5:
        return l10n.featureProgress;
      default:
        return '';
    }
  }
} 