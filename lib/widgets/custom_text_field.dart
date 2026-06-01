// widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuse/utils/constains.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final double widthFactor;
  final TextInputType keyboardType;
  final bool onlyDigits; 

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.widthFactor = 0.7,
    this.keyboardType = TextInputType.text, 
    this.onlyDigits = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * widthFactor,
      child: TextField(
        controller: controller,
        keyboardType: onlyDigits ? TextInputType.number : keyboardType,
        inputFormatters: onlyDigits ? [FilteringTextInputFormatter.digitsOnly] : [],
        obscureText: obscure,
        cursorColor: Colors.white,
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
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}