import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class ForgottenScreen extends StatefulWidget {
  const ForgottenScreen({super.key});

  @override
  State<ForgottenScreen> createState() => _ForgottenScreenState();
}

class _ForgottenScreenState extends State<ForgottenScreen> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Восстановление пароля',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Введите email, привязанный к вашему аккаунту.\n'
                    'Мы отправим ссылку для сброса пароля.',
                    style: TextStyle(color: hint_color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    widthFactor: 1,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _resetPassword,
                          child: const Text("Отправить", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: Colors.transparent,
                          ),
                        ),
                  
                  const SizedBox(height: 20),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const Text(
                      'Вернуться на главный экран',
                      style: TextStyle(color: hint_color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      _showError('Введите email');
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Введите корректный email');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccess('Ссылка для сброса пароля отправлена на $email');
        
        // Возвращаемся на экран входа через 2 секунды
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Firebase НЕ сообщает, существует email или нет (безопасность)
      // Но мы показываем одно и то же сообщение
      _showSuccess('Если аккаунт существует, мы отправили ссылку для сброса пароля');
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Ошибка. Попробуйте позже');
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
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}