import 'package:flutter/material.dart';
import 'responsive.dart';
import '../routes/app_routes.dart';

/// Scaffold com navegação que se adapta à largura da tela:
/// - Celular (estreito): `BottomNavigationBar`, do jeito que já era.
/// - Web/desktop (largo): sidebar lateral tradicional, sem nada embaixo.
///
/// Usado pelas telas que ficam nas abas principais (Início, Perfil...),
/// pra não repetir essa lógica em cada uma.
class AdaptiveNavScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final String homeLabel;
  final String profileLabel;
  final String currentRoute;
  final Widget? floatingActionButton;

  const AdaptiveNavScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabSelected,
    required this.homeLabel,
    required this.profileLabel,
    this.currentRoute = AppRoutes.home,
    this.floatingActionButton,
    this.appBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    if (!Responsive.isWide(context)) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: isDark ? const Color(0xFF101826) : Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,
          onTap: onTabSelected,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home), label: homeLabel),
            BottomNavigationBarItem(icon: const Icon(Icons.person), label: profileLabel),
          ],
        ),
      );
    }

    final railColor = isDark ? const Color(0xFF101826) : Colors.white;
    final contentColor = isDark ? const Color(0xFF08111F) : const Color(0xFFF5F7FB);
    final scrollbarColor = isDark
        ? Colors.white.withValues(alpha: 0.42)
        : primary.withValues(alpha: 0.58);

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(scrollbarColor),
        trackColor: WidgetStatePropertyAll(
          isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(4),
        crossAxisMargin: 2,
        mainAxisMargin: 2,
      ),
      child: Scaffold(
        backgroundColor: contentColor,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: railColor,
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/images/signwriter_logo.png'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'SignWriter Fácil',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _WebNavSectionLabel(label: 'PRINCIPAL', isDark: isDark),
                        _WebNavItem(
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home,
                          label: homeLabel,
                          selected: currentRoute == AppRoutes.home,
                          color: primary,
                          isDark: isDark,
                          onTap: () => onTabSelected(0),
                        ),
                        const SizedBox(height: 8),
                        _WebNavSectionLabel(label: 'FUNCIONALIDADES', isDark: isDark),
                        _WebNavItem(
                          icon: Icons.school_outlined,
                          selectedIcon: Icons.school,
                          label: 'Aprender e Praticar',
                          selected: currentRoute == AppRoutes.learnPractice,
                          color: primary,
                          isDark: isDark,
                          onTap: () => _goTo(context, AppRoutes.learnPractice),
                        ),
                        _WebNavItem(
                          icon: Icons.edit_note_outlined,
                          selectedIcon: Icons.edit_note,
                          label: 'Escrever Sinais',
                          selected: currentRoute == AppRoutes.writeSigns,
                          color: primary,
                          isDark: isDark,
                          onTap: () => _goTo(context, AppRoutes.writeSigns),
                        ),
                        _WebNavItem(
                          icon: Icons.translate_outlined,
                          selectedIcon: Icons.translate,
                          label: 'Traduzir Sinais',
                          selected: currentRoute == AppRoutes.translateSigns,
                          color: primary,
                          isDark: isDark,
                          onTap: () => _goTo(context, AppRoutes.translateSigns),
                        ),
                        _WebNavItem(
                          icon: Icons.menu_book_outlined,
                          selectedIcon: Icons.menu_book,
                          label: 'Dicionário',
                          selected: currentRoute == AppRoutes.dictionary,
                          color: primary,
                          isDark: isDark,
                          onTap: () => _goTo(context, AppRoutes.dictionary),
                        ),
                        const SizedBox(height: 16),
                        _WebNavSectionLabel(label: 'CONTA', isDark: isDark),
                        _WebNavItem(
                          icon: Icons.person_outline,
                          selectedIcon: Icons.person,
                          label: profileLabel,
                          selected: currentRoute == AppRoutes.profile,
                          color: primary,
                          isDark: isDark,
                          onTap: () => onTabSelected(1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(child: body),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _goTo(BuildContext context, String route) {
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

class _WebNavSectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _WebNavSectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black45,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _WebNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _WebNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? color
        : (isDark ? Colors.white.withValues(alpha: 0.62) : const Color(0xFF667085));

    return Material(
      color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withValues(alpha: 0.08),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(selected ? selectedIcon : icon, color: foreground, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
