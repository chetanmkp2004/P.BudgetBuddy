import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

/// Professional budget management screen with visual progress tracking
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<BudgetCategory> _budgetCategories = _generateMockBudgets();
  String _selectedPeriod = 'This Month';

  final List<String> _periods = [
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBudgetData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  void _loadBudgetData() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                _buildOverviewCard(),
                const SizedBox(height: 24),
                _buildBudgetChart(),
                const SizedBox(height: 24),
                _buildCategoriesList(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_rounded, color: AppTheme.gray900),
        ),
      ),
      title: Text(
        'Budget Management',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.gray900,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showBudgetSettings,
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.settings_rounded, color: AppTheme.gray900),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = _selectedPeriod == period;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _periods.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.gray300,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  period,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppTheme.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard() {
    final totalBudget = _budgetCategories.fold<double>(
      0.0,
      (sum, category) => sum + category.budgetAmount,
    );
    final totalSpent = _budgetCategories.fold<double>(
      0.0,
      (sum, category) => sum + category.spentAmount,
    );
    final remaining = totalBudget - totalSpent;
    final progressPercentage =
        totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              progressPercentage > 0.8
                  ? [AppTheme.error, AppTheme.warning]
                  : progressPercentage > 0.6
                  ? [AppTheme.warning, Color(0xFFF59E0B)]
                  : [AppTheme.secondaryGreen, Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (progressPercentage > 0.8
                    ? AppTheme.error
                    : AppTheme.secondaryGreen)
                .withValues(alpha: 0.3),
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
              Icon(
                progressPercentage > 0.8
                    ? Icons.warning_rounded
                    : Icons.analytics_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Budget Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
                      'Total Budget',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '\$${totalBudget.toStringAsFixed(2)}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '\$${remaining.toStringAsFixed(2)}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: progressPercentage.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressPercentage > 1.0 ? Colors.red : Colors.white,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChart() {
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
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections:
                    _budgetCategories.map((category) {
                      final percentage =
                          (category.spentAmount /
                              _budgetCategories.fold<double>(
                                0,
                                (sum, c) => sum + c.spentAmount,
                              )) *
                          100;

                      return PieChartSectionData(
                        value: category.spentAmount,
                        color: category.color,
                        title:
                            '${category.name}\n${percentage.toStringAsFixed(1)}%',
                        titleStyle: TextStyle(
                          fontSize: 11,
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

  Widget _buildCategoriesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),

        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _budgetCategories.length,
          itemBuilder: (context, index) {
            final category = _budgetCategories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(category),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BudgetCategory category) {
    final progress =
        category.budgetAmount > 0
            ? (category.spentAmount / category.budgetAmount)
            : 0.0;
    final isOverBudget = progress > 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isOverBudget ? Border.all(color: AppTheme.error, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  color: category.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                          ),
                        ),
                        if (isOverBudget)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Over Budget',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${category.spentAmount.toStringAsFixed(2)} of \$${category.budgetAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.gray600),
                        ),
                        Text(
                          '\$${(category.budgetAmount - category.spentAmount).toStringAsFixed(2)} left',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                isOverBudget
                                    ? AppTheme.error
                                    : AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverBudget ? AppTheme.error : AppTheme.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppTheme.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? AppTheme.error : category.color,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Create Budget',
            onPressed: _createNewBudget,
            type: ButtonType.primary,
            icon: Icons.add_rounded,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: CustomButton(
            text: 'View Reports',
            onPressed: _viewReports,
            type: ButtonType.outline,
            icon: Icons.bar_chart_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _editBudgets,
      child: Icon(Icons.edit_rounded),
    );
  }

  void _showBudgetSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Budget Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // TODO: Add budget settings content
              ],
            ),
          ),
    );
  }

  void _createNewBudget() {
    // TODO: Navigate to create budget screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Create Budget feature coming soon!'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  void _viewReports() {
    // TODO: Navigate to budget reports screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget Reports feature coming soon!'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  void _editBudgets() {
    // TODO: Navigate to edit budgets screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit Budgets feature coming soon!'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Refresh data
    });
  }

  static List<BudgetCategory> _generateMockBudgets() {
    return [
      BudgetCategory(
        name: 'Food & Dining',
        icon: Icons.restaurant_rounded,
        color: AppTheme.warning,
        budgetAmount: 600.0,
        spentAmount: 487.50,
      ),
      BudgetCategory(
        name: 'Transportation',
        icon: Icons.directions_car_rounded,
        color: AppTheme.primaryBlue,
        budgetAmount: 300.0,
        spentAmount: 245.30,
      ),
      BudgetCategory(
        name: 'Shopping',
        icon: Icons.shopping_bag_rounded,
        color: AppTheme.purple,
        budgetAmount: 400.0,
        spentAmount: 523.75, // Over budget
      ),
      BudgetCategory(
        name: 'Entertainment',
        icon: Icons.movie_rounded,
        color: AppTheme.pink,
        budgetAmount: 200.0,
        spentAmount: 156.80,
      ),
      BudgetCategory(
        name: 'Bills & Utilities',
        icon: Icons.receipt_long_rounded,
        color: AppTheme.error,
        budgetAmount: 800.0,
        spentAmount: 675.20,
      ),
      BudgetCategory(
        name: 'Healthcare',
        icon: Icons.local_hospital_rounded,
        color: AppTheme.info,
        budgetAmount: 150.0,
        spentAmount: 89.50,
      ),
    ];
  }
}

class BudgetCategory {
  final String name;
  final IconData icon;
  final Color color;
  final double budgetAmount;
  final double spentAmount;

  BudgetCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.budgetAmount,
    required this.spentAmount,
  });
}
