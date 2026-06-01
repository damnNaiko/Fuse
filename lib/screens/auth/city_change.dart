import 'package:flutter/material.dart';
import 'package:fuse/routes/app_routes.dart';
import 'package:fuse/utils/constains.dart';
import 'package:fuse/widgets/custom_text_field.dart';

class CityChangeScreen extends StatefulWidget {
  const CityChangeScreen({super.key});

  @override
  State<CityChangeScreen> createState() => _CityChangeScreenState();
}

class _CityChangeScreenState extends State<CityChangeScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: Stack(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center, // 👈 исправлено (было .center)
              children: [
            
                //ПОЧТА
                Padding(
                  padding: const EdgeInsets.only(right: 150),
                  child: Text('Где вы находитесь?', style: TextStyle(color: hint_color))
                ),
            
                SizedBox(height: 10),
            
                Container(
              width: MediaQuery.sizeOf(context).width * 0.7,
              child: DropdownButtonFormField<String>(
                value: selectedCity,
                hint: Text(
                  'Город',
                  style: TextStyle(color: hint_color),
                ),
                dropdownColor: textfield_color,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textfield_color,
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
                items: cities.map((city) { // используем список из constants
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
              ),
            ),
            
            
                SizedBox(height: 30),
            
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
                  },
                  child: Text("Готово", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    foregroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}