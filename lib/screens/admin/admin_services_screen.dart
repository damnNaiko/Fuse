import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:fuse/providers/service_provider.dart';
import 'package:fuse/providers/salon_provider.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  
  String? editingServiceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSalonAndLoadServices();
    });
  }

  Future<void> _checkSalonAndLoadServices() async {
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    
    // Загружаем салон, если его ещё нет
    await salonProvider.fetchSalon();
    
    // Если салон есть — загружаем услуги
    if (salonProvider.salon != null) {
      await serviceProvider.fetchServices();
    }
  }

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
        title: Text(
          isEditing ? 'Редактировать услугу' : 'Добавить услугу',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Название"),
              ),
              const SizedBox(height: 8),
              CustomTextField(controller: nameController, label: 'Название услуги'),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Цена"),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: priceController,
                label: 'Цена (₽)',
                keyboardType: TextInputType.number,
                onlyDigits: true,
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: AddLabel(label: "Длительность (мин)"),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: durationController,
                label: 'Длительность (мин)',
                keyboardType: TextInputType.number,
                onlyDigits: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: hint_color)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = priceController.text.trim();
              final duration = durationController.text.trim();
              
              if (name.isEmpty) {
                _showError('Введите название услуги');
                return;
              }
              
              if (price.isEmpty) {
                _showError('Введите цену услуги');
                return;
              }
              
              final priceValue = int.tryParse(price);
              if (priceValue == null || priceValue <= 0) {
                _showError('Введите корректную цену');
                return;
              }
              
              if (duration.isEmpty) {
                _showError('Введите длительность');
                return;
              }
              
              final durationValue = int.tryParse(duration);
              if (durationValue == null || durationValue <= 0) {
                _showError('Введите корректную длительность');
                return;
              }
              
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              bool success;
              
              if (isEditing) {
                success = await serviceProvider.updateService(editingServiceId!, {
                  'name': name,
                  'price': priceValue,
                  'duration': durationValue,
                });
              } else {
                success = await serviceProvider.addService({
                  'name': name,
                  'price': priceValue,
                  'duration': durationValue,
                });
              }
              
              if (success) {
                Navigator.pop(context);
                _showSuccess(isEditing ? 'Услуга обновлена' : 'Услуга добавлена');
              } else {
                _showError('Ошибка сохранения');
              }
            },
            child: Text(
              isEditing ? 'Сохранить' : 'Добавить',
              style: const TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteService(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background_color,
        title: const Text('Удалить услугу?', style: TextStyle(color: Colors.white)),
        content: const Text('Это действие нельзя отменить.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(color: hint_color)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final success = await serviceProvider.deleteService(id);
      if (success) {
        _showSuccess('Услуга удалена');
      } else {
        _showError('Ошибка удаления');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final salonProvider = Provider.of<SalonProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);

    // Проверяем, есть ли салон
    if (salonProvider.salon == null) {
      return _buildNoSalonState();
    }

    if (serviceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final services = serviceProvider.services;

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Услуги', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showServiceDialog(),
          ),
        ],
      ),
      body: services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cleaning_services, size: 80, color: hint_color),
                  const SizedBox(height: 16),
                  Text(
                    'Нет добавленных услуг',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showServiceDialog(),
                    child: const Text('Добавить первую услугу', style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
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
                        const SizedBox(height: 2),
                        Text(
                          '⏱ ${service['duration']} мин',
                          style: TextStyle(color: hint_color, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
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

  Widget _buildNoSalonState() {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Услуги', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: hint_color),
              const SizedBox(height: 16),
              Text(
                'Сначала создайте салон',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Чтобы добавлять услуги, необходимо сначала создать салон в разделе "Главная"',
                style: TextStyle(color: hint_color, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addService);
                },
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('Создать салон', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}