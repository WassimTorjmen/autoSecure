import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../services/auth_services.dart';
import 'otp_verification.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final AuthService _authService = AuthService();
  String _phoneNumber =
      ''; // Utiliser une variable pour garder le numéro de téléphone

  void _sendCodeToPhoneNumber() {
    if (_phoneNumber.isEmpty || !_phoneNumber.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid phone number in E.164 format")));
      return;
    }

    _authService.sendCodeToPhoneNumber(_phoneNumber, context,
        (String verificationId, int? resendToken) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  OTPVerificationPage(verificationId: verificationId)));
    });
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
                _phoneNumber = number.phoneNumber ??
                    ""; // Mettre à jour directement _phoneNumber
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
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputBorder: const OutlineInputBorder(),
            ),
            const SizedBox(height: 10),
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
