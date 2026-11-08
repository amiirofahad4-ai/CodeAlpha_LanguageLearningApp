import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the 5 main tabs with a bottom navigation bar. Each tab keeps its
/// own navigation stack (StatefulShellRoute).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
      label: 'Learn',
    ),
    NavigationDestination(
      icon: Icon(Icons.quiz_outlined),
      selectedIcon: Icon(Icons.quiz_rounded),
      label: 'Quiz',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights_rounded),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab again returns to its first page.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
