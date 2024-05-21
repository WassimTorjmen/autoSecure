import 'package:autosecure/pages/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/button_component.dart';
import '../components/smsAuth_button.dart';
import '../services/auth_services.dart';
import '../components/text_field_component.dart';
import '../components/auth_button.dart';
import 'profile.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authServices = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      _redirectToHome(user.uid);
    }
  }

  void _redirectToHome(String uid) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => ProfilePage(uid: uid)));
  }

  void _googleSignInOnClick() async {
    final String uid = await _authServices.signInWithGoogle();
    if (uid.isNotEmpty) {
      _redirectToHome(uid);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Google Sign in failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text('Sign In',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  alignment: Alignment.center,
                  child: TextFieldComponent(
                    controller: _emailController,
                    labelText: "Email",
                    hintText: "Enter your email",
                    icon: Icons.email,
                    initiallyObscure: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  alignment: Alignment.center,
                  child: TextFieldComponent(
                    controller: _passController,
                    labelText: "Password",
                    hintText: "Enter your password",
                    icon: Icons.lock,
                    initiallyObscure: true,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                onPressed: _attemptLogin,
                text: 'Login',
              ),
              const SizedBox(height: 20),
              const SizedBox(
                child: Text(
                  'OR ',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
              AuthButton(
                  onClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PhoneNumberPage(),
                      ),
                    );
                  },
                  text: 'With Phone Number',
                  imagePath: "lib/assets/sms_icon.png"),
              const SizedBox(height: 20),
              AuthButton(
                  imagePath: "lib/assets/google_icon.png",
                  text: 'With Google',
                  onClick: _googleSignInOnClick),
              const SizedBox(height: 200),
              CupertinoButton(
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const SignUpPage(),
                  ),
                ),
                color: Colors.white,
                child: const Text('Create a new account',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _attemptLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email/Password can\'t be empty')));
      return;
    }
    dynamic credentials = await _authServices.loginUser(
        _emailController.text.trim(), _passController.text.trim());
    if (credentials == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email/Password are not valid')));
    } else {
      _redirectToHome(credentials.uid);
    }
  }
}
