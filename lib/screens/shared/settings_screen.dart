import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  String? selectedCity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        selectedCity = data['city'];
      }
    } catch (e) {
      print('Ошибка загрузки: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: background_color,
        appBar: AppBar(
          title: const Text('Настройки', style: TextStyle(color: Colors.white)),
          backgroundColor: background_color,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Настройки', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Ваше имя:"),
              ),
              const SizedBox(height: 10),
              CustomTextField(controller: nameController, label: "Имя", widthFactor: 1),
              const SizedBox(height: 20),
                  
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Ваша почта:"),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: emailController,
                label: "Почта",
                widthFactor: 1,
                enabled: false,
              ),
              const SizedBox(height: 20),
                  
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Ваш город:"),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
                  
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Ваш номер телефона:"),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: phoneController,
                label: "Телефон",
                widthFactor: 1,
                keyboardType: TextInputType.phone,
                onlyDigits: true,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _logout,
                child: const Text("Выйти", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.transparent,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Сохранить изменения", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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

  void _saveChanges() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    
    if (name.isEmpty) {
      _showError('Введите имя');
      return;
    }
    
    if (name.length < 2) {
      _showError('Имя должно содержать минимум 2 символа');
      return;
    }
    
    if (email.isEmpty) {
      _showError('Введите email');
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Введите корректный email');
      return;
    }
    
    if (phone.isEmpty) {
      _showError('Введите номер телефона');
      return;
    }
    
    if (phone.length < 10) {
      _showError('Введите корректный номер телефона');
      return;
    }
    
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
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': name,
        'email': email,
        'phone': phone,
        'city': selectedCity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Изменения сохранены!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка сохранения: $e');
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
  
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}