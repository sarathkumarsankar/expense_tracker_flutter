import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/pages/add_new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:intl/intl.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final firestoreInstance = FirebaseFirestore.instance;

  final List<ExpenseItem> expenseList = [];

  final db = FirebaseFirestore.instance;

  void _addToFirebase(ExpenseItem expense) {
    final user = <String, String>{
      "title": expense.title,
      "amount": expense.amount,
      "id": expense.id ?? "",
      "date": expense.date,
      "category": expense.category.name,
    };
    db.collection("expense").add(user).then((DocumentReference doc) {
      print('DocumentSnapshot added with ID: ${doc.id}');
      expenseList.add(ExpenseItem(
          id: doc.id,
          title: expense.title,
          amount: expense.amount,
          date: expense.date,
          category: expense.category));
      setState(() {});
    });
  }

  Future<void> _readFromFirebase() async {
    await db.collection("expense").get().then((event) {
      for (var doc in event.docs) {
        // print("${doc.id} => ${doc.data()}");
        final categoryStr = doc.data()['category'];
        final categoryName = ExpenseCategory.values
            .where((element) => element.name == categoryStr)
            .toList();
        expenseList.add(ExpenseItem(
          id: doc.id,
          title: doc.data()['title'],
          amount: doc.data()['amount'],
          date: doc.data()['date'],
          category: categoryName.isNotEmpty
              ? categoryName.first
              : ExpenseCategory.food,
        ));
      }
    getUniqueDatesMap();
    });
    setState(() {});
  }

  Future<void> _deleteFromFirebase(String id) async {
    final docRefference = db.collection("expense").doc(id);
    docRefference.delete().then((value) {
      print("deleted");
    });
  }

  @override
  void initState() {
    super.initState();
    _readFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              "Flutter ExpenseTracker",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (ctx) {
                          return AddExpensePage(onAddExpense: (expense) {
                            /// firebase
                            _addToFirebase(expense);
                          });
                        });
                  },
                  icon: const Icon(Icons.add))
            ]),
        body: Column(
          children: [
            Chart(expenses: expenseList),
            Expanded(
              child: ListView.builder(
                  itemCount: expenseList.length,
                  itemBuilder: (ctx, index) {
                    return Container(
                      height: 90,
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Dismissible(
                        key: Key(expenseList[index].id ?? ""),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        child: ExpenseCard(expenseItem: expenseList[index]),
                        onDismissed: (direction) {
                          _removeExpense(index, expenseList[index]);
                        },
                      ),
                    );
                  }
                  ),
            ),
          ],
        ));
  }

  // Helper function to get unique dates from the expenseList
  Map<DateTime, List<ExpenseItem>> getUniqueDatesMap() {
    final uniqueDatesMap = <DateTime, List<ExpenseItem>>{};
    for (var expense in expenseList) {
      DateTime parsedDate = DateFormat.yMd().parse(expense.date);
      if (!uniqueDatesMap.containsKey(parsedDate)) {
        uniqueDatesMap[parsedDate] = [expense];
      } else {
        uniqueDatesMap[parsedDate]!.add(expense);
      }
    }
    return uniqueDatesMap;
  }
    
  void _removeExpense(int index, ExpenseItem expense) {
    setState(() {
      expenseList.remove(expense);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: const Text("Expense deleted"),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  expenseList.insert(index, expense);
                });
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      // This code will be executed when the SnackBar is closed
      if (reason == SnackBarClosedReason.timeout) {
        _deleteFromFirebase(expense.id ?? "");
        // SnackBar was closed after the specified duration
        // Add your post-SnackBar timeout logic here
      } else {
        // SnackBar was closed manually (e.g., by pressing 'Undo')
        // Add your post-SnackBar manual close logic here
      }
    });
  }
}


class SectionTitle extends StatelessWidget {
  final DateTime date;

  const SectionTitle({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Text(
        DateFormat.yMd().format(date),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}