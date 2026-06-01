// lib/screens/shared/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final name_controller = TextEditingController();
  final email_controller = TextEditingController();
  final phone_controller = TextEditingController();
  
  String? selectedCity; // 👈 теперь может меняться через setState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text('Настройки', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            // Имя
            const Align(
              alignment: Alignment.centerLeft,
              child: AddLabel(label: "Ваше имя:"),
            ),
            const SizedBox(height: 10),
            CustomTextField(controller: name_controller, label: "Имя", widthFactor: 1),
            const SizedBox(height: 20),
                
            // Почта
            const Align(
              alignment: Alignment.centerLeft,
              child: AddLabel(label: "Ваша почта:"),
            ),
            const SizedBox(height: 10),
            CustomTextField(controller: email_controller, label: "Почта", widthFactor: 1),
            const SizedBox(height: 20),
                
            // Город (выпадающий список)
            const Align(alignment: Alignment.centerLeft, child: AddLabel(label: "Ваш город:"),),
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
                        child: Text(city, style: const TextStyle(color: Colors.white)),
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
                
            const Align(alignment: Alignment.centerLeft,child: AddLabel(label: "Ваш номер телефона:")),
            const SizedBox(height: 10),
            CustomTextField(controller: phone_controller, label: "Телефон", widthFactor: 1),
            const SizedBox(height: 20),

            ElevatedButton(
                  onPressed: (){},
                  child: Text("Выйти", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    foregroundColor: Colors.transparent,
                  ),
                ),

            SizedBox(height: 20),

            ElevatedButton(
                  onPressed: (){},
                  child: Text("Сохранить изменения", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    foregroundColor: Colors.transparent,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}