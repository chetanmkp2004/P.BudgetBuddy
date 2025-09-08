import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_tile.dart';
import 'settings_screen.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = false;
  final List<AccountModel> _accounts = [
    AccountModel(id: '1', name: 'Checking', type: 'Checking', balance: 2450.32),
    AccountModel(id: '2', name: 'Savings', type: 'Savings', balance: 8200.75),
    AccountModel(
      id: '3',
      name: 'Credit Card',
      type: 'Credit',
      balance: -430.12,
    ),
  ];
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 't1',
      merchant: 'Starbucks',
      category: 'Food',
      amount: 6.25,
      date: DateTime.now(),
      isExpense: true,
    ),
    TransactionModel(
      id: 't2',
      merchant: 'Salary',
      category: 'Income',
      amount: 2500,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isExpense: false,
    ),
    TransactionModel(
      id: 't3',
      merchant: 'Uber',
      category: 'Transport',
      amount: 12.90,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isExpense: true,
    ),
  ];

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // mock network
    if (!mounted) return;
    setState(() => _loading = false);
  }

  double get _safeToSpend => 1200.45; // mock calculation
  int get _daysToPayday => 9; // mock

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _buildSafeToSpend(context),
            const SizedBox(height: 24),
            _buildAccountsSection(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeToSpend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safe to Spend',
            style: TextStyle(color: Colors.white.withOpacity(.9)),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_safeToSpend.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_daysToPayday days until payday',
            style: TextStyle(color: Colors.white.withOpacity(.9)),
          ),
          const SizedBox(height: 4),
          Text(
            "You're \$85 ahead of last month!",
            style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Accounts',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _accounts.length,
            itemBuilder: (c, i) => AccountCard(account: _accounts[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final items = [
      _QuickAction(
        icon: Icons.add,
        label: 'Add Expense',
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
      ),
      _QuickAction(icon: Icons.swap_horiz, label: 'Transfer', onTap: () {}),
      _QuickAction(icon: Icons.receipt_long, label: 'Pay Bill', onTap: () {}),
      _QuickAction(icon: Icons.trending_up, label: 'Add Income', onTap: () {}),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 90,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (c, i) => items[i],
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
          ],
        ),
        const SizedBox(height: 4),
        if (_transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                const Text('No transactions yet'),
                const SizedBox(height: 4),
                Text(
                  'Your new activity will appear here',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          )
        else
          ..._transactions.map((t) => TransactionTile(tx: t)),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(minHeight: 3),
          ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF1E40AF)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
