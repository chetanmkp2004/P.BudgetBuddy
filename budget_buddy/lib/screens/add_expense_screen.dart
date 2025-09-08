import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Food & Dining';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _enableLocation = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant,
      'color': AppColors.warning,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': AppColors.primaryBlue,
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': AppColors.success,
    },
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': AppColors.error},
    {
      'name': 'Bills & Utilities',
      'icon': Icons.receipt_long,
      'color': AppColors.gray600,
    },
    {
      'name': 'Healthcare',
      'icon': Icons.local_hospital,
      'color': AppColors.error,
    },
    {'name': 'Education', 'icon': Icons.school, 'color': AppColors.primaryBlue},
    {'name': 'Travel', 'icon': Icons.flight, 'color': AppColors.secondaryGreen},
    {'name': 'Personal Care', 'icon': Icons.face, 'color': AppColors.warning},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': AppColors.gray500},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Expense', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _scanReceipt,
            tooltip: 'Scan Receipt',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Use Expanded + SingleChildScrollView so content can grow without causing overflow
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            96, // approximate bottom section height
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAmountSection(),
                            const SizedBox(height: 32),
                            _buildCategorySection(),
                            const SizedBox(height: 24),
                            _buildDetailsSection(),
                            const SizedBox(height: 24),
                            _buildDateLocationSection(),
                            const SizedBox(
                              height: 120,
                            ), // extra space so last fields not obscured
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text('Amount', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: AppTextStyles.amountMedium.copyWith(
              color: AppColors.primaryBlue,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              prefixStyle: AppTextStyles.amountMedium.copyWith(
                color: AppColors.gray500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Amount is required';
              final amount = double.tryParse(value!);
              if (amount == null || amount <= 0) return 'Enter a valid amount';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.h4),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 100,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? category['color'].withValues(alpha: 0.1)
                            : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? category['color'] : AppColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'],
                        color:
                            isSelected ? category['color'] : AppColors.gray500,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name'],
                        style: AppTextStyles.caption.copyWith(
                          color:
                              isSelected
                                  ? category['color']
                                  : AppColors.gray600,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Details', style: AppTextStyles.h4),
        const SizedBox(height: 16),
        TextFormField(
          controller: _merchantController,
          decoration: const InputDecoration(
            labelText: 'Merchant/Store',
            hintText: 'Where did you spend?',
            prefixIcon: Icon(Icons.store),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Merchant is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Add any additional details...',
            prefixIcon: Icon(Icons.note),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date & Location', style: AppTextStyles.h4),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.gray600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: AppTextStyles.body1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Wrap in Expanded so the SwitchListTile receives bounded width constraints
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: SwitchListTile(
                  value: _enableLocation,
                  onChanged: (value) {
                    setState(() {
                      _enableLocation = value;
                    });
                  },
                  title: Text('Location', style: AppTextStyles.body2),
                  secondary: const Icon(Icons.location_on),
                  activeColor: AppColors.primaryBlue,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Expense'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _scanReceipt() {
    // TODO: Implement camera/receipt scanning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt scanning coming soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save expense to backend/local database
      await Future.delayed(const Duration(seconds: 2)); // Simulate network call

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save expense'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
