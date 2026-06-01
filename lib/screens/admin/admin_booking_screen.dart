// screens/admin/admin_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  bool isActive = true;

  // Моковые данные
  List<Map<String, dynamic>> _activeBookings = [
    {
      'id': '1',
      'clientName': 'Анна Иванова',
      'clientPhone': '+7 (999) 123-45-67',
      'service': 'Стрижка',
      'date': '15.05.2024',
      'time': '14:00',
      'status': 'pending',
    },
    {
      'id': '2',
      'clientName': 'Петр Сидоров',
      'clientPhone': '+7 (999) 234-56-78',
      'service': 'Маникюр',
      'date': '15.05.2024',
      'time': '15:30',
      'status': 'pending',
    },
  ];

  List<Map<String, dynamic>> _completedBookings = [
    {
      'id': '3',
      'clientName': 'Мария Петрова',
      'clientPhone': '+7 (999) 345-67-89',
      'service': 'Массаж',
      'date': '10.05.2024',
      'time': '11:00',
      'status': 'completed',
    },
  ];

  void _confirmBooking(Map<String, dynamic> booking) {
    setState(() {
      // Удаляем из активных
      _activeBookings.removeWhere((b) => b['id'] == booking['id']);
      
      // Добавляем в выполненные со статусом 'completed'
      _completedBookings.insert(0, {
        ...booking,
        'status': 'completed',
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Запись подтверждена'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectBooking(Map<String, dynamic> booking) {
    setState(() {
      // Удаляем из активных
      _activeBookings.removeWhere((b) => b['id'] == booking['id']);
      
      // Добавляем в выполненные со статусом 'rejected'
      _completedBookings.insert(0, {
        ...booking,
        'status': 'rejected',
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Запись отклонена'),
        backgroundColor: Colors.red,
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Кнопки переключения
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton('Активные (${_activeBookings.length})', true),
                const SizedBox(width: 30),
                _buildToggleButton('Выполненные (${_completedBookings.length})', false),
              ],
            ),
            const SizedBox(height: 20),
            
            // Список записей
            Expanded(
              child: isActive 
                ? _buildBookingsList(_activeBookings, isActive: true)
                : _buildBookingsList(_completedBookings, isActive: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String title, bool isActiveMode) {
    final isSelected = (isActiveMode == isActive);
    return Container(
      width: 172,
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
              isActive ? 'Нет активных записей' : 'Нет выполненных записей',
              style: TextStyle(color: hint_color, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, isActive: isActive);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, {required bool isActive}) {
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
          // Имя клиента и статус
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking['clientName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Статус (для выполненных)
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking['status'] == 'completed' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking['status'] == 'completed' ? 'Выполнено' : 'Отклонено',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Телефон
          Row(
            children: [
              const Icon(Icons.phone, color: hint_color, size: 16),
              const SizedBox(width: 8),
              Text(
                booking['clientPhone'],
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Услуга
          Row(
            children: [
              const Icon(Icons.cleaning_services, color: hint_color, size: 16),
              const SizedBox(width: 8),
              Text(
                booking['service'],
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Дата и время
          Row(
            children: [
              const Icon(Icons.calendar_today, color: hint_color, size: 16),
              const SizedBox(width: 8),
              Text(
                '${booking['date']} в ${booking['time']}',
                style: TextStyle(color: hint_color, fontSize: 14),
              ),
            ],
          ),
          
          // Кнопки действий (только для активных)
          if (isActive) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmBooking(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Подтвердить',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rejectBooking(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Отклонить',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}