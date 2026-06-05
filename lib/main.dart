import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fuse/firebase_options.dart';
import 'package:fuse/providers/auth_provider.dart';
import 'package:fuse/providers/salon_provider.dart';
import 'package:fuse/providers/service_provider.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: MaterialApp(
        title: 'Fuse CRM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }
          ),
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        onGenerateRoute: AppRoutes.generateRoute,
        home: SplashScreen(),
      ),
    );
  }
}

// Экран проверки авторизации
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
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
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}