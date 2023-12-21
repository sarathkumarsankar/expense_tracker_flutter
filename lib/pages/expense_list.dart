import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/pages/add_new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:expense_tracker/firebase_service.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  final List<ExpenseItem> _expenseList = [];

  @override
  void initState() {
    super.initState();
    _readFromFirebase();
  }

  Map<String, List<ExpenseItem>> get dateAndExpenseArray {
    Map<String, List<ExpenseItem>> tempDict = {};
    for (final expense in _expenseList) {
      if (tempDict.containsKey(expense.date)) {
        tempDict[expense.date]!.add(expense);
      } else {
        tempDict[expense.date] = [expense];
      }
    }
    // Sort the keys (dates)
    List<String> sortedKeys = tempDict.keys.toList()..sort();
    // Create a new map with sorted keys
    Map<String, List<ExpenseItem>> sortedDateAndExpenseArray = {};
    for (final key in sortedKeys) {
      sortedDateAndExpenseArray[key] = tempDict[key]!;
    }
    return sortedDateAndExpenseArray;
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
            onPressed: () => _showAddNewExpenseModel(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Chart(expenses: _expenseList),
            Expanded(
              child: ListView.builder(
                itemCount: dateAndExpenseArray.length,
                itemBuilder: (context, index) {
                  return _buildListItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    List<String> keys = dateAndExpenseArray.keys.toList();
    final key = keys[index];
    return Column(
      children: [
        SectionTitle(date: DateFormat.yMd().parse(key)),
      ...dateAndExpenseArray[key]!.asMap().entries.map((entry) {
        final innerIndex = entry.key;
        final expense = entry.value;
        return _buildExpenseItem(innerIndex, expense);
      }).toList(),
      ],
    );
  }

  Widget _buildExpenseItem(int index, ExpenseItem expense) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(top: 5),
      child: Dismissible(
        key: Key(expense.id ?? ""),
        background: Container(
          color: Theme.of(context).colorScheme.error,
        ),
        child: ExpenseCard(expenseItem: expense),
        onDismissed: (direction) {
          _removeExpense(index, expense);
        },
      ),
    );
  }

  void _showAddNewExpenseModel() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddExpensePage(onAddExpense: (expense) {
          _addToFirebase(expense);
        });
      },
    );
  }

void _addToFirebase(ExpenseItem expense) async {
    await _firebaseService.addToFirebase(expense);
    setState(() {
      _expenseList.add(expense);
    });
  }

 void _readFromFirebase() async {
    try {
      final expenses = await _firebaseService.readExpenses();
      setState(() {
        _expenseList.addAll(expenses);
      });
    } catch (e) {
      // Handle errors...
    }
  }

  void _removeExpense(int index, ExpenseItem expense) {
    setState(() {
      _expenseList.remove(expense);
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
                  _expenseList.insert(index, expense);
                });
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      if (reason == SnackBarClosedReason.timeout) {
        _deleteFromFirebase(expense.id ?? "");
      }
    });
  }

  void _deleteFromFirebase(String id) async {
    await _firebaseService.deleteFromFirebase(id);
    setState(() {
      _expenseList.removeWhere((expense) => expense.id == id);
    });
  }
}

class SectionTitle extends StatelessWidget {
  final DateTime date;

  const SectionTitle({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 5),
      child: Card(
        color: isDarkMode
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            DateFormat.yMd().format(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
