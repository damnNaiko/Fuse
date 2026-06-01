// screens/admin/admin_main_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/screens/admin/admin_booking_screen.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/screens/admin/admin_services_screen.dart';
import 'package:fuse/screens/admin/admin_info_screen.dart';
import 'package:fuse/screens/shared/settings_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  
  // Список экранов
  final List<Widget> _screens = [
    const AdminMainInfoScreen(),      // Главное меню / информация о сервисе
    const AdminBookingsScreen(),  // Записи (история)
    const AdminServicesScreen(),  // Услуги
    SettingsScreen(),        // Настройки
  ];
  
  // Названия для AppBar (опционально)
  final List<String> _titles = [
    'Главная',
    'Записи',
    'Услуги',
    'Настройки',
  ];
  
  // Иконки для кнопок
  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.event,
    Icons.cleaning_services,
    Icons.settings,
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_background_color,
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
          type: BottomNavigationBarType.fixed, // для 4+ кнопок
          backgroundColor: background_color,
          selectedItemColor: const Color.fromARGB(255, 215, 215, 215),    // активная кнопка (розовая)
          unselectedItemColor: const Color.fromARGB(255, 125, 125, 125),     // неактивная (серая)
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: ImageIcon(
                      AssetImage('lib/assets/png/Home.png'),
                      size: 24,
                    ),
              label: _titles[0],
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                      AssetImage('lib/assets/png/Archive.png'),
                      size: 24,
                    ),
              label: _titles[1],
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                      AssetImage('lib/assets/png/Services.png'),
                      size: 24,
                    ),
              label: _titles[2],
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                      AssetImage('lib/assets/png/Settings.png'),
                      size: 24,
                    ),
              label: _titles[3],
            ),
          ],
        ),
      ),
    );
  }
}
