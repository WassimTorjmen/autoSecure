import 'package:autosecure/components/splash_screen.dart';
import 'package:autosecure/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autosecure/services/auth_services.dart'; // Importez le service AuthService

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authServices = AuthService();
  User? user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      print("UID: '${widget.uid}'");
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
                        await _authServices.logout();
                        final isUserLoggedIn =
                            await _authServices.isUserLoggedIn();
                        if (!isUserLoggedIn) {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const SplashScreen(),
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
                      backgroundImage: NetworkImage(userData!['photoURL'] ??
                          'https://via.placeholder.com/150'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name: ${userData!['name']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${userData!['email']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
