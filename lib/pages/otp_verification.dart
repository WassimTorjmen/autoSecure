import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'profile.dart';
import 'profile_edit.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationPage(
      {Key? key, required this.verificationId, required this.phoneNumber})
      : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  // Dans OTPVerificationPage
  void _verifyOTP() async {
    final User? user = await _authService.verifyOTP(
        widget.verificationId, _otpController.text.trim());

    if (user != null) {
      // Vérifier si un profil existe déjà
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userProfile.exists) {
        // Profil existe, rediriger vers la page de profil
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ProfilePage(uid: user.uid)));
      } else {
        // Pas de profil, rediriger vers la création de profil
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => UserProfileCreationPage(
                      uid: user.uid,
                      phoneNumber: user.phoneNumber!,
                    )));
      }
    } else {
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
            Text("Enter the OTP sent to ${widget.phoneNumber}",
                style: TextStyle(fontSize: 16)),
            TextField(
              controller: _otpController,
              decoration:
                  const InputDecoration(labelText: 'OTP', hintText: '123456'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
