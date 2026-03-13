import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/screens/auth_screen.dart';
import 'views/screens/home_screen.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/app_settings_viewmodel.dart';
import 'services/database_seed_service.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseSeedService().seedDatabaseIfEmpty();
  final appSettings = AppSettingsViewModel();
  await appSettings.loadPreferences();
  runApp(MyApp(appSettings: appSettings));
}

class MyApp extends StatelessWidget {
  final AppSettingsViewModel appSettings;

  const MyApp({super.key, required this.appSettings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<AppSettingsViewModel>.value(value: appSettings),
      ],
      child: Consumer<AppSettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'SignWriter Fácil',
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: settings.themeMode,
            theme: AppTheme.light(
              fontScale: settings.fontScale,
              contrastLevel: settings.contrastLevel,
              spacingScale: settings.spacingScale,
            ),
            darkTheme: AppTheme.dark(
              fontScale: settings.fontScale,
              contrastLevel: settings.contrastLevel,
              spacingScale: settings.spacingScale,
            ),
            initialRoute: '/auth',
            routes: {
              '/auth': (context) => const AuthScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
