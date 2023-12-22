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
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

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
    _autovalidate = AutovalidateMode.onUserInteraction;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Please select the date'),
          ),
        );
      } else {
        widget.onAddExpense(ExpenseItem(
            title: titleEditController.text,
            amount: amountEditController.text,
            date: DateFormat.yMd().format(selectedDate!),
            category: selectedCategory));
        Navigator.of(context).pop();
      }
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
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
          child: SingleChildScrollView(
            child: SizedBox(
              child: Form(
                autovalidateMode: _autovalidate,
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleEditController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        hintText: "Title",
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().length <= 1 ||
                            value.length > 50) {
                          return "Please enter the expense reason";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: amountEditController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(hintText: "Amount"),
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              if (value == null ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
                                return "Please enter a valid amount";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedDate == null
                              ? "No date selected"
                              : DateFormat.yMd().format(selectedDate!),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                            onTap: () => _selectDate(),
                            child: const Icon(Icons.calendar_month_outlined))
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ExpenseCategory>(
                            value: selectedCategory,
                            style: TextStyle(
                                color: isDarkMode
                                    ? kDarkColorScheme.onPrimaryContainer
                                    : kColorScheme.onPrimaryContainer),
                            onChanged: (newValue) {
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
                        ),
                        // const Spacer(),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: _saveExpense,
                              child: const Text("Save Expense")),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
