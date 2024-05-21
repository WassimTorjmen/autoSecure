import 'package:autosecure/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/button_component.dart';
import '../components/text_field_component.dart';
import '../services/auth_services.dart'; // Assurez-vous que le chemin d'importation est correct
import '../widgets/bezierContainer.dart'; // Assurez-vous que le chemin d'importation est correct

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: const BezierContainer(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple),
                      ),
                      const SizedBox(height: 50),
                      TextFieldComponent(
                        controller: _emailController,
                        labelText: "Email",
                        hintText: "Enter your email",
                        icon: Icons.email,
                        initiallyObscure: false,
                      ),
                      TextFieldComponent(
                        controller: _passwordController,
                        labelText: "Password",
                        hintText: "Enter your password",
                        icon: Icons.lock,
                        initiallyObscure: true,
                      ),
                      TextFieldComponent(
                        controller: _confirmPasswordController,
                        labelText: "Confirm Password",
                        hintText: "Confirm your password",
                        icon: Icons.lock,
                        initiallyObscure: true,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onPressed: () {
                          _registerUser();
                        },
                        width: 200,
                        text: 'Register Now',
                        color: const Color.fromARGB(255, 183, 134, 192),
                        textStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                  context); // retourner à la page de connexion
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // retourner à la page de connexion
      },
      child: const Text(
        'Already have an account? Login',
        style: TextStyle(
            decoration: TextDecoration.underline, color: Colors.black),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 20,
      left: 0,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 30),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    User? newUser = await _authService.registerUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (newUser != null && newUser.emailVerified) {
      // Navigate to the Profile Page if the email is already verified
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ProfilePage(uid: newUser.uid)));
    } else if (newUser != null && !newUser.emailVerified) {
      // Prompt the user to check their email for a verification link
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please verify your email to complete registration.')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
  }
}
