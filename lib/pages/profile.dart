import 'dart:io';

import 'package:autosecure/components/profile_text_field.dart';
import 'package:autosecure/components/splash_screen.dart';
import 'package:autosecure/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autosecure/services/auth_services.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final _authServices = AuthService();
  User? user = FirebaseAuth.instance.currentUser;

  String fname = '';
  String email = '';
  String phoneNumber = '';
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      var data = await _authServices.getUserData(widget.uid);
      setState(() {
        userData = data;

        // Utilisez les méthodes correctes pour mettre à jour les valeurs par défaut
        userData!['photoURL'] =
            userData!['photoURL'] ?? 'https://via.placeholder.com/150';
        fname =
            userData!['full name'] = userData!['full name'] ?? 'Unavailable';
        email = userData!['email'] = userData!['email'] ?? 'Unavailable';
        phoneNumber = userData!['phoneNumber'] =
            userData!['phoneNumber'] ?? 'Unavailable';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch user data: $e")));
      // Gérer l'erreur éventuellement en affichant un message à l'utilisateur
    }
  }

  ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null) {
      return const NetworkImage('https://via.placeholder.com/150');
    }

    // Vérifie si le chemin commence par 'http'
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      // C'est un chemin de fichier local
      return FileImage(File(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Are you sure ?'),
                  content: const Text(
                    'Do you want to log out ?',
                  ),
                  actions: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.green,
                      child: const Text('Yes'),
                      onPressed: () async {
                        await _authServices.logout(context);
                        final isUserLoggedIn =
                            await _authServices.isUserLoggedIn();
                        if (!isUserLoggedIn) {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const SplashScreen(
                                pageSuivante: LoginPage(),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: getImageProvider(userData!['photoURL']),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 20),
                    DisabledTextField(
                        value: fname, label: 'Full Name', icon: Icons.person),
                    const SizedBox(height: 10),
                    DisabledTextField(
                        value: email, label: 'Email', icon: Icons.email),
                    const SizedBox(height: 10),
                    DisabledTextField(
                        value: phoneNumber,
                        label: 'Phone Number',
                        icon: Icons.phone),
                  ],
                ),
              ),
            ),
    );
  }
}
