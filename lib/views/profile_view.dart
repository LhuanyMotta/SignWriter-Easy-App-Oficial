import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Seção de Informações do Usuário
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(viewModel.userData['nome']),
                  subtitle: Text(viewModel.userData['email']),
                ),
              ),
              const SizedBox(height: 16),
              
              // Seção de Configurações
              const Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Acessibilidade
              Card(
                child: ListTile(
                  leading: const Icon(Icons.accessibility_new),
                  title: const Text('Acessibilidade'),
                  subtitle: const Text('Configurações no Perfil'),
                  trailing: const Icon(Icons.check_circle_outline),
                  onTap: null,
                ),
              ),
              
              // Notificações
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Notificações'),
                  subtitle: const Text('Receber notificações do app'),
                  value: viewModel.notificationsEnabled,
                  onChanged: viewModel.toggleNotifications,
                ),
              ),
              
              // Tema Escuro
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Tema Escuro'),
                  subtitle: const Text('Alternar entre tema claro e escuro'),
                  value: viewModel.darkMode,
                  onChanged: viewModel.toggleDarkMode,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 