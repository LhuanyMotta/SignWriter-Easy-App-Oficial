import 'package:flutter/material.dart';
import 'package:signwriter_easy_app_oficial/views/screens/auth_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/home_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/learn_practice_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/write_signs_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/translate_signs_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/chat_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/dictionary_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/progress_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/favorites_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/profile_screen.dart';

class AppRoutes {
  // Nome das rotas
  static const String auth = '/auth';
  static const String home = '/home';
  static const String learnPractice = '/learn-practice';
  static const String writeSigns = '/write-signs';
  static const String translateSigns = '/translate-signs';
  static const String chat = '/chat';
  static const String dictionary = '/dictionary';
  static const String progress = '/progress';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // Mapeamento das rotas
  static Map<String, WidgetBuilder> get routes {
    return {
      auth: (context) => const AuthScreen(),
      home: (context) => const HomeScreen(),
      learnPractice: (context) => const LearnPracticeScreen(),
      writeSigns: (context) => const WriteSignsScreen(),
      translateSigns: (context) => const TranslateSignsScreen(),
      chat: (context) => const ChatScreen(),
      dictionary: (context) => const DictionaryScreen(),
      progress: (context) => const ProgressScreen(),
      favorites: (context) => const FavoritesScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }

  // Método para navegação fácil
  static Future<void> navigateTo(BuildContext context, String routeName) {
    return Navigator.pushNamed(context, routeName);
  }

  // Método para navegação com replace (sem voltar)
  static Future<void> navigateReplacement(BuildContext context, String routeName) {
    return Navigator.pushReplacementNamed(context, routeName);
  }

  // Método para voltar
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}