import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_entrega1/utils/format.dart';
import 'package:proyecto_entrega1/widgets/user_avatar.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const UserAvatar(radius: 30),
                    title: Text(
                      expense.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      expense.paidBy +
                          " pago\n" +
                          DateFormat("dd-MM-y, hh:mm:ss a")
                              .format(expense.date),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "\$" + formatExpense(expense.amount),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
