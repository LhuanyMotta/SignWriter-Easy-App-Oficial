import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/feature_card.dart';
import 'profile_screen.dart';

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
      'title': 'Aprender e Praticar',
      'icon': Icons.school,
      'color': const Color(0xFF2D78BB),
    },
    {
      'title': 'Escrever Sinais',
      'icon': Icons.edit_document,
      'color': const Color(0xFF4EB1F0),
    },
    {
      'title': 'Dicionário',
      'icon': Icons.book,
      'color': const Color(0xFF2D78BB),
    },
    {
      'title': 'Progresso',
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
      _viewModel.navigateToDictionary,
      _viewModel.navigateToProgress,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SignWriter Fácil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D78BB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navega para a tela de perfil, que contém as configurações
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
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
              // Título de boas-vindas - Estilo igual ao da imagem (AZUL)
              const Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D78BB), // AZUL como na imagem
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo - Estilo igual ao da imagem
              const Text(
                'O que você deseja fazer hoje?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666), // Cor cinza médio como na imagem
                ),
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
                    title: _features[index]['title'],
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
    );
  }
}