//import 'package:autosecure/pages/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/end_user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;
  bool result = false;

  //Init Firebase user
  EndUser _userFirebaseUser(User? firebaseUser) {
    return EndUser(
      uid: firebaseUser!.uid,
    );
  }

  //Signin Email/Pass
  Future loginUser(String login, String password) async {
    try {
      UserCredential endUserCredentials = await _firebaseAuth
          .signInWithEmailAndPassword(email: login, password: password);
      User firebaseUser = endUserCredentials.user!;
      return _userFirebaseUser(firebaseUser);
    } catch (e) {
      print('Login failed, reason: $e');
      return null;
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          // Optionally store user information in Firestore
          await _storeUserData(user);
          return user
              .uid; // You can choose to return the UID or any other user information
        }
      }
      return '';
    } catch (e) {
      print("Error signing in with Google: $e");
      return '';
    }
  }

  Future<void> _storeUserData(User user) async {
    await _firebaseFirestore.collection('users').doc(user.uid).set({
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
    }, SetOptions(merge: true));
  }

  Future<bool> isUserLoggedIn() async {
    final user = _firebaseAuth.currentUser;
    return user != null;
  }

  Future<void> _saveUserDataToFirestore(EndUser endUser) async {
    try {
      // Convertir l'objet EndUser en Map
      final Map<String, dynamic> userData = endUser.toJson();

      // Enregistrer les données de l'utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(endUser.uid)
          .set(userData);
    } catch (e) {
      print('Failed to save user data to Firestore: $e');
    }
  }

  Future addUserToCollection(EndUser newUser, String? uid) async {
    await _firebaseFirestore.collection('users').doc(uid).set(newUser.toJson());
  }

  Future<bool> _checkIfUserExists(String uid) async {
    try {
      // Vérifiez si l'utilisateur existe déjà dans Firestore
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userSnapshot.exists;
    } catch (e) {
      print('Failed to check if user exists: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      print('logging out...');
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

//deconnexion du compte
  /*Future<void> logout() async {
    try {
      print('logging out...');
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }*/

//Signup Email/Pass
  Future registerUser(String email, String password) async {
    try {
      UserCredential endUserCredentials = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User firebaseUser = endUserCredentials.user!;
      return _userFirebaseUser(firebaseUser);
    } catch (e) {
      print('sign up  failed, reason: $e');
      return null;
    }
  }

  //creer le document de chaque utilisateur ayant fait le signup
  Future createUserDocument(String docId, EndUser mUser) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(docId)
          .set(mUser.toJson());
    } catch (e) {
      print(e);
    }
  }

  /*Future<DocumentSnapshot> getUserData(String userID) async {
    return _firebaseFirestore.collection('users').doc(userID).get();
  }*/

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      // Récupérer les données de l'utilisateur à partir de Firestore
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Vérifier si l'utilisateur existe
      if (userSnapshot.exists) {
        // Retourner les données de l'utilisateur sous forme de Map
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        // L'utilisateur n'existe pas, retourner une Map vide
        return {};
      }
    } catch (e) {
      print('Failed to get user data: $e');
      // En cas d'erreur, retourner une Map vide ou null selon votre préférence
      return {};
    }
  }
}
