import 'package:flutter/material.dart';

import '../views/screens/home_screen.dart';
import '../views/screens/learn_practice_screen.dart';
import '../views/screens/dictionary_screen.dart';
import '../views/screens/write_signs_screen.dart';
import '../views/screens/translate_signs_screen.dart';
import '../views/screens/favorites_screen.dart';
import '../views/screens/profile_screen.dart';

class HomeViewModel {
  void navigateToLearnAndPractice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LearnPracticeScreen()),
    );
  }

  void navigateToDictionary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DictionaryScreen()),
    );
  }

  void navigateToWriteSigns(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WriteSignsScreen()),
    );
  }

  void navigateToTranslateSigns(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TranslateSignsScreen()),
    );
  }

  void navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void onBottomNavTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
