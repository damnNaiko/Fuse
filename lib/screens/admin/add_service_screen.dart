// screens/admin/add_service_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/providers/salon_provider.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactsController = TextEditingController();
  final addressController = TextEditingController();
  
  String? selectedCity;
  TimeOfDay? startTime; // 👈 ДОБАВИЛИ
  TimeOfDay? endTime;   // 👈 ДОБАВИЛИ

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    contactsController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Не выбрано';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        endTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Добавить салон', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSalon,
            child: const Text(
              'Добавить',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название
            const AddLabel(label: 'Название салона'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: nameController,
              label: 'Название',
              widthFactor: 1,
            ),
            const SizedBox(height: 20),

            // Описание
            const AddLabel(label: 'Описание'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: TextField(
                controller: descriptionController,
                maxLines: 5,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textfield_color,
                  hintText: 'Опишите ваш салон...',
                  hintStyle: TextStyle(color: hint_color),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 80, 80, 80)),
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Контакты
            const AddLabel(label: 'Контакты'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: contactsController,
              label: 'Телефон, WhatsApp, Telegram...',
              widthFactor: 1,
            ),
            const SizedBox(height: 20),

            // Город
            const AddLabel(label: 'Город'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                color: textfield_color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Выберите город',
                      style: TextStyle(color: hint_color),
                    ),
                  ),
                  dropdownColor: textfield_color,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          city,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCity = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Адрес
            const AddLabel(label: 'Адрес'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: addressController,
              label: 'Улица, дом, офис',
              widthFactor: 1,
            ),
            const SizedBox(height: 20),

            // 👇 ДОБАВИЛИ ЧАСЫ РАБОТЫ
            // Часы работы
            const AddLabel(label: 'Часы работы'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: textfield_color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Открытие',
                            style: TextStyle(color: hint_color, fontSize: 14),
                          ),
                          Text(
                            _formatTime(startTime),
                            style: TextStyle(
                              color: startTime != null ? Colors.white : hint_color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: textfield_color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Закрытие',
                            style: TextStyle(color: hint_color, fontSize: 14),
                          ),
                          Text(
                            _formatTime(endTime),
                            style: TextStyle(
                              color: endTime != null ? Colors.white : hint_color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Примечание
            const AddLabel(label: 'Примечание'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textfield_color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Услуги вашего сервиса вы сможете добавить на главном экране '
                'приложения в разделе: "Услуги".',
                style: TextStyle(color: hint_color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSalon() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final contacts = contactsController.text.trim();
    final address = addressController.text.trim();
    
    // Валидация
    if (name.isEmpty) {
      _showError('Введите название салона');
      return;
    }
    
    if (description.isEmpty) {
      _showError('Введите описание салона');
      return;
    }
    
    if (contacts.isEmpty) {
      _showError('Введите контакты');
      return;
    }
    
    if (selectedCity == null || selectedCity!.isEmpty) {
      _showError('Выберите город');
      return;
    }
    
    if (address.isEmpty) {
      _showError('Введите адрес');
      return;
    }
    
    if (startTime == null || endTime == null) {
      _showError('Укажите часы работы');
      return;
    }
    
    // Сохраняем через SalonProvider
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);
    
    final success = await salonProvider.saveSalon({
      'name': name,
      'description': description,
      'contacts': contacts,
      'city': selectedCity,
      'address': address,
      'startTime': '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}',
    });
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Салон успешно добавлен!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      _showError('Ошибка сохранения салона');
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}