import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SalonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _salon;
  bool _isLoading = false;

  Map<String, dynamic>? get salon => _salon;
  bool get isLoading => _isLoading;

  // Загрузка салона текущего админа
  Future<void> fetchSalon() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final query = await _firestore
          .collection('salons')
          .where('adminId', isEqualTo: user.uid)
          .get();

      if (query.docs.isNotEmpty) {
        _salon = query.docs.first.data();
        _salon!['id'] = query.docs.first.id;
      } else {
        _salon = null;
      }
    } catch (e) {
      _salon = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Создание или обновление салона
  Future<bool> saveSalon(Map<String, dynamic> salonData) async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      salonData['adminId'] = user.uid;
      salonData['updatedAt'] = FieldValue.serverTimestamp();

      // Проверяем, есть ли уже салон
      final query = await _firestore
          .collection('salons')
          .where('adminId', isEqualTo: user.uid)
          .get();

      if (query.docs.isNotEmpty) {
        // Обновляем существующий
        await query.docs.first.reference.update(salonData);
        _salon = salonData;
        _salon!['id'] = query.docs.first.id;
      } else {
        // Создаем новый
        final docRef = _firestore.collection('salons').doc();
        salonData['createdAt'] = FieldValue.serverTimestamp();
        await docRef.set(salonData);
        _salon = salonData;
        _salon!['id'] = docRef.id;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Очистка
  void clear() {
    _salon = null;
    notifyListeners();
  }
}