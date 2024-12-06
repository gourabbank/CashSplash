import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'login_screen.dart'; // Ensure the login screen is available

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  String _imageBase64 = "";
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      dbRef.child('user_profiles').child(user.uid).once().then((snapshot) {
        if (snapshot.snapshot.value != null) {
          Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
          _nameController.text = data['name'] ?? '';
          _budgetController.text = data['budgetGoal'] ?? '';
          _imageBase64 = data['image'] ?? '';
        }
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> pickImageAndEncode() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  void saveProfileSettings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      dbRef.child('user_profiles').child(user.uid).update({
        'name': _nameController.text,
        'budgetGoal': _budgetController.text,
        'image': _imageBase64,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile settings saved successfully')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile settings: $error')));
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile Settings')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          InkWell(
            onTap: pickImageAndEncode, // Bind the image picker function to onTap
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _imageBase64.isEmpty
                  ? NetworkImage('https://via.placeholder.com/150')
                  : MemoryImage(base64Decode(_imageBase64)),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _budgetController,
            decoration: InputDecoration(labelText: 'Budget Goal', border: OutlineInputBorder()),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveProfileSettings,
            child: Text('Save Settings'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logout,
            child: Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}