import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  Future<void> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign up: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              onSaved: (value) => _email = value!,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
              onSaved: (value) => _password = value!,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  signUp(_email, _password);
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}