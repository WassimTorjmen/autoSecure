import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final TextStyle textStyle;
  final double width;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color = Colors.blue, // Default color
    this.textStyle = const TextStyle(), // Default text style
    this.width = double.infinity, // Default width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor:
              const Color.fromARGB(255, 183, 134, 192), // Background color
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
