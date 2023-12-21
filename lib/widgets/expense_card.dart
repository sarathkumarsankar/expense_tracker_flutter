import 'package:flutter/material.dart';
import 'package:expense_tracker/model/expense.dart';


extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expenseItem,
  });

  final ExpenseItem expenseItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
       padding: const EdgeInsets.all(10),
        child: Row(
         crossAxisAlignment: CrossAxisAlignment.end,
         children: [
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                Text(expenseItem.title.toCapitalized(),
                 style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis, maxLines: 1,),
                Text("INR.${expenseItem.amount}", style: const TextStyle(fontWeight: FontWeight.w400))
             ],),
           ),
           const Spacer(),
           Row(
             children: [
             Icon(getIconForCategory(expenseItem.category)),
             const SizedBox(width: 5),
             Text(expenseItem.date)
           ],)
         ]
         ),
      ),
    );
  }
}