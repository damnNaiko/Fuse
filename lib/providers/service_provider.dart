import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get services => _services;
  bool get isLoading => _isLoading;

  // Загрузка услуг текущего салона
  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Сначала найдём салон админа
      final salonQuery = await _firestore
          .collection('salons')
          .where('adminId', isEqualTo: user.uid)
          .get();

      if (salonQuery.docs.isEmpty) {
        _services = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final salonId = salonQuery.docs.first.id;

      // Загружаем услуги этого салона
      final servicesQuery = await _firestore
          .collection('services')
          .where('salonId', isEqualTo: salonId)
          .get();

      _services = servicesQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'price': data['price'],
          'duration': data['duration'],
        };
      }).toList();
    } catch (e) {
      _services = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Добавление услуги
  Future<bool> addService(Map<String, dynamic> serviceData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Находим салон админа
      final salonQuery = await _firestore
          .collection('salons')
          .where('adminId', isEqualTo: user.uid)
          .get();

      if (salonQuery.docs.isEmpty) return false;

      final salonId = salonQuery.docs.first.id;

      // Сохраняем услугу
      await _firestore.collection('services').add({
        'salonId': salonId,
        'name': serviceData['name'],
        'price': serviceData['price'],
        'duration': serviceData['duration'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchServices(); // Обновляем список
      return true;
    } catch (e) {
      return false;
    }
  }

  // Обновление услуги
  Future<bool> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'name': serviceData['name'],
        'price': serviceData['price'],
        'duration': serviceData['duration'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchServices(); // Обновляем список
      return true;
    } catch (e) {
      return false;
    }
  }

  // Удаление услуги
  Future<bool> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
      await fetchServices(); // Обновляем список
      return true;
    } catch (e) {
      return false;
    }
  }

  // Очистка данных при выходе из аккаунта
  void clear() {
    _services = [];
    notifyListeners();
  }
}