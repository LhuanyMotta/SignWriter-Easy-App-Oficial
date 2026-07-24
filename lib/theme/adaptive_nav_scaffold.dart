import 'package:flutter/material.dart';
import 'responsive.dart';

/// Scaffold com navegação que se adapta à largura da tela:
/// - Celular (estreito): `BottomNavigationBar`, do jeito que já era.
/// - Web/desktop (largo): `NavigationRail` lateral, sem nada embaixo.
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

  const AdaptiveNavScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabSelected,
    required this.homeLabel,
    required this.profileLabel,
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101826) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              extended: true,
              minExtendedWidth: 200,
              selectedIndex: currentIndex,
              groupAlignment: -1.0,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/signwriter_logo.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SignWriter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
              selectedIconTheme: IconThemeData(color: primary),
              selectedLabelTextStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
              unselectedIconTheme: IconThemeData(color: Colors.grey[500]),
              unselectedLabelTextStyle: TextStyle(color: Colors.grey[500]),
              useIndicator: true,
              indicatorColor: primary.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onDestinationSelected: onTabSelected,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(homeLabel),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(profileLabel),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
