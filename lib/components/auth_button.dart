import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final Function()? onClick;
  const AuthButton({
    super.key,
    required this.imagePath,
    required this.onClick,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 235,
      height: 50,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30,
              height: 30,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
