import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/models/user.dart';
import '../auth/auth.dart';
import 'dart:developer';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool signUpValid = true;

  Future<void> signUp() async {
    try {
      if (passwordController.text == confirmPassword.text) {
        await Auth().createUserWithEmailAndPassword(
            emailController.text, passwordController.text);

        // var user = UserRequest();
        // user.name = nameController.text;
        // user.email = emailController.text;

        await Firestore().createFirestoreUser(
            {"name": nameController.text, "email": emailController.text});
        signUpValid = true;
      } else {
        signUpValid = false;
        _showAlert(context, "Passwords do not match!");
      }
    } on FirebaseAuthException catch (error) {
      log('data: $error');
      signUpValid = false;
      // Handle Errors here.
      String errorMessage = error.message!;
      _showAlert(context, errorMessage);
    }
  }

  void _showAlert(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert!!"),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: confirmPassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await signUp();
                // ignore: use_build_context_synchronously
                if (signUpValid) {
                  context.go('/');
                }
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
