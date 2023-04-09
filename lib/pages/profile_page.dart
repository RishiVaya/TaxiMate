import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/models/user.dart';

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
      var userMap = {};
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
                context.go('/maps');
              },
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}
