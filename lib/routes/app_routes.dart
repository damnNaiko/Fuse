import 'package:flutter/material.dart';
import 'package:fuse/screens/auth/city_change.dart';
import 'package:fuse/screens/auth/forgot_password.dart';
import 'package:fuse/screens/auth/login_screen.dart';
import 'package:fuse/screens/auth/register_screen.dart';
import 'package:fuse/screens/admin/admin_main_screen.dart';
import 'package:fuse/screens/shared/settings_screen.dart';
import 'package:fuse/screens/admin/add_service_screen.dart';
import 'package:fuse/screens/admin/edit_salon_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String adminMain = '/admin-main';
  static const String clientMain = '/client-main';
  static const String appSettings = '/settings';
  static const String addService = '/add-service';
  static const String editSalon = '/edit-salon';
  static const String forgotPassword = '/forgot-password';
  static const String city = '/city';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case city:
        return MaterialPageRoute(builder: (_) => const CityChangeScreen());
        
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case adminMain:
        return MaterialPageRoute(builder: (_) => const AdminMainScreen()); // 👈 ОДНА СКОБКА
        
      case appSettings:
        return MaterialPageRoute(builder: (_) => SettingsScreen()); // 👈 ОДНА СКОБКА
        
      case addService:
        return MaterialPageRoute(builder: (_) => const AddServiceScreen()); // 👈 ОДНА СКОБКА
        
      case editSalon:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditSalonScreen(salonData: args?['salonData']),
        );
        
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgottenScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Маршрут ${settings.name} не найден'),
            ),
          ),
        );
    }
  }
}