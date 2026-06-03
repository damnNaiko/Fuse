import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:fuse/providers/salon_provider.dart';
import 'package:fuse/utils/constains.dart';

class AdminInfoScreen extends StatefulWidget {
  const AdminInfoScreen({super.key});

  @override
  State<AdminInfoScreen> createState() => _AdminInfoScreenState();
}

class _AdminInfoScreenState extends State<AdminInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalonProvider>(context, listen: false).fetchSalon();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salonProvider = Provider.of<SalonProvider>(context);

    if (salonProvider.isLoading) {
      return const Scaffold(
        backgroundColor: background_color,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final salon = salonProvider.salon;

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text(
          'Мой салон',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: salon == null ? _buildEmptyState() : _buildSalonCard(salon),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: textfield_color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store,
                size: 50,
                color: hint_color,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Добро пожаловать!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Добавьте свой салон, чтобы начать работу',
              style: TextStyle(
                color: hint_color,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addService);
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Добавить салон',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonCard(Map<String, dynamic> salon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: textfield_color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: active_button.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: active_button,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.store, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salon['name'] ?? 'Название не указано',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              salon['city'] ?? 'Город не указан',
                              style: TextStyle(color: hint_color, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Описание',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        salon['description'] ?? 'Описание не добавлено',
                        style: TextStyle(color: hint_color, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text(
                        'Контакты',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        salon['contacts'] ?? 'Контакты не указаны',
                        style: TextStyle(color: hint_color, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text(
                        'Адрес',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        salon['address'] ?? 'Адрес не указан',
                        style: TextStyle(color: hint_color, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      
                      const Text(
                        'Часы работы',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${salon['startTime'] ?? '—'} — ${salon['endTime'] ?? '—'}',
                        style: TextStyle(color: hint_color, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editSalon,
                  arguments: {'salonData': salon},
                );
              },
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text(
                'Изменить информацию',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}