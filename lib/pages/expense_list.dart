import 'package:flutter/material.dart';
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
  final FirebaseService _firebaseService = FirebaseService();

  final List<ExpenseItem> _expenseList = [];

  int get _totalExpense {
    if (_expenseList.isEmpty) return 0;
    return _expenseList
                .map((e) => int.parse(e.amount))
                .reduce((value, element) => value + element);
  }

  @override
  void initState() {
    super.initState();
    _readFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
        child: width < 600 ?
        Column(
          children: [
            Chart(expenses: _expenseList),
            Align(alignment: Alignment.bottomRight, child: Text("Total: $_totalExpense", style: TextStyle(fontWeight: FontWeight.bold),), ),
            Expanded(
              child: ListView.builder(
                itemCount: _expenseList.length,
                itemBuilder: (context, index) {
                  return _buildListItem(index);
                },
              ),
            ),
          ],
        ) : Row(
          children: [
            Expanded(child: Chart(expenses: _expenseList)),
            Expanded(
              child: ListView.builder(
                itemCount: _expenseList.length,
                itemBuilder: (context, index) {
                  return _buildListItem(index);
                },
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget _buildListItem(int index) {
    return _buildExpenseItem(index, _expenseList[index]);
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
      useSafeArea: true,
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
      _expenseList.addAll(expenses);
      _expenseList.sort((a, b) {
         return b.date.compareTo(a.date);
      });
      setState(() {
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
            duration: const Duration(seconds: 3),
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
