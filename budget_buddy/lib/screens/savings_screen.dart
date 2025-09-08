import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': '1',
      'name': 'Emergency Fund',
      'icon': Icons.security,
      'color': AppColors.success,
      'targetAmount': 10000.0,
      'currentAmount': 7500.0,
      'targetDate': DateTime.now().add(const Duration(days: 180)),
      'monthlyTarget': 500.0,
      'priority': 'High',
    },
    {
      'id': '2',
      'name': 'Vacation to Japan',
      'icon': Icons.flight,
      'color': AppColors.primaryBlue,
      'targetAmount': 5000.0,
      'currentAmount': 2800.0,
      'targetDate': DateTime.now().add(const Duration(days: 365)),
      'monthlyTarget': 200.0,
      'priority': 'Medium',
    },
    {
      'id': '3',
      'name': 'New Laptop',
      'icon': Icons.laptop,
      'color': AppColors.warning,
      'targetAmount': 2500.0,
      'currentAmount': 1200.0,
      'targetDate': DateTime.now().add(const Duration(days: 120)),
      'monthlyTarget': 400.0,
      'priority': 'Low',
    },
    {
      'id': '4',
      'name': 'House Down Payment',
      'icon': Icons.home,
      'color': AppColors.error,
      'targetAmount': 50000.0,
      'currentAmount': 15000.0,
      'targetDate': DateTime.now().add(const Duration(days: 730)),
      'monthlyTarget': 1500.0,
      'priority': 'High',
    },
  ];

  double get _totalTargetAmount =>
      _goals.fold(0, (sum, goal) => sum + goal['targetAmount']);
  double get _totalCurrentAmount =>
      _goals.fold(0, (sum, goal) => sum + goal['currentAmount']);
  double get _overallProgress =>
      _totalTargetAmount > 0 ? _totalCurrentAmount / _totalTargetAmount : 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Savings Goals', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGoalDialog,
            tooltip: 'Add Goal',
          ),
        ],
      ),
      body: Column(
        children: [_buildOverallProgress(), Expanded(child: _buildGoalsList())],
      ),
    );
  }

  Widget _buildOverallProgress() {
    return Container(
      margin: const EdgeInsets.all(24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Progress',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
              Text(
                '${(_overallProgress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '\$${_totalCurrentAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'of \$${_totalTargetAmount.toStringAsFixed(0)}',
                style: AppTextStyles.body1.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _overallProgress * _animationController.value,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_goals.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        return _buildGoalCard(_goals[index], index);
      },
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, int index) {
    final progress =
        goal['targetAmount'] > 0
            ? goal['currentAmount'] / goal['targetAmount']
            : 0.0;
    final remaining = goal['targetAmount'] - goal['currentAmount'];
    final daysLeft = goal['targetDate'].difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: goal['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(goal['icon'], color: goal['color'], size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal['name'],
                                  style: AppTextStyles.h4,
                                ),
                              ),
                              _buildPriorityChip(goal['priority']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${DateFormat('MMM dd, yyyy').format(goal['targetDate'])}',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: AppColors.gray500),
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Goal'),
                            ),
                            const PopupMenuItem(
                              value: 'contribute',
                              child: Text('Add Contribution'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Goal'),
                            ),
                          ],
                      onSelected: (value) => _handleGoalAction(value, goal),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${goal['currentAmount'].toStringAsFixed(0)} of \$${goal['targetAmount'].toStringAsFixed(0)}',
                            style: AppTextStyles.h4.copyWith(
                              color: goal['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.h4.copyWith(
                            color: goal['color'],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$daysLeft days left',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          height: 12,
                          width:
                              MediaQuery.of(context).size.width *
                              progress *
                              _animationController.value *
                              0.8, // Approximate container width factor
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                goal['color'],
                                goal['color'].withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Remaining',
                        '\$${remaining.toStringAsFixed(0)}',
                        Icons.radio_button_unchecked,
                        AppColors.gray600,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Monthly Target',
                        '\$${goal['monthlyTarget'].toStringAsFixed(0)}',
                        Icons.calendar_month,
                        goal['color'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: goal['color'].withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showContributionDialog(goal),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Money'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: goal['color'],
                      side: BorderSide(color: goal['color']),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showGoalDetails(goal),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goal['color'],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority) {
      case 'High':
        color = AppColors.error;
        break;
      case 'Medium':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
            ),
            Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.savings,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text('No Savings Goals Yet', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Text(
              'Start building your financial future by setting your first savings goal.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.gray600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGoalAction(String action, Map<String, dynamic> goal) {
    switch (action) {
      case 'edit':
        _showEditGoalDialog(goal);
        break;
      case 'contribute':
        _showContributionDialog(goal);
        break;
      case 'delete':
        _showDeleteConfirmation(goal);
        break;
    }
  }

  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Savings Goal'),
            content: const Text('Goal creation form coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showEditGoalDialog(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit ${goal['name']}'),
            content: const Text('Goal editing form coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showContributionDialog(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add to ${goal['name']}'),
            content: const Text('Contribution form coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added \$100 to ${goal['name']}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Add \$100'),
              ),
            ],
          ),
    );
  }

  void _showGoalDetails(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(goal['name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Amount: \$${goal['targetAmount'].toStringAsFixed(0)}',
                ),
                Text(
                  'Current Amount: \$${goal['currentAmount'].toStringAsFixed(0)}',
                ),
                Text(
                  'Target Date: ${DateFormat('MMM dd, yyyy').format(goal['targetDate'])}',
                ),
                Text(
                  'Monthly Target: \$${goal['monthlyTarget'].toStringAsFixed(0)}',
                ),
                Text('Priority: ${goal['priority']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Goal'),
            content: Text('Are you sure you want to delete "${goal['name']}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _goals.removeWhere((g) => g['id'] == goal['id']);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted ${goal['name']}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
