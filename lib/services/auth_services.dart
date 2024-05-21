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
  Future<EndUser?> loginUser(String login, String password) async {
    try {
      UserCredential endUserCredentials = await _firebaseAuth
          .signInWithEmailAndPassword(email: login, password: password);
      User firebaseUser = endUserCredentials.user!;
      if (firebaseUser.emailVerified) {
        return _userFirebaseUser(firebaseUser);
      } else if (!firebaseUser.emailVerified) {
        print('User email is not verified.');
        return null;
      }
    } catch (e) {
      print('Login failed, reason: $e');
      return null;
    }
    return null; // Add this line to return null if no value is ever returned
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
          // socker les données de l'utilisateur dans la base de donnéees
          await _storeUserData(user);
          return user.uid; // retourner l'identifiant de l'utilisateur connecté
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
      // Utilisez le nom d'utilisateur ou la partie locale de l'email
      'name': user.displayName ?? user.email?.split('@')[0],
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
    }, SetOptions(merge: true));
  }

  Future<bool> isUserLoggedIn() async {
    final user = _firebaseAuth.currentUser;
    return user != null;
  }

  Future addUserToCollection(EndUser newUser, String? uid) async {
    await _firebaseFirestore.collection('users').doc(uid).set(newUser.toJson());
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

//envoyer le code de verification au numero de telephone
  Future<void> sendCodeToPhoneNumber(String phoneNumber, BuildContext context,
      Function(String, int?) onCodeSent) async {
    //print(PhoneNumber);
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to Verify Phone Number: ${e.message}')),
        );
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        print('Failed to Verify Phone Number: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Verification code sent to the phone number");
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Auto retrieval timeout: $verificationId");
      },
    );
  }

  Future<User?> verifyOTP(
      String verificationId, String smsCode, BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phone number verified!")));
        notifyListeners(); // Utile si vous utilisez Provider ou un autre state management
        return userCredential.user; // Retourne l'utilisateur vérifié
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to verify OTP: No user returned")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to verify OTP: $e")));
    }
    return null;
  }

  Future<bool> createProfileWithPhone(
      {required String userId,
      required String firstName,
      required String lastName,
      required String password,
      String? imagePath}) async {
    try {
      // Vous pouvez également ajouter ici une logique pour stocker l'image dans un stockage Cloud si nécessaire
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'password':
            password, // Pensez à sécuriser le stockage des mots de passe
        'imagePath': imagePath
      });
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
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
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        user.reload().then((_) {
          if (user.emailVerified) {
            _storeUserData(
                user); // Stocker les données après la vérification de l'email
          }
        });
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Sign up failed, reason: $e');
      return null;
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Créer le document de chaque utilisateur ayant fait le signup
  Future<void> createUserDocument(User user) async {
    await user.reload(); // Assurez-vous que l'état de l'utilisateur est à jour
    if (user.emailVerified) {
      try {
        // Créer le document utilisateur avec les informations nécessaires
        await _storeUserData(user);
        print("User document created successfully for UID: ${user.uid}.");
      } catch (e) {
        print('Failed to create user document for UID: ${user.uid}, error: $e');
      }
    } else {
      print(
          'Email not verified yet for UID: ${user.uid}. Please verify email to complete registration.');
    }
  }

  /*Future<DocumentSnapshot> getUserData(String userID) async {
    return _firebaseFirestore.collection('users').doc(userID).get();
  }*/

  /*Future<Map<String, dynamic>> getUserData(String uid) async {
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
  }*/
}
