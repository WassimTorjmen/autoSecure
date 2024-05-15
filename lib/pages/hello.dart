import 'package:autosecure/services/auth_services.dart';
import 'package:flutter/material.dart';

class Hello extends StatelessWidget {
  Hello({Key? key, required this.uid}) : super(key: key);

  final String uid;
  final AuthService _authServices = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authServices.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _authServices.getUserData(
            uid), // Utiliser l'UID pour obtenir les données de l'utilisateur
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final userData = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome ${userData['full_name']}'),
                  // Afficher d'autres données de l'utilisateur
                ],
              );
            }
          }
        },
      ),
    );
  }
}
