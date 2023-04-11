import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/models/user.dart';

import '../auth/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String _selectedValue = "";
  List<String> listOfValue = ["Male", "Female", "Other"];

  Future<bool> updateUserInfo() async {
    try {
      Map<String, dynamic> userMap = {};
      userMap["name"] = nameController.text;
      userMap["age"] = int.parse(ageController.text);
      if (_selectedValue != "") {
        userMap["gender"] = _selectedValue;
      }
      await Firestore().updateFirestoreUser(userMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  int _currentIndex = 1;
  Map<int, String> pagesMap = {0: '/', 1: '/profile'};

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go('${pagesMap[index]}');
  }

  Future<void> logout() async {
    try {
      await Auth().signOut();
      context.go('/login');
    } on FirebaseAuthException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Page'),
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
              const SizedBox(height: 16.0),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                value: _selectedValue.isNotEmpty ? _selectedValue : null,
                hint: Text(
                  'Gender',
                ),
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
                items: listOfValue.map((String val) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(
                      val,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  updateUserInfo();
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.blue,
            onTap: _onTabTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              //BottomNavigationBarItem(
              //  icon: Icon(Icons.search),
              //  label: 'Search',
              //),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ]));
  }
}
