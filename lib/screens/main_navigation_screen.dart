import 'dart:developer';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'shared_screen.dart';
import 'create_memory_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import "timeline_screen.dart";

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  final PageController _pageController = PageController();

  int _selectedIndex = 0;

  // Create is NOT in here because it opens as its own screen.
  final List<Widget> _pages = const [
    HomeScreen(),
    TimelineScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    // CREATE
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreateMemoryScreen(),
        ),
      );

      return;
    }

    // NavigationBar indexes:
    // 0 = Home
    // 1 = Shared
    // 2 = Create
    // 3 = Search
    // 4 = Profile
    //
    // PageView indexes:
    // 0 = Home
    // 1 = Shared
    // 2 = Search
    // 3 = Profile

    final pageIndex = index > 2 ? index - 1 : index;

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int pageIndex) {
    final navIndex =
        pageIndex >= 2 ? pageIndex + 1 : pageIndex;

    setState(() {
      _selectedIndex = navIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.public),
            selectedIcon: Icon(Icons.public),
            label: 'Timeline',
          ),

          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),

          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}