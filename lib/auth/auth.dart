import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Stream<User?> get onAuthStateChanged;
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  Future<User?> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  @override
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
  }

  @override
  Future<User?> currentUser() async {
    return _firebaseAuth.currentUser!;
  }

  @override
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
