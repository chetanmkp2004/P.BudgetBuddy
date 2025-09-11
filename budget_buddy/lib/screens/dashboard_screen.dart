import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/services/service_provider.dart';
import '../core/theme/app_theme.dart';
import '../models/transaction.dart';

/// Professional dashboard with safe-to-spend hero, account overview, and insights
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  final List<TransactionModel> _recentTransactions = [];
  double? _totalBalance;
  double? _expenseTotal;
  List<Map<String, dynamic>> _categorySpending = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final services = context.read<ServiceProvider>();

      // Fetch summary and last transactions in parallel
      final results = await Future.wait([
        services.accountService.getSummary(),
        services.transactionService.getTransactions(pageSize: 10),
        services.transactionService.getCategorySpending(),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final txns = results[1] as List<TransactionModel>;
      final categorySpending = results[2] as List<Map<String, dynamic>>;

      setState(() {
        _totalBalance = _toDouble(summary['total_balance']);
        _expenseTotal = _toDouble(summary['expense_total']);
        _recentTransactions
          ..clear()
          ..addAll(txns);
        _categorySpending = categorySpending;
      });
    } catch (e) {
      // Keep UI responsive; show empty state if failed
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load dashboard: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        _slideController.forward();
      }
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading) ...[
                    _buildLoadingSkeletons(),
                  ] else ...[
                    // Safe to Spend Hero Card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSafeToSpendCard(),
                    ),

                    const SizedBox(height: 24),

                    // Account Overview Cards
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildAccountOverview(),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildQuickActions(),
                    ),

                    const SizedBox(height: 24),

                    // Spending Insights Chart
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildSpendingChart(),
                    ),

                    const SizedBox(height: 24),

                    // Recent Transactions
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildRecentTransactions(),
                    ),

                    const SizedBox(height: 100), // Bottom padding for FAB
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryBlue, Color(0xFF3B82F6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Good morning,',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          'John Doe',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification bell
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile avatar
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeletons() {
    return Column(
      children: [
        _buildShimmerCard(height: 200),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildShimmerCard(height: 120)),
            const SizedBox(width: 16),
            Expanded(child: _buildShimmerCard(height: 120)),
          ],
        ),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 300),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: AppTheme.gray200,
      highlightColor: AppTheme.gray100,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSafeToSpendCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondaryGreen, Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Safe to Spend',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '\$2,847.50',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Based on your budget and upcoming bills',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),

          const SizedBox(height: 20),

          // Progress bar for month progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Month Progress',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '18 days left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: 0.4,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'Total Balance',
                amount:
                    _totalBalance != null
                        ? '\$${_totalBalance!.toStringAsFixed(2)}'
                        : '—',
                subtitle: '+2.5% from last month',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.primaryBlue,
                isPositive: true,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _buildOverviewCard(
                title: 'Monthly Spending',
                amount:
                    _expenseTotal != null
                        ? '\$${_expenseTotal!.toStringAsFixed(2)}'
                        : '—',
                subtitle: '68% of budget used',
                icon: Icons.trending_up_rounded,
                color: AppTheme.warning,
                isPositive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppTheme.success : AppTheme.warning,
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
          ),

          const SizedBox(height: 4),

          Text(
            amount,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isPositive ? AppTheme.success : AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_rounded,
                title: 'Add Expense',
                subtitle: 'Record a purchase',
                onTap: () => Navigator.of(context).pushNamed('/add-expense'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                icon: Icons.savings_rounded,
                title: 'Save Money',
                subtitle: 'Add to savings',
                onTap: () => Navigator.of(context).pushNamed('/savings'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_rounded,
                title: 'View Budget',
                subtitle: 'Track progress',
                onTap: () => Navigator.of(context).pushNamed('/budget'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gray200),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    if (_categorySpending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gray200.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: Text('No spending data available')),
      );
    }

    final total = _categorySpending.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as num).toDouble(),
    );
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.secondaryGreen,
      AppTheme.warning,
      AppTheme.gray400,
      AppTheme.purple,
      AppTheme.teal,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                'Spending Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/budget'),
                child: Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections:
                    _categorySpending.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final amount = (item['amount'] as num).toDouble();
                      final percentage =
                          total > 0 ? (amount / total * 100).round() : 0;
                      final color = colors[index % colors.length];
                      return PieChartSectionData(
                        value: amount,
                        color: color,
                        title: '${item['category']}\n$percentage%',
                        titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pushNamed('/transactions'),
                child: Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_recentTransactions.isEmpty)
            _buildEmptyState()
          else
            ..._recentTransactions
                .take(5)
                .map((transaction) => _buildTransactionTile(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray900,
                  ),
                ),
                Text(
                  transaction.category ?? 'General',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
                ),
              ],
            ),
          ),

          Text(
            '-\$${transaction.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: AppTheme.gray400),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.gray600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).pushNamed('/add-expense'),
      label: Text('Add Expense'),
      icon: Icon(Icons.add_rounded),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadDashboardData();
  }

  // Removed unused mock generator
}
