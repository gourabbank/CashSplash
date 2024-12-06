import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  String? _selectedCategory = 'Food';
  File? _receiptImage;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String? imageString = _receiptImage != null ? base64Encode(await _receiptImage!.readAsBytes()) : null;
        DatabaseReference dbRef = FirebaseDatabase.instance.ref("expenses/${FirebaseAuth.instance.currentUser?.uid}");
        await dbRef.push().set({
          'amount': _amountController.text,
          'category': _selectedCategory,
          'receiptImage': imageString,
          'date': DateTime.now().toIso8601String(),
        });
        Navigator.pop(context); // Navigate back after save
      } catch (e) {
        print("Error saving expense: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save expense. Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: <String>[
                'Food', 'Travel', 'Housing', 'Utilities', 'Transportation', 'Healthcare', 'Entertainment', 'Education', 'Personal Care', 'Other'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Category'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Add Receipt Image'),
            ),
            _receiptImage != null ? Image.file(_receiptImage!) : Container(),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}