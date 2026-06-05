import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _checkAuthState();
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _saveUserSession(user.uid);
      } else {
        await _clearSession();
      }
      notifyListeners();
    });
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString('user_uid');
    
    if (savedUid != null && _user == null) {
      // Сессия есть, Firebase сам восстановит пользователя через authStateChanges
      // Просто ждём
    }
  }

  Future<void> _saveUserSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', uid);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
  }

  // Регистрация
  Future<bool> register(String email, String password) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _saveUserSession(userCredential.user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Произошла ошибка. Попробуйте позже.';
      notifyListeners();
      return false;
    }
  }

  // Вход
  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _saveUserSession(userCredential.user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Произошла ошибка. Попробуйте позже.';
      notifyListeners();
      return false;
    }
  }

  // Выход
  Future<void> logout() async {
    await _auth.signOut();
    await _clearSession();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'weak-password':
        return 'Пароль должен быть не менее 6 символов';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      default:
        return 'Ошибка. Попробуйте позже';
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['role'];
    } catch (e) {
      return null;
    }
  }
}