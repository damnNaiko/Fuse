import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';
import 'package:intl/intl.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> salon;
  
  const ServiceDetailScreen({super.key, required this.salon});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final servicesQuery = await FirebaseFirestore.instance
          .collection('services')
          .where('salonId', isEqualTo: widget.salon['id'])
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
      print('Ошибка загрузки услуг: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: Text(widget.salon['name'], style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSalonInfo(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Услуги', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildServicesList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: textfield_color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.salon['name'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(widget.salon['description'], style: TextStyle(color: hint_color, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Row(children: [Icon(Icons.phone, size: 18, color: active_button), const SizedBox(width: 8), Text(widget.salon['contacts'], style: TextStyle(color: hint_color, fontSize: 14))]),
          const SizedBox(height: 12),
          Row(children: [Icon(Icons.location_on, size: 18, color: active_button), const SizedBox(width: 8), Expanded(child: Text(widget.salon['address'], style: TextStyle(color: hint_color, fontSize: 14)))]),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    if (_isLoading) return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
    if (_services.isEmpty) return Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Услуги не добавлены', style: TextStyle(color: hint_color))));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _services.length,
      itemBuilder: (context, index) => _buildServiceCard(_services[index]),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: textfield_color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(service['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
              Text('${service['price']} ₽', style: TextStyle(color: active_button, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [Icon(Icons.access_time, size: 14, color: hint_color), const SizedBox(width: 4), Text('${service['duration']} мин', style: TextStyle(color: hint_color, fontSize: 12))]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => showDialog(context: context, builder: (context) => BookingDialog(service: service, salon: widget.salon)),
              child: const Text('Записаться', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Booking Dialog с занятыми датами и временем
// ============================================================

// ============================================================
// Booking Dialog с вертикальным скроллом для времени
// ============================================================

class BookingDialog extends StatefulWidget {
  final Map<String, dynamic> service;
  final Map<String, dynamic> salon;
  
  const BookingDialog({super.key, required this.service, required this.salon});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime? _selectedDate;
  String? _selectedTime;
  
  String _workStart = '10:00';
  String _workEnd = '20:00';
  bool _isLoading = true;
  
  Set<String> _bookedTimeSlots = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final salonDoc = await FirebaseFirestore.instance.collection('salons').doc(widget.salon['id']).get();
      if (salonDoc.exists) {
        final data = salonDoc.data()!;
        _workStart = data['startTime'] ?? '10:00';
        _workEnd = data['endTime'] ?? '20:00';
      }

      final bookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('salonId', isEqualTo: widget.salon['id'])
          .get();

      for (var doc in bookings.docs) {
        final data = doc.data();
        _bookedTimeSlots.add('${data['date']}_${data['time']}');
      }
    } catch (e) {
      print('Ошибка загрузки: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  List<String> _generateTimeSlots() {
    final startParts = _workStart.split(':');
    final endParts = _workEnd.split(':');
    
    int startHour = int.parse(startParts[0]);
    int startMinute = startParts.length > 1 ? int.parse(startParts[1]) : 0;
    int endHour = int.parse(endParts[0]);
    int endMinute = endParts.length > 1 ? int.parse(endParts[1]) : 0;
    
    List<String> slots = [];
    int totalStartMinutes = startHour * 60 + startMinute;
    int totalEndMinutes = endHour * 60 + endMinute;
    
    for (int minutes = totalStartMinutes; minutes < totalEndMinutes; minutes += 30) {
      int hour = minutes ~/ 60;
      int minute = minutes % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
    return slots;
  }

  List<DateTime> get _next30Days {
    List<DateTime> days = [];
    for (int i = 0; i < 30; i++) {
      days.add(DateTime.now().add(Duration(days: i)));
    }
    return days;
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }

  bool _isTimeBooked(DateTime date, String time) {
    return _bookedTimeSlots.contains('${DateFormat('yyyy-MM-dd').format(date)}_$time');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        backgroundColor: background_color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      );
    }

    final timeSlots = _generateTimeSlots();

    return Dialog(
      backgroundColor: background_color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите дату и время', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Календарь
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _next30Days.length,
                itemBuilder: (context, index) {
                  final date = _next30Days[index];
                  final isSelected = _selectedDate != null && _selectedDate!.day == date.day && _selectedDate!.month == date.month;
                  
                  return GestureDetector(
                    onTap: () => setState(() { _selectedDate = date; _selectedTime = null; }),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? active_button : textfield_color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? null : Border.all(color: hint_color.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${date.day}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(_getDayOfWeek(date), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.8) : hint_color)),
                          const SizedBox(height: 2),
                          Text('${date.month}.${date.year}', style: TextStyle(fontSize: 10, color: isSelected ? Colors.white.withOpacity(0.6) : hint_color.withOpacity(0.6))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Выбор времени с вертикальным скроллом
            if (_selectedDate != null) ...[
              const Align(alignment: Alignment.centerLeft, child: Text('Выберите время:', style: TextStyle(color: Colors.white, fontSize: 14))),
              const SizedBox(height: 10),
              Container(
                height: 200, // Фиксированная высота для скролла
                decoration: BoxDecoration(
                  color: textfield_color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final time = timeSlots[index];
                    final isSelected = _selectedTime == time;
                    final isBooked = _isTimeBooked(_selectedDate!, time);
                    
                    return GestureDetector(
                      onTap: isBooked ? null : () => setState(() => _selectedTime = time),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isBooked 
                              ? Colors.red 
                              : (isSelected ? active_button : textfield_color),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected 
                              ? null 
                              : Border.all(color: hint_color.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _selectedTime != null && !_isTimeBooked(_selectedDate!, _selectedTime!)) ? _confirmBooking : null,
                child: const Text('Записаться', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Необходимо войти в аккаунт');
      Navigator.pop(context);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? 'Клиент';
      final userPhone = userDoc.data()?['phone'] ?? '';

      await FirebaseFirestore.instance.collection('bookings').add({
        'salonId': widget.salon['id'],
        'salonName': widget.salon['name'],
        'serviceId': widget.service['id'],
        'serviceName': widget.service['name'],
        'servicePrice': widget.service['price'],
        'clientId': user.uid,
        'clientName': userName,
        'clientPhone': userPhone,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time': _selectedTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      _showSuccess('Вы записаны на ${DateFormat('dd.MM.yyyy').format(_selectedDate!)} в $_selectedTime');
    } catch (e) {
      _showError('Ошибка записи: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }
}
