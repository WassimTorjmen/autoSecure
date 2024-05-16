import 'package:autosecure/components/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoSecure',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        hintColor: Colors.deepOrange,
        fontFamily: 'Lato',
      ),
      home: const SplashScreen(
        pageSuivante: LoginPage(),
      ),
    );
  }
}
