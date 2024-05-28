import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../services/auth_services.dart';
import 'otp_verification.dart';
import 'profile.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({Key? key}) : super(key: key);

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final AuthService _authService = AuthService();
  String _phoneNumber = '';

  // Dans PhoneNumberPage
  void _sendCodeToPhoneNumber() async {
    // Vérification de base du format E.164 avec une expression régulière simple
    final RegExp e164 = RegExp(r'^\+33\d{9}$');

    if (!_phoneNumber.startsWith('+') || !e164.hasMatch(_phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please enter a valid phone number in the right format"),
        ),
      );
      return;
    }

    // Vérifier si le numéro est déjà utilisé
    var existingUser = await _authService.getUserByPhoneNumber(_phoneNumber);
    if (existingUser != null) {
      // Rediriger vers la page de profil si l'utilisateur existe
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(uid: existingUser.uid)),
      );
    } else {
      // Continuer avec l'envoi du code si le numéro n'est pas utilisé
      bool sent = await _authService.sendCodeToPhoneNumber(_phoneNumber,
          (String verificationId, int? resendToken) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OTPVerificationPage(
                      verificationId: verificationId,
                      phoneNumber: _phoneNumber,
                    )));
      });

      if (!sent) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to send verification code.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Your Phone Number")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                _phoneNumber = number.phoneNumber ?? "";
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                showFlags: true,
                useEmoji: false,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              initialValue: PhoneNumber(isoCode: 'FR'),
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputBorder: const OutlineInputBorder(),
              inputDecoration: const InputDecoration(
                hintText: 'Enter phone number',
                labelText: 'Phone Number',
                // Add input formatter for digits only
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendCodeToPhoneNumber,
              child: const Text('Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }
}
