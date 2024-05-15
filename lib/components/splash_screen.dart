import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:autosecure/pages/login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Définissez la durée du délai (2 secondes)
    const splashDuration = Duration(seconds: 5);

    // Utilisez Future.delayed pour retarder la navigation vers la page de login
    Future.delayed(splashDuration, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'lib/media/splash_img.gif', // Chemin vers votre image GIF
          width: 200, // Ajustez la taille selon vos besoins
          height: 200,
          // Vous pouvez également ajouter des options de décodage pour les images GIF si nécessaire
          // Par exemple, pour désactiver la lecture en boucle de l'image GIF :
          repeat: ImageRepeat.noRepeat,
        ),
      ),
    );
  }
}
