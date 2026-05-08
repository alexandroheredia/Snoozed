
// ignore_for_file: prefer_const_constructors, body_might_complete_normally_nullable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:smarttodo/authentication/services/database_service.dart';
import 'package:smarttodo/models/app_user.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  AppUser? _userFromFirebaseUser(User user) {
    // ignore: unnecessary_null_comparison
    return user != null ? AppUser(uid: user.uid, username: '') : null;
  }
  
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> signIn({required String email, required String password, required BuildContext context}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Signed in';
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) {
        return e.message;
      }

      if (e.code == 'user-not-found') {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('No user found for that email.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito'
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ]
            );
          },
          barrierDismissible: true,
        );
      } else if (e.code == 'wrong-password') {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('oops! the password seems to be incorrect 😰 try again'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito'
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ]
            );
          },
          barrierDismissible: true,
        );
      } else if (e.code == 'user-disabled') {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('Your account has been disabled, to reactivate your account, please contact us on discord'),
              actions: [
                CupertinoDialogAction(
                  child: Text('open discord'),
                  onPressed: () async {
                    // discord server link to the #ask-for-help channel
                  },
                ),
              ]
            );
          },
          barrierDismissible: true,
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('$e'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito'
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ]
            );
          },
          barrierDismissible: true,
        );
      }
      
      // print(e.toString());
      // return e.message;
      // if (e.code == 'user-not-found') {
      //   print('No user found for that email.');
      // } if (e.code == 'wrong-password') {
      //   print('Wrong password provided for that user.');
      // } else {
      //   print(e.toString());
      // }
    }
    // } on FirebaseAuthException catch (e) {

    //   print(e.toString());
    //   return e.message;
    // }
  }


  Future<Object?> signUp({required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, 
          password: password);
      User? user = result.user;
      await DatabaseService(uid: user!.uid).updateUserData(
    
        Timestamp.now(),

        );
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.message;
    }
  }
}
