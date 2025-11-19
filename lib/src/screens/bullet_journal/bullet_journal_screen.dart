import 'package:flutter/material.dart';

import 'widgets/diary_tab.dart';
import 'widgets/calendar_tab.dart';
import 'widgets/my_page_tab.dart';

class BulletJournalScreen extends StatefulWidget {
  const BulletJournalScreen({super.key});

  @override
  State<BulletJournalScreen> createState() => _BulletJournalScreenState();
}

class _BulletJournalScreenState extends State<BulletJournalScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DiaryTab(),
    CalendarTab(),
    MyPageTab(),
  ];

  final List<String> _titles = const ['다이어리', '캘린더', '마이페이지'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: '다이어리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

