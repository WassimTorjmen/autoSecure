import 'package:autosecure/components/auth_button.dart';
import 'package:autosecure/pages/profile.dart';
import 'package:autosecure/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/auth_services.dart';

TextEditingController _emailController = TextEditingController();
TextEditingController _passcontroller = TextEditingController();
bool _isPassVisible = true;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

AuthService _authServices = AuthService();

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String uid = '';

  @override
  void initState() {
    super.initState();
    //_auth.authStateChanges().listen((event) { })
    _checkCurrentUser();
  }

  void _redirectToHome(String uid) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Vérifie si le widget est encore monté
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: uid),
          ),
          (route) => false, // Supprime toutes les routes de la pile
        );
      }
    });
  }

  void _googleSignInOnClick() async {
    print("Attempting to sign in with Google");
    final value = await _authServices.signInWithGoogle();
    print("Google sign in response: $value");
    if (value.isNotEmpty) {
      _redirectToHome(value);
    } else {
      const snackBar = SnackBar(
        content: Text('Google Sign in failed'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _checkCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Utilisateur déjà connecté, rediriger vers la page d'accueil
      _redirectToHome(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 350,
                child: TextField(
                  controller: _emailController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      // icon: Icon(Icons.mail),
                      prefixIcon: Icon(Icons.mail),
                      suffixIcon: _emailController.text.isEmpty
                          ? Text('')
                          : GestureDetector(
                              onTap: () {
                                _emailController.clear();
                              },
                              child: Icon(Icons.close)),
                      hintText: 'example@mail.com',
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1))),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 350,
                child: TextField(
                  obscureText: _isPassVisible,
                  controller: _passcontroller,
                  onChanged: (value) {
                    print(value);
                  },
                  //
                  decoration: InputDecoration(
                      // icon: Icon(Icons.mail),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _isPassVisible = !_isPassVisible;
                            setState(() {});
                          },
                          child: Icon(_isPassVisible
                              ? Icons.visibility
                              : Icons.visibility_off)),
                      hintText: 'type your password',
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1))),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 90),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: Colors.purple,
                        onPressed: () async {
                          if (_emailController.text.trim().isEmpty ||
                              _passcontroller.text.trim().isEmpty) {
                            const snackBar = SnackBar(
                              content: Text('Email/Password can\'t be empty'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            dynamic credentials = await _authServices.loginUser(
                                _emailController.text.trim(),
                                _passcontroller.text.trim());

                            print('credentials are: ' + credentials.toString());
                            if (credentials == null) {
                              const snackBar = SnackBar(
                                content: Text('Email/Password are not valid'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              if (_emailController.text.trim() ==
                                      'admin@gmail.com' ||
                                  _passcontroller.text.trim() == 'admin123') {
                                //_redirectToHome(uid);
                              } else {
                                //_redirectToHome(uid);
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              AuthButton(
                imagePath: "lib/media/google_icon.png",
                onClick: _googleSignInOnClick,
              ),
              const SizedBox(
                width: 18,
              ),
              CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: ((context) =>
                                SignUpPage()))); //bulider ye5ou arrow function w n3tih esm widget
                  },
                  color: Colors.white,
                  child: const Text('Create a new account',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold)))
            ],
          ),
        ));
  }
}
