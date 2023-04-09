import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert!!"),
          content: const Text("Please use a valid Username and Password!"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
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
              onPressed: () {},
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
