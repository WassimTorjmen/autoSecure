import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final Widget pageSuivante;
  const SplashScreen({super.key, required this.pageSuivante});

  @override
  Widget build(BuildContext context) {
    // Définissez la durée du délai (2 secondes)
    const splashDuration = Duration(seconds: 5);

    // Utilisez Future.delayed pour retarder la navigation vers la page de login
    Future.delayed(splashDuration, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => pageSuivante),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'lib/assets/splash_img.gif', // Chemin vers votre image GIF
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
