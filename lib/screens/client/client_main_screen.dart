// screens/client/client_main_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/screens/client/client_home_screen.dart';
import 'package:fuse/screens/client/client_bookings_screen.dart';
import 'package:fuse/screens/shared/settings_screen.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ClientHomeScreen(),
    const ClientBookingsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Сервисы',
    'Мои записи',
    'Настройки',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      // 👇 УСЛОВНЫЙ APP BAR: показываем только не для настроек
      appBar: _selectedIndex == 2
          ? null  // Настройки — без AppBar
          : AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: background_color,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: background_color,
          selectedItemColor: const Color.fromARGB(255, 215, 215, 215),
          unselectedItemColor: const Color.fromARGB(255, 125, 125, 125),
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('lib/assets/png/Home.png'),
                size: 24,
              ),
              label: 'Сервисы',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('lib/assets/png/Archive.png'),
                size: 24,
              ),
              label: 'Мои записи',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('lib/assets/png/Settings.png'),
                size: 24,
              ),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}