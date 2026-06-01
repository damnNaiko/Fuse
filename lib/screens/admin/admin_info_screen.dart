// screens/admin/admin_main_info_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/screens/admin/add_service_screen.dart';
import 'package:fuse/screens/admin/edit_salon_screen.dart';

class AdminMainInfoScreen extends StatefulWidget {
  const AdminMainInfoScreen({super.key});

  @override
  State<AdminMainInfoScreen> createState() => _AdminMainInfoScreenState();
}

class _AdminMainInfoScreenState extends State<AdminMainInfoScreen> {
  // Временно храним данные салона здесь
  // Потом заменишь на данные из Firebase
  Map<String, dynamic>? _salonData;

  @override
  void initState() {
    super.initState();
    // Проверяем, есть ли сохраненный салон (пока моково)
    _checkSalonData();
  }

  void _checkSalonData() {
    print('Проверяем данные салона...');
    final savedSalon = {
      'name': 'Fuse Салон Красоты',
      'description': 'Профессиональный салон красоты...',
      'contacts': '+7 (999) 123-45-67',
      'city': 'Москва',
      'address': 'ул. Тверская, д. 10',
    };
    
    print('Салон загружен: $savedSalon');
    setState(() {
      _salonData = savedSalon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Мой салон', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _salonData == null ? _buildEmptyState() : _buildSalonCard(),
    );
  }

  // Состояние "нет салона"
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: textfield_color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store,
                size: 50,
                color: hint_color,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Добро пожаловать!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Добавьте свой салон, чтобы начать работу',
              style: TextStyle(
                color: hint_color,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _navigateToAddService();
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Добавить салон',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Карточка салона
  Widget _buildSalonCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Карточка с информацией
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: textfield_color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок карточки (можно добавить иконку)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: active_button.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: active_button,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _salonData!['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _salonData!['city'],
                              style: TextStyle(
                                color: hint_color,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Тело карточки с информацией
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Описание
                      const Row(
                        children: [
                          Icon(Icons.description, color: hint_color, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Описание',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: background_color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _salonData!['description'],
                          style: TextStyle(
                            color: hint_color,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Контакты
                      const Row(
                        children: [
                          Icon(Icons.contact_phone, color: hint_color, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Контакты',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: background_color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _salonData!['contacts'],
                          style: TextStyle(
                            color: hint_color,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Адрес
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: hint_color, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Адрес',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: background_color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _salonData!['address'],
                          style: TextStyle(
                            color: hint_color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Кнопка "Изменить"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _navigateToEditSalon();
              },
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text(
                'Изменить информацию',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddServiceScreen(),
      ),
    ).then((_) {
      _checkSalonData(); // Обновляем данные после возвращения
    });
  }

  void _navigateToEditSalon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSalonScreen(salonData: _salonData!),
      ),
    ).then((_) {
      _checkSalonData(); // Обновляем данные после редактирования
    });
  }
}