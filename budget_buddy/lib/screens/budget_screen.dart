import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_state.dart';
import '../core/api/api_client.dart';
import '../core/api/finance_service.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  List<Map<String, dynamic>> _budgets = [];
  bool _loading = false;
  String? _error;
  FinanceService? _service;

  double get _totalBudgeted => _budgets.fold(0.0, (sum, budget) {
    final v = budget['budgeted'] ?? budget['limit'] ?? 0;
    return sum + (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
  });
  double get _totalSpent => _budgets.fold(0.0, (sum, budget) {
    final v = budget['spent'] ?? 0;
    return sum + (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
  });
  double get _remaining => _totalBudgeted - _totalSpent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthState>();
    if (_service == null || _service!.token != auth.accessToken) {
      _service = FinanceService(
        ApiClient(),
        token: auth.accessToken,
        onUnauthorized: () async {
          final refreshed = await auth.refresh();
          if (refreshed) _service!.token = auth.accessToken;
          return refreshed;
        },
      );
      _fetchBudgets();
    }
  }

  Future<void> _fetchBudgets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = _service;
      if (svc == null) return;
      final list = await svc.fetchBudgets();
      // Map backend fields to UI expectations. Assume backend returns category_name, limit, spent.
      _budgets =
          list.map((b) {
            return {
              'category': b['category_name'] ?? b['category'] ?? 'Unknown',
              'icon': Icons.category,
              // choose a deterministic color variant
              'color': AppColors.primaryBlue,
              'budgeted':
                  (b['limit'] is num)
                      ? (b['limit'] as num).toDouble()
                      : double.tryParse('${b['limit']}') ?? 0,
              'spent':
                  (b['spent'] is num)
                      ? (b['spent'] as num).toDouble()
                      : double.tryParse('${b['spent']}') ?? 0,
            };
          }).toList();
    } catch (e) {
      _error = 'Failed to load budgets';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Budgets', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateBudgetDialog,
            tooltip: 'Add Budget',
          ),
        ],
      ),
      body:
          _loading && _budgets.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: AppTextStyles.body1),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchBudgets,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [_buildHeader(), Expanded(child: _buildBudgetList())],
              ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: _previousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Budget',
                  _totalBudgeted,
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Spent',
                  _totalSpent,
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Remaining',
                  _remaining,
                  _remaining >= 0 ? Colors.white : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOverallProgress(),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: textColor.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: AppTextStyles.h4.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOverallProgress() {
    final progress = _totalBudgeted > 0 ? _totalSpent / _totalBudgeted : 0.0;
    final progressColor =
        progress <= 0.8
            ? Colors.white
            : progress <= 1.0
            ? AppColors.warning
            : AppColors.error;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.body2.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildBudgetList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _budgets.length + 1,
      itemBuilder: (context, index) {
        if (index == _budgets.length) {
          return Column(
            children: [
              _buildChartPlaceholder(),
              const SizedBox(height: 16),
              _buildInsightsCard(),
            ],
          );
        }

        final budget = _budgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Spending Trend (Placeholder)',
                style: AppTextStyles.h4.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.primaryBlue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    spots: [
                      FlSpot(0, 2),
                      FlSpot(1, 3.2),
                      FlSpot(2, 2.6),
                      FlSpot(3, 4.5),
                      FlSpot(4, 3.8),
                      FlSpot(5, 5.1),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Interactive charts coming soon – this placeholder shows a sample spending trend.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget) {
    final spent = (budget['spent'] as double);
    final budgeted = (budget['budgeted'] as double);
    final progress = budgeted > 0 ? spent / budgeted : 0.0;
    final remaining = budgeted - spent;

    Color statusColor;
    if (progress <= 0.7) {
      statusColor = AppColors.success;
    } else if (progress <= 1.0) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: budget['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(budget['icon'], color: budget['color'], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget['category'], style: AppTextStyles.h4),
                    const SizedBox(height: 4),
                    Text(
                      remaining >= 0
                          ? '\$${remaining.toStringAsFixed(0)} left'
                          : '\$${(-remaining).toStringAsFixed(0)} over budget',
                      style: AppTextStyles.body2.copyWith(
                        color:
                            remaining >= 0
                                ? AppColors.gray600
                                : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${spent.toStringAsFixed(0)}',
                    style: AppTextStyles.h4.copyWith(color: statusColor),
                  ),
                  Text(
                    'of \$${budgeted.toStringAsFixed(0)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.success, size: 24),
              const SizedBox(width: 12),
              Text(
                'Budget Insights',
                style: AppTextStyles.h4.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Great job! You\'re staying within budget for most categories. Consider reallocating some funds from Shopping to Transportation.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.gray700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (_selectedMonth.isBefore(DateTime.now())) {
      setState(() {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
        );
      });
    }
  }

  void _showCreateBudgetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Budget'),
            content: const Text('Budget creation form coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
