import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:fuse/providers/auth_provider.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final loginController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool isUser = true;
  bool _isLoading = false;

  @override
  void dispose() {
    loginController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background_color,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 150),
                  child: Text('Введите ваш логин:', style: TextStyle(color: hint_color)),
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: loginController, label: 'Логин'),
                const SizedBox(height: 20),
                
                const Padding(
                  padding: EdgeInsets.only(right: 170),
                  child: Text('Введите почту:', style: TextStyle(color: hint_color)),
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: emailController, label: 'Почта'),
                const SizedBox(height: 20),
                
                const Padding(
                  padding: EdgeInsets.only(right: 70),
                  child: Text('Введите ваш номер телефона:', style: TextStyle(color: hint_color)),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: phoneController,
                  label: 'Телефон',
                  keyboardType: TextInputType.phone,
                  onlyDigits: true,
                ),
                const SizedBox(height: 20),
                
                const Padding(
                  padding: EdgeInsets.only(right: 170),
                  child: Text('Введите пароль:', style: TextStyle(color: hint_color)),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: passwordController,
                  label: 'Пароль',
                  obscure: true,
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isUser = true;
                        });
                      },
                      child: Text(
                        "Пользователь",
                        style: TextStyle(color: isUser ? Colors.black : hint_color),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUser ? active_button : innactive_button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isUser = false;
                        });
                      },
                      child: Text(
                        "Админ",
                        style: TextStyle(color: isUser ? hint_color : Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUser ? innactive_button : active_button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text("Продолжить", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.transparent,
                        ),
                      ),
                
                const SizedBox(height: 20),
                
                InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  splashColor: Colors.transparent,
                  child: Text('Войти', style: TextStyle(color: hint_color)),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    // Валидация
    if (loginController.text.trim().isEmpty) {
      _showError('Введите логин');
      return;
    }
    
    if (email.isEmpty) {
      _showError('Введите email');
      return;
    }
    
    if (phoneController.text.trim().isEmpty) {
      _showError('Введите телефон');
      return;
    }
    
    if (password.isEmpty) {
      _showError('Введите пароль');
      return;
    }
    
    if (password.length < 6) {
      _showError('Пароль должен быть не менее 6 символов');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(email, password);
    
    // Проверяем, существует ли виджет
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': loginController.text.trim(),
          'email': email,
          'phone': phoneController.text.trim(),
          'role': isUser ? 'client' : 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      
      if (isUser) {
        Navigator.pushReplacementNamed(context, AppRoutes.city);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
      }
    } else {
      _showError(authProvider.errorMessage ?? 'Ошибка регистрации');
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