import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
  bool isActive = true;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _historyBookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
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
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('clientId', isEqualTo: user.uid)
          .get();

      if (!mounted) return;

      final List<Map<String, dynamic>> active = [];
      final List<Map<String, dynamic>> history = [];

      for (var doc in bookingsQuery.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'pending';
        
        final booking = {
          'id': doc.id,
          'salonName': data['salonName'] ?? '',
          'service': data['serviceName'] ?? '',
          'date': data['date'] ?? '',
          'time': data['time'] ?? '',
          'status': status,
          'price': data['servicePrice'] ?? 0,
        };

        if (status == 'pending' || status == 'confirmed') {
          active.add(booking);
        } else {
          history.add(booking);
        }
      }

      active.sort((a, b) => b['date'].compareTo(a['date']));
      history.sort((a, b) => b['date'].compareTo(a['date']));

      if (mounted) {
        setState(() {
          _activeBookings = active;
          _historyBookings = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки записей: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildToggleButton('Активные (${_activeBookings.length})', true),
                      const SizedBox(width: 30),
                      _buildToggleButton('История (${_historyBookings.length})', false),
                    ],
                  ),
                ),
                Expanded(
                  child: isActive
                      ? _buildBookingsList(_activeBookings, isActive: true)
                      : _buildBookingsList(_historyBookings, isActive: false),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleButton(String title, bool isActiveMode) {
    final isSelected = (isActiveMode == isActive);
    return Container(
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? active_button : innactive_button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (isActiveMode != isActive) {
            setState(() {
              isActive = isActiveMode;
            });
          }
        },
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, {required bool isActive}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.event_busy : Icons.history,
              size: 64,
              color: hint_color,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Нет активных записей' : 'История пуста',
              style: TextStyle(color: hint_color, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, isActive: isActive);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, {required bool isActive}) {
    final status = booking['status'];
    String statusText = '';
    Color statusColor = Colors.grey;
    
    if (isActive) {
      if (status == 'pending') {
        statusText = '⏳ В обработке';
        statusColor = Colors.orange;
      } else if (status == 'confirmed') {
        statusText = '✅ Подтверждено';
        statusColor = Colors.green;
      }
    } else {
      if (status == 'completed') {
        statusText = '✓ Выполнено';
        statusColor = Colors.green;
      } else if (status == 'rejected') {
        statusText = '✗ Отклонено';
        statusColor = Colors.red;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: textfield_color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking['salonName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.cleaning_services, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text(
                booking['service'],
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(booking['date'])} в ${booking['time']}',
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.currency_ruble, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text(
                '${booking['price']} ₽',
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Дата не указана';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}