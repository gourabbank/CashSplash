import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/home_screen.dart';
import 'view_expenses_screen.dart'; // Make sure to import the expenses screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // Redirect to View Expenses Screen upon successful login
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen())
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign in: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              onSaved: (value) => _email = value!,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
              onSaved: (value) => _password = value!,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  signIn(_email, _password);
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}