import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  bool _isLoading = true; // State to manage loading

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
        }
        setState(() {
          _isLoading = false; // Loading complete
        });
      }).catchError((error) {
        print("Failed to fetch user profile: $error");
        setState(() => _isLoading = false);
      });
    } else {
      setState(() => _isLoading = false); // No user logged in
    }
  }

  void saveProfileSettings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      dbRef.child('user_profiles').child(user.uid).set({
        'name': _nameController.text,
        'budgetGoal': _budgetController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile settings saved successfully'))
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile settings: $error'))
        );
      });
    }
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
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
            backgroundColor: Colors.grey.shade200,
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
        ],
      ),
    );
  }
}