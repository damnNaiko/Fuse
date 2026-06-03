import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  bool isActive = true;
  bool _isLoading = true;
  String? _salonId;

  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _historyBookings = [];

  @override
  void initState() {
    super.initState();
    _loadSalonAndBookings();
  }

  Future<void> _loadSalonAndBookings() async {
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
      final salonQuery = await FirebaseFirestore.instance
          .collection('salons')
          .where('adminId', isEqualTo: user.uid)
          .get();

      if (!mounted) return;

      if (salonQuery.docs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _salonId = salonQuery.docs.first.id;

      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('salonId', isEqualTo: _salonId)
          .get();

      if (!mounted) return;

      final List<Map<String, dynamic>> active = [];
      final List<Map<String, dynamic>> history = [];

      for (var doc in bookingsQuery.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'pending';

        final booking = {
          'id': doc.id,
          'clientName': data['clientName'] ?? 'Клиент',
          'clientPhone': data['clientPhone'] ?? 'Номер не указан',
          'service': data['serviceName'] ?? '',
          'date': data['date'] ?? '',
          'time': data['time'] ?? '',
          'status': status,
          'price': data['servicePrice'] ?? 0,
        };

        // Активные: pending и confirmed. История: rejected и completed
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
      print('Ошибка загрузки: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Обновляем локальные списки
      setState(() {
        // Проверяем в активных
        final activeIndex = _activeBookings.indexWhere((b) => b['id'] == bookingId);
        if (activeIndex != -1) {
          final updatedBooking = _activeBookings[activeIndex];
          updatedBooking['status'] = newStatus;
          
          if (newStatus == 'rejected' || newStatus == 'completed') {
            // Уходит в историю
            _activeBookings.removeAt(activeIndex);
            _historyBookings.insert(0, updatedBooking);
          }
          // Если newStatus == 'confirmed' — остаётся в активных
        } else {
          // Проверяем в истории (на случай если нужно переместить обратно)
          final historyIndex = _historyBookings.indexWhere((b) => b['id'] == bookingId);
          if (historyIndex != -1) {
            final updatedBooking = _historyBookings[historyIndex];
            updatedBooking['status'] = newStatus;
            
            if (newStatus == 'pending' || newStatus == 'confirmed') {
              _historyBookings.removeAt(historyIndex);
              _activeBookings.insert(0, updatedBooking);
            }
          }
        }
      });

      if (mounted) {
        String message = '';
        Color color = Colors.green;
        switch (newStatus) {
          case 'confirmed':
            message = 'Запись подтверждена';
            color = Colors.green;
            break;
          case 'rejected':
            message = 'Запись отклонена';
            color = Colors.red;
            break;
          case 'completed':
            message = 'Запись выполнена';
            color = Colors.blue;
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: color),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка обновления статуса'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Записи', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salonId == null
              ? _buildNoSalonState()
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

  Widget _buildNoSalonState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 80, color: hint_color),
          const SizedBox(height: 16),
          const Text(
            'Сначала создайте салон',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Записи будут отображаться после создания салона',
            style: TextStyle(color: hint_color, fontSize: 14),
            textAlign: TextAlign.center,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          if (isActiveMode != isActive) {
            setState(() {
              isActive = isActiveMode;
            });
          }
        },
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, {required bool isActive}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.event_busy : Icons.history, size: 64, color: hint_color),
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
        statusText = '⏳ Ожидает';
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
                  booking['clientName'],
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text(booking['clientPhone'], style: TextStyle(color: hint_color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.cleaning_services, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text(booking['service'], style: TextStyle(color: hint_color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text('${_formatDate(booking['date'])} в ${booking['time']}', style: TextStyle(color: hint_color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.currency_ruble, size: 16, color: hint_color),
              const SizedBox(width: 8),
              Text('${booking['price']} ₽', style: TextStyle(color: hint_color, fontSize: 14)),
            ],
          ),
          // Кнопки действий
          if (isActive) ...[
            const SizedBox(height: 16),
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBookingStatus(booking['id'], 'confirmed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Подтвердить', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBookingStatus(booking['id'], 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Отклонить', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            else if (status == 'confirmed')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBookingStatus(booking['id'], 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Выполнено', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
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