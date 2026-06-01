// screens/admin/add_service_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    contactsController.dispose();
    addressController.dispose();
    super.dispose();
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
        actions: [
          // Кнопка "Добавить" справа
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

            // Описание (большое поле)
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

            // Город (выпадающий список)
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
            const SizedBox(height: 30),

            // Примечание (через AddLabel)
            const AddLabel(
              label: 'Примечание',
            ),
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

  void _saveSalon() {
    // Проверка заполнения
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        contactsController.text.isEmpty ||
        selectedCity == null ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все поля'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }



    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Салон успешно добавлен!'),
        backgroundColor: Colors.green,
      ),
    );

    // Возвращаемся на главный экран
    Navigator.pop(context);
  }
}