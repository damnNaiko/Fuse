import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:fuse/providers/auth_provider.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 180),
                  child: Text('Введите почту:', style: TextStyle(color: hint_color)),
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: emailController, label: 'Почта'),
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
                const SizedBox(height: 30),
                
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text("Войти", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.transparent,
                        ),
                      ),
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.register);
                    },
                    splashColor: Colors.transparent,
                    child: Text('Зарегистрироваться', style: TextStyle(color: hint_color)),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword);
                    },
                    splashColor: Colors.transparent,
                    child: Text('Забыли пароль?', style: TextStyle(color: hint_color)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty) {
      _showError('Введите email');
      return;
    }
    
    if (password.isEmpty) {
      _showError('Введите пароль');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);
    
    // 👇 ПРОВЕРЯЕМ mounted ПОСЛЕ await
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final role = await authProvider.getUserRole(user.uid);
        
        if (!mounted) return;
        
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.clientMain);
        }
      } else {
        _showError('Ошибка получения данных пользователя');
      }
    } else {
      _showError(authProvider.errorMessage ?? 'Ошибка входа');
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