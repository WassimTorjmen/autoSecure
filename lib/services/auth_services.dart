//import 'package:autosecure/pages/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/end_user.dart';
import '../pages/login.dart';

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
      'full name': user.displayName ?? user.email?.split('@')[0],
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
    }, SetOptions(merge: true));
  }

  Future<bool> isUserLoggedIn() async {
    final user = _firebaseAuth.currentUser;
    return user != null;
  }

  /*Future addUserToCollection(EndUser newUser, String? uid) async {
    await _firebaseFirestore.collection('users').doc(uid).set(newUser.toJson());
  }
*/
  Future<void> logout(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      // Utilisez pushAndRemoveUntil pour retirer toutes les routes précédentes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print(e.toString());
    }
  }

//envoyer le code de verification au numero de telephone
  Future<bool> sendCodeToPhoneNumber(
      String phoneNumber, Function(String, int?) onCodeSent) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          // Vous pouvez notifier ici si nécessaire
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
          print('Failed to Verify Phone Number: ${e.message}');
          throw Exception('Failed to Verify Phone Number: ${e.message}');
        },
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Auto retrieval timeout: $verificationId");
        },
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        notifyListeners(); // Si vous utilisez Provider ou un autre gestionnaire d'état
        return userCredential.user; // Retourne l'utilisateur vérifié
      }
    } catch (e) {
      print("Failed to verify OTP: $e");
    }
    return null;
  }

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    // Rechercher l'utilisateur par numéro de téléphone
    var userQuery = await _firebaseFirestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      // Convertir le premier document trouvé en objet User
      return _firebaseAuth
          .currentUser; // ou retourner un objet utilisateur personnalisé
    }
    return null;
  }

  Future<bool> createProfileWithPhone({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? imagePath,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'full name': firstName + lastName,
        'phoneNumber': phoneNumber,
        'photoURL': imagePath,
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
  Future<User?> registerUser(
      String email, String password, String fullName) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Sign up failed, reason: $e');
      return null;
    }
  }

  Future<void> checkEmailVerified(User user) async {
    await user.reload();
    if (user.emailVerified) {
      print("email is verified");
      await createUserDocument(user);
    }
  }

  // Créer le document de chaque utilisateur ayant fait le signup
  Future<void> createUserDocument(User user) async {
    try {
      await _firebaseFirestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
        // Ajoutez d'autres attributs ici si nécessaire
      });
      print("User document created successfully for UID: ${user.uid}.");
    } catch (e) {
      print('Failed to create user document for UID: ${user.uid}, error: $e');
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
      // En cas d'erreur, retourner une Map vide
      return {};
    }
  }
}
