import 'package:flutter/material.dart';
import '../views/screens/write_signs_screen.dart';
import '../views/screens/translate_signs_screen.dart';
import '../views/screens/learn_practice_screen.dart';
import '../views/screens/dictionary_screen.dart';
import '../views/screens/chat_screen.dart';
import '../views/screens/progress_screen.dart';
import '../views/screens/profile_screen.dart';
import '../views/screens/favorites_screen.dart';
import '../views/screens/home_screen.dart';

/// ViewModel para a tela inicial
/// Responsável pela lógica de navegação e interação da tela home
class HomeViewModel {
  /// Navega para a tela de Aprender e Praticar
  void navigateToLearnAndPractice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LearnPracticeScreen()),
    );
    // Futuramente, também poderia:
    // - Registrar o acesso no banco de dados
    // - Carregar dados de progresso do usuário
  }

  /// Navega para a tela de Escrever Sinais
  void navigateToWriteSigns(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WriteSignsScreen()),
    );
  }

  /// Navega para a tela de Traduzir Sinais
  void navigateToTranslateSigns(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TranslateSignsScreen()),
    );
  }

  /// Navega para a tela de Conversar
  void navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  /// Navega para a tela de Dicionário
  void navigateToDictionary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DictionaryScreen(),
      ),
    );
    // Futuramente:
    // - Carregar dados do dicionário do banco local
  }

  /// Navega para a tela de Progresso
  void navigateToProgress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProgressScreen()),
    );
    // Futuramente:
    // - Buscar dados de progresso no banco
    // - Atualizar estatísticas
  }

  /// Navega para a tela de Favoritos
  void navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
    );
  }
  
  /// Navega para a tela de Perfil
  void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  /// Manipula o toque na barra de navegação inferior
  void onBottomNavTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        // Navega para a tela inicial
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        navigateToFavorites(context);
        break;
      case 2:
        navigateToProfile(context);
        break;
    }
  }
} 