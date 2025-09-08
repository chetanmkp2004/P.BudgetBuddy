import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _filter = 'All';

  final List<TransactionModel> _all = List.generate(
    25,
    (i) => TransactionModel(
      id: 'tx$i',
      merchant:
          i % 3 == 0
              ? 'Starbucks'
              : i % 3 == 1
              ? 'Amazon'
              : 'Salary',
      category: i % 3 == 2 ? 'Income' : 'General',
      amount: (i % 3 == 2) ? 2500 : (5 + i).toDouble(),
      date: DateTime.now().subtract(Duration(days: i)),
      isExpense: i % 3 != 2,
    ),
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _all.where((t) {
          final matchesQuery =
              _query.isEmpty ||
              t.merchant.toLowerCase().contains(_query.toLowerCase());
          final matchesFilter =
              _filter == 'All' ||
              (_filter == 'Income' && !t.isExpense) ||
              (_filter == 'Expense' && t.isExpense);
          return matchesQuery && matchesFilter;
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      hintText: 'Search merchant...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => _filter = v),
                  itemBuilder:
                      (c) => const [
                        PopupMenuItem(value: 'All', child: Text('All')),
                        PopupMenuItem(value: 'Income', child: Text('Income')),
                        PopupMenuItem(value: 'Expense', child: Text('Expense')),
                      ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _filter,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                filtered.isEmpty
                    ? Center(
                      child: Text(
                        'No transactions found',
                        style: AppTextStyles.body1,
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: filtered.length,
                      itemBuilder: (c, i) => TransactionTile(tx: filtered[i]),
                    ),
          ),
        ],
      ),
    );
  }
}
