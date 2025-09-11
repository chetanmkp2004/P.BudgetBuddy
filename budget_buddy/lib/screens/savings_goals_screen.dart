import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

/// Professional savings goals screen with creation wizard and progress tracking
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<SavingsGoal> _savingsGoals = _generateMockGoals();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavingsData();
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

  void _loadSavingsData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() => _isLoading = false);
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
                if (_isLoading) const LinearProgressIndicator(minHeight: 3),
                _buildOverviewCard(),
                const SizedBox(height: 24),
                _buildGoalsList(),
                const SizedBox(height: 100), // Space for FAB
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
        'Savings Goals',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.gray900,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showSavingsInsights,
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.insights_rounded, color: AppTheme.gray900),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    final totalGoalAmount = _savingsGoals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final totalSavedAmount = _savingsGoals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final overallProgress =
        totalGoalAmount > 0 ? (totalSavedAmount / totalGoalAmount) : 0.0;

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
              Icon(Icons.savings_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Savings Overview',
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
                      'Total Saved',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '\$${totalSavedAmount.toStringAsFixed(2)}',
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
                      'Total Goals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '\$${totalGoalAmount.toStringAsFixed(2)}',
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
                    'Overall Progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: overallProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_savingsGoals.length} active goals',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Goals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),

        const SizedBox(height: 16),

        if (_savingsGoals.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savingsGoals.length,
            itemBuilder: (context, index) {
              final goal = _savingsGoals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGoalCard(goal),
              );
            },
          ),
      ],
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final progress =
        goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isCompleted = progress >= 1.0;
    final isOverdue = daysLeft < 0 && !isCompleted;

    return GestureDetector(
      onTap: () => _showGoalDetails(goal),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              isCompleted
                  ? Border.all(color: AppTheme.success, width: 2)
                  : isOverdue
                  ? Border.all(color: AppTheme.error, width: 2)
                  : null,
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 28),
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
                              goal.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.success,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Completed',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (isOverdue)
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
                                'Overdue',
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
                        children: [
                          Text(
                            '\$${goal.currentAmount.toStringAsFixed(2)} of \$${goal.targetAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.gray600),
                          ),
                          const Spacer(),
                          Text(
                            daysLeft >= 0
                                ? '$daysLeft days left'
                                : '${-daysLeft} days over',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  isOverdue ? AppTheme.error : AppTheme.gray600,
                              fontWeight: FontWeight.w500,
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
                        color: AppTheme.gray700,
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
                    isCompleted ? AppTheme.success : goal.color,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Add Money',
                        onPressed: () => _addMoney(goal),
                        type: ButtonType.outline,
                        size: ButtonSize.small,
                        icon: Icons.add_rounded,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: CustomButton(
                        text: 'View Details',
                        onPressed: () => _showGoalDetails(goal),
                        type: ButtonType.ghost,
                        size: ButtonSize.small,
                        icon: Icons.visibility_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
        children: [
          Icon(Icons.savings_rounded, size: 80, color: AppTheme.gray400),

          const SizedBox(height: 20),

          Text(
            'No Savings Goals Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Start building your financial future by\ncreating your first savings goal',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
          ),

          const SizedBox(height: 24),

          CustomButton(
            text: 'Create Your First Goal',
            onPressed: _createNewGoal,
            type: ButtonType.primary,
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _createNewGoal,
      label: Text('New Goal'),
      icon: Icon(Icons.add_rounded),
    );
  }

  void _createNewGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateGoalBottomSheet(),
    );
  }

  void _addMoney(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => _AddMoneyDialog(goal: goal),
    );
  }

  void _showGoalDetails(SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalDetailsBottomSheet(goal: goal),
    );
  }

  void _showSavingsInsights() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SavingsInsightsBottomSheet(),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Refresh data
    });
  }

  static List<SavingsGoal> _generateMockGoals() {
    return [
      SavingsGoal(
        id: '1',
        name: 'Emergency Fund',
        targetAmount: 10000.0,
        currentAmount: 6750.0,
        targetDate: DateTime.now().add(const Duration(days: 120)),
        icon: Icons.security_rounded,
        color: AppTheme.primaryBlue,
      ),
      SavingsGoal(
        id: '2',
        name: 'Vacation to Europe',
        targetAmount: 3500.0,
        currentAmount: 1200.0,
        targetDate: DateTime.now().add(const Duration(days: 180)),
        icon: Icons.flight_rounded,
        color: AppTheme.purple,
      ),
      SavingsGoal(
        id: '3',
        name: 'New Car',
        targetAmount: 25000.0,
        currentAmount: 8500.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        icon: Icons.directions_car_rounded,
        color: AppTheme.secondaryGreen,
      ),
      SavingsGoal(
        id: '4',
        name: 'Home Down Payment',
        targetAmount: 50000.0,
        currentAmount: 50000.0, // Completed goal
        targetDate: DateTime.now().subtract(const Duration(days: 30)),
        icon: Icons.home_rounded,
        color: AppTheme.success,
      ),
    ];
  }
}

// Create Goal Bottom Sheet Widget
class _CreateGoalBottomSheet extends StatefulWidget {
  @override
  State<_CreateGoalBottomSheet> createState() => _CreateGoalBottomSheetState();
}

class _CreateGoalBottomSheetState extends State<_CreateGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  IconData _selectedIcon = Icons.savings_rounded;
  Color _selectedColor = AppTheme.primaryBlue;
  bool _isLoading = false;

  final List<IconData> _icons = [
    Icons.savings_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.school_rounded,
    Icons.phone_iphone_rounded,
    Icons.laptop_rounded,
    Icons.beach_access_rounded,
  ];

  final List<Color> _colors = [
    AppTheme.primaryBlue,
    AppTheme.secondaryGreen,
    AppTheme.purple,
    AppTheme.pink,
    AppTheme.warning,
    AppTheme.info,
    AppTheme.teal,
    AppTheme.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
              'Create New Goal',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Goal Name',
                        hintText: 'What are you saving for?',
                        prefixIcon: Icon(Icons.flag_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a goal name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Target amount field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Target Amount',
                        hintText: '0.00',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a target amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Date selection
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.gray300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: AppTheme.gray600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Target Date',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppTheme.gray600),
                                  ),
                                  Text(
                                    '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.gray900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppTheme.gray400,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Icon selection
                    Text(
                      'Choose Icon',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        final isSelected = _selectedIcon == icon;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? _selectedColor.withValues(alpha: 0.1)
                                      : AppTheme.gray100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? _selectedColor
                                        : AppTheme.gray300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color:
                                  isSelected
                                      ? _selectedColor
                                      : AppTheme.gray600,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Color selection
                    Text(
                      'Choose Color',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _colors.length,
                      itemBuilder: (context, index) {
                        final color = _colors[index];
                        final isSelected = _selectedColor == color;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: AppTheme.gray900,
                                        width: 3,
                                      )
                                      : null,
                            ),
                            child:
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                    : null,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.of(context).pop(),
                            type: ButtonType.outline,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: CustomButton(
                            text: 'Create Goal',
                            onPressed: _isLoading ? null : _createGoal,
                            type: ButtonType.primary,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _targetDate) {
      setState(() {
        _targetDate = pickedDate;
      });
    }
  }

  void _createGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Goal created successfully!'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create goal. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// Add Money Dialog Widget
class _AddMoneyDialog extends StatefulWidget {
  final SavingsGoal goal;

  const _AddMoneyDialog({required this.goal});

  @override
  State<_AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<_AddMoneyDialog> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Money to ${widget.goal.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Amount to Add',
              hintText: '0.00',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        CustomButton(
          text: 'Add Money',
          onPressed: _isLoading ? null : _addMoney,
          type: ButtonType.primary,
          size: ButtonSize.small,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  void _addMoney() async {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '\$${amount.toStringAsFixed(2)} added to ${widget.goal.name}!',
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add money. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// Goal Details Bottom Sheet Widget
class _GoalDetailsBottomSheet extends StatelessWidget {
  final SavingsGoal goal;

  const _GoalDetailsBottomSheet({required this.goal});

  @override
  Widget build(BuildContext context) {
    // Detailed stats can be computed when needed in UI; suppress unused warnings

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 32),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TODO: Add goal details content
          Expanded(
            child: Center(
              child: Text(
                'Goal details coming soon!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Savings Insights Bottom Sheet Widget
class _SavingsInsightsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Savings Insights',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          // TODO: Add savings insights content
          Expanded(
            child: Center(
              child: Text(
                'Savings insights coming soon!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final IconData icon;
  final Color color;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.icon,
    required this.color,
  });
}
