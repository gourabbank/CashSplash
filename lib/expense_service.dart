import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'expense_model.dart';

class ExpenseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('expenses');

  String getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : '';
  }

  void saveExpense(Expense expense) {
    String userId = getUserId();
    _dbRef.child(userId).child(expense.id).set(expense.toJson());
  }

  Stream<List<Expense>> getExpenses() {
    String userId = getUserId();
    return _dbRef.child(userId).onValue.map((event) {
      var data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values.map((e) => Expense.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }
}