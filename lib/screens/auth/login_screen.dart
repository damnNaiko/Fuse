import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: Stack(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center, // 👈 исправлено (было .center)
              children: [
            
                //ПОЧТА
                Padding(
                  padding: const EdgeInsets.only(right: 180),
                  child: Text('Введите почту:', style: TextStyle(color: hint_color))
                ),
            
                SizedBox(height: 10),
            
                CustomTextField(controller: emailController, label: 'Почта'),
            
                SizedBox(height: 20),
            
            
                //ПАРОЛЬ
                Padding(
                  padding: EdgeInsetsGeometry.only(right: 170),
                  child: Text('Введите пароль:', style: TextStyle(color: hint_color))
                ),
            
                SizedBox(height: 10),
            
                CustomTextField(controller: passwordController, label: 'Пароль'),
            
                SizedBox(height: 30),
            
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
                  },
                  child: Text("Войти", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
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
                mainAxisAlignment: .end,
                children: [
                  InkWell(onTap: (){
                    Navigator.pushReplacementNamed(context, AppRoutes.register);
                  }, splashColor: Colors.transparent, child: Text('Зарегистрироваться', style: TextStyle(color: hint_color))),

                  SizedBox(height: 10),

                  InkWell(onTap: (){
                    Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword);
                  }, splashColor: Colors.transparent, child: Text('Забыли пароль?', style: TextStyle(color: hint_color))),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}