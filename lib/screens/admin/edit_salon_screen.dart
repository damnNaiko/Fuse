import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fuse/providers/salon_provider.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_labels.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class EditSalonScreen extends StatefulWidget {
  final Map<String, dynamic> salonData;
  
  const EditSalonScreen({super.key, required this.salonData});

  @override
  State<EditSalonScreen> createState() => _EditSalonScreenState();
}

class _EditSalonScreenState extends State<EditSalonScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController contactsController;
  late TextEditingController addressController;
  late String? selectedCity;
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.salonData['name']);
    descriptionController = TextEditingController(text: widget.salonData['description']);
    contactsController = TextEditingController(text: widget.salonData['contacts']);
    addressController = TextEditingController(text: widget.salonData['address']);
    selectedCity = widget.salonData['city'];
    
    // Парсим время
    startTime = _parseTime(widget.salonData['startTime']);
    endTime = _parseTime(widget.salonData['endTime']);
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

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
      initialTime: startTime ?? TimeOfDay.now(),
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
      initialTime: endTime ?? TimeOfDay.now(),
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
        title: const Text('Редактировать салон', style: TextStyle(color: Colors.white)),
        backgroundColor: background_color,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Сохранить',
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
            const AddLabel(label: 'Название салона'),
            const SizedBox(height: 10),
            CustomTextField(controller: nameController, label: 'Название', widthFactor: 1),
            const SizedBox(height: 20),

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

            const AddLabel(label: 'Контакты'),
            const SizedBox(height: 10),
            CustomTextField(controller: contactsController, label: 'Телефон, WhatsApp...', widthFactor: 1),
            const SizedBox(height: 20),

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
                    child: Text('Выберите город', style: TextStyle(color: hint_color)),
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
                  onChanged: (newValue) => setState(() => selectedCity = newValue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const AddLabel(label: 'Адрес'),
            const SizedBox(height: 10),
            CustomTextField(controller: addressController, label: 'Улица, дом, офис', widthFactor: 1),
            const SizedBox(height: 20),

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
                          Text('Открытие', style: TextStyle(color: hint_color)),
                          Text(_formatTime(startTime), style: TextStyle(color: startTime != null ? Colors.white : hint_color)),
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
                          Text('Закрытие', style: TextStyle(color: hint_color)),
                          Text(_formatTime(endTime), style: TextStyle(color: endTime != null ? Colors.white : hint_color)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final contacts = contactsController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) { _showError('Введите название салона'); return; }
    if (description.isEmpty) { _showError('Введите описание'); return; }
    if (contacts.isEmpty) { _showError('Введите контакты'); return; }
    if (selectedCity == null) { _showError('Выберите город'); return; }
    if (address.isEmpty) { _showError('Введите адрес'); return; }
    if (startTime == null || endTime == null) { _showError('Укажите часы работы'); return; }

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
        const SnackBar(content: Text('Изменения сохранены!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      _showError('Ошибка сохранения');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}