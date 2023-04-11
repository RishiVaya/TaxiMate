import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/models/app_data.dart';
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
  Map<int, String> pagesMap2 = {
    0: '/mapsac',
    1: '/profile',
    2: '/spotify',
  };
  Map<int, String> pagesMap3 = {
    0: '/mapsr',
    1: '/profile',
    2: '/spotify',
  };

  Future<void> logout() async {
    try {
      await Auth().signOut();
      context.go('/login');
    } on FirebaseAuthException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    void _onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
      if (appData.offerId != '') {
        context.go('${pagesMap2[index]}');
      } else if (appData.requestId != '') {
        context.go('${pagesMap3[index]}');
      } else {
        context.go('${pagesMap[index]}');
      }
    }

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
            items: <BottomNavigationBarItem>[
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
              if (appData.offerId != '')
                BottomNavigationBarItem(
                  icon: Icon(Icons.music_note),
                  label: 'Music',
                )
            ]));
  }
}
