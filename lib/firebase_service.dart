import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ExpenseItem>> readExpenses() async {
    try {
      var querySnapshot = await _db.collection("expense").get();
      return querySnapshot.docs.map((doc) {
        final categoryStr = doc.data()['category'];
        final categoryName = ExpenseCategory.values
            .where((element) => element.name == categoryStr)
            .toList();
        return ExpenseItem(
          id: doc.id,
          title: doc.data()['title'],
          amount: doc.data()['amount'],
          date: doc.data()['date'],
          category: categoryName.isNotEmpty
              ? categoryName.first
              : ExpenseCategory.food,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToFirebase(ExpenseItem expense) async {
    final user = <String, String>{
      "title": expense.title,
      "amount": expense.amount,
      "id": expense.id ?? "",
      "date": expense.date,
      "category": expense.category.name,
    };

    DocumentReference doc = await _db.collection("expense").add(user);
    print('DocumentSnapshot added with ID: ${doc.id}');
  }

  Future<void> deleteFromFirebase(String id) async {
    final docReference = _db.collection("expense").doc(id);
    await docReference.delete();
    print("Deleted");
  }
}
