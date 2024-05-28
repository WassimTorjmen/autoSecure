// disabled_text_field.dart
import 'package:flutter/material.dart';

class DisabledTextField extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const DisabledTextField({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.purple.shade200),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.purple.shade200),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      readOnly: true, // Make it read-only
    );
  }
}
