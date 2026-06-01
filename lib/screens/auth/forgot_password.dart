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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Введите почту к которой привязан ваш аккаунт:', style: TextStyle(color: hint_color))
                ),
            
                SizedBox(height: 10),
            
                CustomTextField(controller: emailController, label: 'Почта'),
            
            
                SizedBox(height: 30),
            
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: Text("Получить письмо", style: TextStyle(color: Colors.black)),
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
                  InkWell(onTap: (){}, splashColor: Colors.transparent, child: Text('Вернуться на главный экран', style: TextStyle(color: hint_color))),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}