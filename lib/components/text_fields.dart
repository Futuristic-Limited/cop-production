import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsecureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obsecureText,
  });

  Icon _getIcon() {
    final lowerHint = hintText.toLowerCase();
    if (lowerHint.contains('password')) {
      return const Icon(Icons.lock, color: Color(0xFF7BC148));
    } else if (lowerHint.contains('name')) {
      return const Icon(Icons.person, color: Color(0xFF7BC148));
    } else if (lowerHint.contains('email')) {
      return const Icon(Icons.email, color: Color(0xFF7BC148));
    } else {
      return const Icon(Icons.text_fields, color: Color(0xFF7BC148));
    }
  }

  TextInputType _getKeyboardType() {
    final lowerHint = hintText.toLowerCase();
    if (lowerHint.contains('email')) {
      return TextInputType.emailAddress;
    } else if (lowerHint.contains('number')) {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obsecureText,
      keyboardType: _getKeyboardType(),
      decoration: InputDecoration(
        labelText: hintText,
        hintText: 'Enter your $hintText',
        prefixIcon: _getIcon(),
        filled: true,
        fillColor: const Color(0xFFF6FFF1), // Light APHRC green background
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF7BC148), // APHRC green
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF5FAE3E), // Darker APHRC green
            width: 2.0,
          ),
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
