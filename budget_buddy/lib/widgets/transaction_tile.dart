import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = tx.isExpense ? Colors.red[600] : const Color(0xFF059669);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color?.withOpacity(.15),
        child: Icon(
          tx.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        tx.merchant,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${tx.category} • ${_friendlyDate(tx.date)}'),
      trailing: Text(
        (tx.isExpense ? '-' : '+') + '\$${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _friendlyDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day)
      return 'Today';
    return '${d.month}/${d.day}/${d.year}';
  }
}
