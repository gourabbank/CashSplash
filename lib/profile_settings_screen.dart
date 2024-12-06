import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'login_screen.dart';

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
        setState(() => _isLoading = false);
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> pickImageAndEncode() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() => _imageBase64 = base64Encode(bytes));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Profile settings saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FilledButton(
                    child: const Text('Logout'),
                    onPressed: () {
                      Navigator.pop(context);
                      logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      InkWell(
                        onTap: pickImageAndEncode,
                        child: Hero(
                          tag: 'profile-image',
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: _imageBase64.isEmpty
                                    ? const NetworkImage('https://via.placeholder.com/150')
                                    : MemoryImage(base64Decode(_imageBase64)) as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            decoration: const InputDecoration(
                              labelText: 'Monthly Budget Goal',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: saveProfileSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}