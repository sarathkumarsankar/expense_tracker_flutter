import 'dart:ffi';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class ExpenseItem {
  String? id;
  String title;
  String amount;
  String date;
  ExpenseCategory category;
    // Named constructor for creating an ExpenseItem with a custom ID
  ExpenseItem.withId({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Named constructor for creating an ExpenseItem with a generated ID
  ExpenseItem({
    String? id, // Nullable id
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = id ?? const Uuid().v4(); // Use the provided ID or generate a new one

}

enum ExpenseCategory {general, cinema, food, clothing, travel, shopping }

IconData getIconForCategory(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.general:
      return Icons.money;
    case ExpenseCategory.cinema:
      return Icons.movie;
    case ExpenseCategory.food:
      return Icons.restaurant;
    case ExpenseCategory.clothing:
      return Icons.shopping_bag;
    case ExpenseCategory.travel:
      return Icons.flight;
    case ExpenseCategory.shopping:
      return Icons.shopping_cart;
  }
}

class ExpenseBucket {
  ExpenseCategory category;
  List<ExpenseItem> expenses;

  ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<ExpenseItem> expenses, this.category)
      : expenses =
            expenses.where((element) => element.category == category).toList();

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += double.tryParse(expense.amount) ?? 0;
    }
    return sum;
  }

  int get totalExpensesInteger {
    int sum = 0;
    for (final expense in expenses) {
      sum += int.tryParse(expense.amount) ?? 0;
    }
    return sum;
  }
}
