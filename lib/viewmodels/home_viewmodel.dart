import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class HomeViewModel {
  void navigateToLearnAndPractice(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.learnPractice);
  }

  void navigateToDictionary(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.dictionary);
  }

  void navigateToWriteSigns(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.writeSigns);
  }

  void navigateToTranslateSigns(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.translateSigns);
  }

  void navigateToProfile(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.profile);
  }

  void onBottomNavTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        AppRoutes.navigateReplacement(context, AppRoutes.home);
        break;
      case 1:
        navigateToProfile(context);
        break;
    }
  }
}
