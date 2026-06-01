import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/screens/admin/add_service_screen.dart';
import 'package:fuse/screens/admin/admin_main_screen.dart';
import 'package:fuse/screens/auth/city_change.dart';
import 'package:fuse/screens/auth/forgot_password.dart';
import 'package:fuse/screens/auth/login_screen.dart';
import 'package:fuse/screens/auth/register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen()
    );
  }
}