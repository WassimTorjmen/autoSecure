import 'package:autosecure/models/end_user.dart';
import 'package:autosecure/pages/profile.dart';
import 'package:autosecure/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/auth_services.dart';
import '../widgets/BezierContainer.dart';

FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
AuthService _authServices = AuthService();

TextEditingController _emailController = TextEditingController();
TextEditingController _passcontroller = TextEditingController();
TextEditingController _passconfirmcontroller = TextEditingController();
TextEditingController _usernameController = TextEditingController();

bool _isPassVisible = true;
EndUser endUser = EndUser(
    username: _usernameController.text.trim(),
    fullName: '',
    email: _emailController.text.trim(),
    phone: '',
    uid: _firebaseAuth.currentUser!.uid);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
                top: -MediaQuery.of(context).size.height * .15,
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
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'S',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.purple,
                          ),
                          children: [
                            TextSpan(
                              text: 'ig',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                              ),
                            ),
                            TextSpan(
                              text: 'n',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 30,
                              ),
                            ),
                            TextSpan(
                              text: 'Up',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.start,
                                  obscureText: false,
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.person),
                                      suffixIcon: _usernameController
                                              .text.isEmpty
                                          ? const Text('')
                                          : GestureDetector(
                                              onTap: () {
                                                _usernameController.clear();
                                              },
                                              child: const Icon(Icons.close)),
                                      hintText: 'WalterWhite',
                                      labelText: 'Username',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.start,
                                  obscureText: false,
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                      // icon: Icon(Icons.mail),
                                      prefixIcon: const Icon(Icons.mail),
                                      suffixIcon: _emailController.text.isEmpty
                                          ? const Text('')
                                          : GestureDetector(
                                              onTap: () {
                                                _emailController.clear();
                                              },
                                              child: const Icon(Icons.close)),
                                      hintText: 'example@mail.com',
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  obscureText: _isPassVisible,
                                  controller: _passcontroller,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.start,
                                  obscureText: _isPassVisible,
                                  controller: _passconfirmcontroller,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: GestureDetector(
                                          onTap: () {
                                            _isPassVisible = !_isPassVisible;
                                            setState(() {});
                                          },
                                          child: Icon(_isPassVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off)),
                                      hintText: 'confirm your password',
                                      labelText: 'Password',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(
                              15,
                            ),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.grey.shade200,
                              offset: const Offset(
                                2,
                                4,
                              ),
                              blurRadius: 5,
                              spreadRadius: 2,
                            )
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.purple,
                              Colors.purple,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: CupertinoButton(
                                    child: const Text(
                                      'Register Now',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_emailController.text
                                              .trim()
                                              .isEmpty ||
                                          _passcontroller.text.trim().isEmpty ||
                                          _passconfirmcontroller.text
                                              .trim()
                                              .isEmpty ||
                                          _usernameController.text
                                              .trim()
                                              .isEmpty) {
                                        const snackBar = SnackBar(
                                          content: Text('Missing field(s)'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      } else if (_passcontroller.text.trim() !=
                                          _passconfirmcontroller.text.trim()) {
                                        const snackBar = SnackBar(
                                          content:
                                              Text('Please Confirm password'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      } else if (_passcontroller.text.trim() ==
                                              _passconfirmcontroller.text
                                                  .trim() &&
                                          _emailController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _passcontroller.text
                                              .trim()
                                              .isNotEmpty &&
                                          _passconfirmcontroller.text
                                              .trim()
                                              .isNotEmpty &&
                                          _usernameController.text
                                              .trim()
                                              .isNotEmpty) {
                                        dynamic credentials =
                                            await _authServices.registerUser(
                                          _emailController.text.trim(),
                                          _passcontroller.text.trim(),
                                        );
                                        if (credentials == null) {
                                          const snackBar = SnackBar(
                                            content: Text(
                                                'Email/Password are Invalid'),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        } else {
                                          _authServices
                                              .createUserDocument(
                                                  _firebaseAuth
                                                      .currentUser!.uid,
                                                  endUser)
                                              .then(
                                                (value) =>
                                                    Navigator.pushReplacement(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        ProfilePage(
                                                            uid: _firebaseAuth
                                                                .currentUser!
                                                                .uid),
                                                  ),
                                                ),
                                              );
                                        }
                                      }
                                    }))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          padding: const EdgeInsets.all(15),
                          alignment: Alignment.bottomCenter,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Already have an account ?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                            left: 0,
                            top: 10,
                            bottom: 10,
                          ),
                          child: const Icon(
                            Icons.arrow_left,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                        const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
