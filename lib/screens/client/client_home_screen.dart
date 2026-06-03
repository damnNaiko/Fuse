import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';
import 'package:fuse/screens/client/service_detail_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';
  String? _userCity;
  bool _isLoading = true;

  List<Map<String, dynamic>> _salons = [];

  @override
  void initState() {
    super.initState();
    _loadUserCityAndSalons();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCityAndSalons() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final city = userDoc.data()?['city'];

      if (city == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      _userCity = city;

      final salonsQuery = await FirebaseFirestore.instance
          .collection('salons')
          .where('city', isEqualTo: city)
          .get();

      if (!mounted) return;

      _salons = salonsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'description': data['description'],
          'contacts': data['contacts'],
          'address': data['address'],
          'city': data['city'],
        };
      }).toList();
    } catch (e) {
      print('Ошибка загрузки: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredSalons {
    if (searchQuery.isEmpty) return _salons;
    return _salons.where((salon) {
      return salon['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          salon['description'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userCity == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 64, color: hint_color),
            const SizedBox(height: 16),
            Text(
              'Город не указан',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Пожалуйста, укажите ваш город в настройках',
              style: TextStyle(color: hint_color, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.appSettings);
              },
              child: const Text('Перейти в настройки'),
              style: ElevatedButton.styleFrom(
                backgroundColor: active_button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: CustomTextField(
            controller: searchController,
            label: 'Поиск салонов...',
            widthFactor: 1,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.location_on, color: active_button, size: 16),
              const SizedBox(width: 4),
              Text(
                'Салоны в городе $_userCity',
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        Expanded(
          child: _filteredSalons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: hint_color),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty
                            ? 'В вашем городе пока нет салонов'
                            : 'Ничего не найдено',
                        style: TextStyle(color: hint_color, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredSalons.length,
                  itemBuilder: (context, index) {
                    final salon = _filteredSalons[index];
                    return _buildSalonCard(salon);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSalonCard(Map<String, dynamic> salon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: textfield_color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              salon['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              salon['description'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: hint_color, fontSize: 14, height: 1.4),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.phone, size: 16, color: hint_color),
                const SizedBox(width: 8),
                Text(
                  salon['contacts'],
                  style: TextStyle(color: hint_color, fontSize: 13),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: hint_color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    salon['address'],
                    style: TextStyle(color: hint_color, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailScreen(salon: salon),
                    ),
                  );
                },
                child: const Text('Подробнее', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}