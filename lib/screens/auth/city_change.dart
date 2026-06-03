import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';

class CityChangeScreen extends StatefulWidget {
  const CityChangeScreen({super.key});

  @override
  State<CityChangeScreen> createState() => _CityChangeScreenState();
}

class _CityChangeScreenState extends State<CityChangeScreen> {
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Выберите ваш город',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 60),
                decoration: BoxDecoration(
                  color: textfield_color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Выберите город',
                        style: TextStyle(color: hint_color),
                      ),
                    ),
                    dropdownColor: textfield_color,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            city,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCity = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveCity,
                child: const Text("Готово", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCity() async {
    if (selectedCity == null || selectedCity!.isEmpty) {
      _showError('Выберите город');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Пользователь не найден');
      return;
    }

    try {
      // Сохраняем город в профиль пользователя
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'city': selectedCity,
      });
      
      // Переходим на главный экран клиента
      Navigator.pushReplacementNamed(context, AppRoutes.clientMain);
    } catch (e) {
      _showError('Ошибка сохранения города');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}