import 'package:flutter/material.dart';
import 'package:test_app_new/Quran_Section/views/quran_index_screen.dart';
import 'package:test_app_new/azkr_section/views/azkarCategori_Screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    QuranIndexScreen(),
    AzkarCategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "المصحف"),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "الأذكار",
          ),
        ],
      ),
    );
  }
}
