import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taximate/pages/login_page.dart';
import '../auth/auth.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> logout() async {
    try {
      await Auth().signOut();
    } on FirebaseAuthException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Home page"),
            const Text("Home page2"),
            ElevatedButton(
              onPressed: logout,
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/maps');
              },
              child: const Text('Maps'),
            ),
          ],
        ),
      ),
    );
  }
}
