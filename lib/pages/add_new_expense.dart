import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  final void Function(ExpenseItem expense) onAddExpense;
  const AddExpensePage({required this.onAddExpense, Key? key})
      : super(key: key);

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  TextEditingController titleEditController = TextEditingController();
  TextEditingController amountEditController = TextEditingController();

  DateTime? selectedDate;
  ExpenseCategory selectedCategory = ExpenseCategory.values.first;

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = ExpenseCategory.values.map((e) {
      return DropdownMenuItem(
        value: e.name,
        child: Text(e.name),
      );
    }).toList();
    return menuItems;
  }

  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveExpense() {
    if (selectedDate != null && titleEditController.text.trim().isNotEmpty && amountEditController.text.trim().isNotEmpty) {
      widget.onAddExpense(ExpenseItem(
          title: titleEditController.text,
          amount: amountEditController.text,
          date: DateFormat.yMd().format(selectedDate!),
          category: selectedCategory));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
        duration: Duration(seconds: 1),
          content: Text('Make sure all the inputs are entered!!!'),
        ),
      );
    }
  }

@override
  void dispose() {
    amountEditController.dispose();
    titleEditController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 40, top: 10, bottom: 20),
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  TextField(
                    controller: titleEditController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      hintText: "Title",
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountEditController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: "Amount"),
                          onSubmitted: (String value) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                      const Spacer(),
                      Text(
                        selectedDate == null
                            ? "No date selected"
                            : DateFormat.yMd().format(selectedDate!),
                      ),
                      IconButton(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_month)),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      DropdownButton<ExpenseCategory>(
                        value: selectedCategory,
                        icon: const Icon(Icons.arrow_downward, color: Colors.deepPurple),
                        style: TextStyle(color:isDarkMode ? kDarkColorScheme.onPrimaryContainer : kColorScheme.onPrimaryContainer),
                        onChanged: (ExpenseCategory? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        items: ExpenseCategory.values.map((category) {
                          return DropdownMenuItem<ExpenseCategory>(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                          onPressed: _saveExpense,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Expense")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      
    );
    
  }
}
