import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel _viewModel = HomeViewModel();

  int _currentBottomIndex = 0;

  static const _primary = Color(0xFF2D78BB);
  static const _secondary = Color(0xFF4EB1F0);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? const Color(0xFF08111F) : const Color(0xFFF5F7FB);

  Color get cardColor => isDark ? const Color(0xFF121C2B) : Colors.white;

  Color get textColor => isDark ? Colors.white : const Color(0xFF1E1E1E);

  Color get subtitleColor => isDark ? Colors.white70 : Colors.black54;

  Color get borderColor => isDark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.06);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: Text(
          context.l10n.appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildHomeTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        backgroundColor: isDark ? const Color(0xFF101826) : Colors.white,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
          _viewModel.onBottomNavTapped(index, context);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: context.l10n.bottomHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: context.l10n.bottomFavorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: context.l10n.bottomProfile,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTEÚDO PRINCIPAL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHomeTab() {
    final List<_FeatureData> features = [
      _FeatureData(
        title: context.l10n.featureLearnPractice,
        icon: Icons.school_rounded,
        colors: const [_primary, Color(0xFF1A5A9A)],
        onTap: () => _viewModel.navigateToLearnAndPractice(context),
      ),
      _FeatureData(
        title: context.l10n.featureWriteSigns,
        icon: Icons.edit_document,
        colors: const [_secondary, _primary],
        onTap: () => _viewModel.navigateToWriteSigns(context),
      ),
      _FeatureData(
        title: context.l10n.featureTranslateSigns,
        icon: Icons.translate_rounded,
        colors: const [_primary, _secondary],
        onTap: () => _viewModel.navigateToTranslateSigns(context),
      ),
      _FeatureData(
        title: context.l10n.featureDictionary,
        icon: Icons.menu_book_rounded,
        colors: const [Color(0xFF1A5A9A), _primary],
        onTap: () => _viewModel.navigateToDictionary(context),
      ),
    ];

    return SingleChildScrollView(
      padding: AppSpacing.all(context, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.homeWelcome,
            style: TextStyle(
              color: _primary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 6)),
          Text(
            context.l10n.homeQuestion,
            style: TextStyle(color: subtitleColor, fontSize: 16),
          ),
          SizedBox(height: AppSpacing.value(context, 26)),

          // ─── Grade de funcionalidades ──────────────────────────
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
                    child: _buildFeatureCard(item),
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: AppSpacing.value(context, 32)),

          // ─── Como funciona o SignWriting ────────────────────────
          _buildSectionLabel('COMO FUNCIONA O SIGNWRITING'),
          SizedBox(height: AppSpacing.value(context, 12)),
          _buildHowItWorks(),

          SizedBox(height: AppSpacing.value(context, 32)),

          // ─── Sobre o Projeto ─────────────────────────────────
          _buildSectionLabel('SOBRE O PROJETO'),
          SizedBox(height: AppSpacing.value(context, 12)),
          _buildAboutProject(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: subtitleColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureData item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: item.colors.first.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppSpacing.value(context, 56),
                height: AppSpacing.value(context, 56),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: AppSpacing.value(context, 28),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              Text(
                item.title,
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
    );
  }

  // Explicação visual de como funciona o SignWriting — diferencial educativo do app
  Widget _buildHowItWorks() {
    final steps = [
      _HowStep(
        icon: Icons.front_hand_rounded,
        title: 'Configuração de Mão',
        description: 'A forma exata dos dedos durante o sinal',
        color: _primary,
      ),
      _HowStep(
        icon: Icons.gesture_rounded,
        title: 'Movimento',
        description: 'Setas mostram a direção e trajetória da mão',
        color: _secondary,
      ),
      _HowStep(
        icon: Icons.face_retouching_natural_rounded,
        title: 'Expressão Facial',
        description: 'O rosto também é gramática em Libras',
        color: const Color(0xFF1A5A9A),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: AppSpacing.all(context, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todo sinal combina três elementos visuais:',
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.value(context, 16)),
          ...steps.asMap().entries.map((e) {
            final isLast = e.key == steps.length - 1;
            final step = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.value(context, 16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.value(context, 38),
                    height: AppSpacing.value(context, 38),
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(step.icon, color: step.color, size: AppSpacing.value(context, 19)),
                  ),
                  SizedBox(width: AppSpacing.value(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: AppSpacing.value(context, 2)),
                        Text(
                          step.description,
                          style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: AppSpacing.value(context, 16)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _viewModel.navigateToLearnAndPractice(context),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Aprender mais sobre SignWriting'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(color: _primary.withValues(alpha: 0.4)),
                padding: AppSpacing.symmetric(context, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sobre o Projeto ────────────────────────────────────────────
  Widget _buildAboutProject() {
    return Column(
      children: [
        // Card principal com gradiente — apresentação do app
        Container(
          width: double.infinity,
          padding: AppSpacing.all(context, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primary, Color(0xFF1A5A9A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSpacing.value(context, 44),
                    height: AppSpacing.value(context, 44),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.sign_language_rounded,
                      color: Colors.white,
                      size: AppSpacing.value(context, 24),
                    ),
                  ),
                  SizedBox(width: AppSpacing.value(context, 14)),
                  const Expanded(
                    child: Text(
                      'SignWriter Fácil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.value(context, 14)),
              Text(
                'Desenvolvido por estudantes voluntários do Instituto Federal de Rondônia (IFRO), Campus Ji-Paraná, para promover a inclusão da comunidade surda através do SignWriting.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              Wrap(
                spacing: AppSpacing.value(context, 8),
                runSpacing: AppSpacing.value(context, 8),
                children: const [
                  _Chip('IFRO · Ji-Paraná'),
                  _Chip('Libras'),
                  _Chip('SignWriting'),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: AppSpacing.value(context, 14)),

        // Equipe — Lhuany e Bruno em destaque
        Row(
          children: [
            Expanded(
              child: _buildDevCard(
                initials: 'LT',
                name: 'Lhuany Thainara',
                role: 'Aluna Voluntária',
                color: _primary,
              ),
            ),
            SizedBox(width: AppSpacing.value(context, 10)),
            Expanded(
              child: _buildDevCard(
                initials: 'BS',
                name: 'Bruno Santos',
                role: 'Aluno Voluntário',
                color: const Color(0xFF1A5A9A),
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.value(context, 10)),

        // Orientadora
        Container(
          width: double.infinity,
          padding: AppSpacing.symmetric(context, horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.value(context, 42),
                height: AppSpacing.value(context, 42),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'IL',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.value(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dra. Ilma Rodrigues de Souza Fausto',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Orientadora do Projeto',
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDevCard({
    required String initials,
    required String name,
    required String role,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.all(context, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.value(context, 44),
            height: AppSpacing.value(context, 44),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSpacing.value(context, 16),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 12)),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 2)),
          Text(
            role,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

}

class _HowStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HowStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureData {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _FeatureData({
    required this.title,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}