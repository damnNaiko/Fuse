import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginController = TextEditingController();
  final phoneController = TextEditingController();
  bool isUser = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background_color,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: .center, 
              children: [
            
                //Логин
                Padding(
                  padding: const EdgeInsets.only(right: 150),
                  child: Text('Введите ваш логин:', style: TextStyle(color: hint_color))
                ),
            
                SizedBox(height: 10),
            
                CustomTextField(controller: loginController, label: 'Имя'),
            
                SizedBox(height: 20),
            
            
                //ПАРОЛЬ
                Padding(
                  padding: const EdgeInsets.only(right: 170),
                  child: Text('Введите почту:', style: TextStyle(color: hint_color))
                ),
            
                SizedBox(height: 10),
            
                CustomTextField(controller: emailController, label: 'Почта'),

                SizedBox(height: 20),


                Padding(
                  padding: const EdgeInsets.only(right: 70),
                  child: Text('Введите ваш номер телефона:', style: TextStyle(color: hint_color))
                ),


                SizedBox(height: 10),
                //Номер телефона
                CustomTextField(controller: phoneController, label: 'Телефон'),

                SizedBox(height: 20),


                Padding(
                  padding: const EdgeInsets.only(right: 170),
                  child: Text('Введите пароль:', style: TextStyle(color: hint_color))
                ),


                SizedBox(height: 10),
                //Пароль
                CustomTextField(controller: passwordController, label: 'Пароль', obscure: true),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: .center,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          isUser = true;
                        });
                      },
                      child: Text("Пользователь", style: TextStyle(color: isUser ? Colors.black : hint_color)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUser? active_button :  innactive_button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        foregroundColor:Colors.transparent,
                      ),
                    ),

                    SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          isUser = false;
                        });
                      },
                      child: Text("Админ", style: TextStyle(color: isUser ? hint_color : Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUser? innactive_button : active_button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        foregroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),

            
                SizedBox(height: 30),
            
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, AppRoutes.city);
                  },
                  child: Text("Продолжить", style: TextStyle(color: Colors.black)),
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
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }, splashColor: Colors.transparent, child: Text('Войти', style: TextStyle(color: hint_color))),

                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}