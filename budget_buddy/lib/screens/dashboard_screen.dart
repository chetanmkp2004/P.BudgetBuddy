import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_tile.dart';

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
            onPressed: () => AppNavigation.goToSettings(context),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondaryGreen, AppColors.success],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe to Spend',
                style: AppTextStyles.body1.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Icon(
                Icons.visibility,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${_safeToSpend.toStringAsFixed(2)}',
            style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$_daysToPayday days until payday',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  "You're \$85 ahead of last month!",
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
            Text('Accounts', style: AppTextStyles.h4),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.visibility,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              label: Text(
                'View All',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
        color: AppColors.error,
        onTap: () => AppNavigation.pushAddExpense(context),
      ),
      _QuickAction(
        icon: Icons.swap_horiz,
        label: 'Transfer',
        color: AppColors.primaryBlue,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.receipt_long,
        label: 'Pay Bill',
        color: AppColors.warning,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.trending_up,
        label: 'Add Income',
        color: AppColors.success,
        onTap: () {},
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.h4),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 120,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
            Text('Recent Transactions', style: AppTextStyles.h4),
            const Spacer(),
            TextButton(
              onPressed: () => AppNavigation.goToTransactions(context),
              child: Text(
                'See All',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 24),
        _buildAiInsightsCard(),
      ],
    );
  }

  Widget _buildAiInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.insights, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insights (Coming Soon)',
                  style: AppTextStyles.h4.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "You'll soon receive personalized suggestions to optimize your spending and accelerate savings goals.",
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
