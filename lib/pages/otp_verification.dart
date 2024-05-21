import 'package:autosecure/pages/profile_edit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;

  const OTPVerificationPage({super.key, required this.verificationId});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService =
      AuthService(); // Assurez-vous d'avoir une instance d'AuthService

  void _verifyOTP() async {
    final User? user = await _authService.verifyOTP(
        widget.verificationId, _otpController.text.trim(), context);

    if (user != null) {
      // Redirection en cas de succès
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => UserProfileCreationPage(uid: user.uid)));
    } else {
      // Afficher une erreur si aucune utilisateur n'est retourné
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Verification failed or session expired")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter the OTP sent to your phone",
                style: TextStyle(fontSize: 16)),
            TextField(
              controller: _otpController,
              decoration:
                  const InputDecoration(labelText: 'OTP', hintText: '123456'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _verifyOTP, child: const Text('Verify'))
          ],
        ),
      ),
    );
  }
}
