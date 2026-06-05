// screens/check_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:fuse/providers/auth_provider.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSession = prefs.containsKey('user_uid');
    
    if (hasSession) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final role = await authProvider.getUserRole(user.uid);
        
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.clientMain);
          }
        }
      } else {
        await prefs.remove('user_uid');
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background_color,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}