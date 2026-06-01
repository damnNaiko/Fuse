import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  // Контроллеры для диалога добавления/редактирования
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  
  String? editingServiceId; // null если добавляем, не null если редактируем

  // Моковые данные (потом заменишь на Firebase)
  final List<Map<String, dynamic>> _services = [
    {'id': '1', 'name': 'Стрижка', 'price': 1500, 'duration': 60},
    {'id': '2', 'name': 'Маникюр', 'price': 1200, 'duration': 45},
    {'id': '3', 'name': 'Массаж', 'price': 2000, 'duration': 90},
  ];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _showServiceDialog({Map<String, dynamic>? service}) {
    final isEditing = service != null;
    
    if (isEditing) {
      nameController.text = service['name'];
      priceController.text = service['price'].toString();
      durationController.text = service['duration'].toString();
      editingServiceId = service['id'];
    } else {
      nameController.clear();
      priceController.clear();
      durationController.clear();
      editingServiceId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background_color,
        title: Text(isEditing ? 'Редактировать услугу' : 'Добавить услугу', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: .centerLeft, child: AddLabel(label: "Название")),
            const SizedBox(height: 10),
            CustomTextField(controller: nameController, label: 'Название услуги'),
            const SizedBox(height: 20),
            Align(alignment: .centerLeft, child: AddLabel(label: "Цена")),
            const SizedBox(height: 10),
            CustomTextField(controller: priceController, label: 'Цена (₽)', keyboardType: TextInputType.number, onlyDigits: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: hint_color)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Заполните название и цену')),
                );
                return;
              }
              
              if (isEditing) {
                _updateService();
              } else {
                _addService();
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Сохранить' : 'Добавить', style: TextStyle(color: Colors.black),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _addService() {
    setState(() {
      _services.add({
        'id': DateTime.now().toString(),
        'name': nameController.text,
        'price': int.parse(priceController.text),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Услуга добавлена'), backgroundColor: Colors.green),
    );
  }

  void _updateService() {
    final index = _services.indexWhere((s) => s['id'] == editingServiceId);
    if (index != -1) {
      setState(() {
        _services[index] = {
          'id': editingServiceId!,
          'name': nameController.text,
          'price': int.parse(priceController.text),
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Услуга обновлена'), backgroundColor: Colors.green),
      );
    }
  }

  void _deleteService(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background_color,
        title: const Text('Удалить услугу?', style: TextStyle(color: Colors.white),),
        content: const Text('Это действие нельзя отменить.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: hint_color)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _services.removeWhere((s) => s['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Услуга удалена'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Услуги', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showServiceDialog(),
          ),
        ],
      ),
      body: _services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cleaning_services, size: 80, color: hint_color),
                  const SizedBox(height: 16),
                  Text(
                    'Нет добавленных услуг',
                    style: TextStyle(color: hint_color, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showServiceDialog(),
                    child: const Text('Добавить первую услугу'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: active_button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: textfield_color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      service['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${service['price']} ₽',
                          style: TextStyle(color: hint_color, fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255)),
                          onPressed: () => _showServiceDialog(service: service),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteService(service['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}