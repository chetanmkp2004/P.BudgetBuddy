import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_state.dart';
import '../core/api/finance_provider.dart';

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

  final List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = false;
  Map<String, int> _categoryNameToId = {};
  // Accounts
  List<Map<String, dynamic>> _accounts = [];
  String? _selectedAccountName;
  bool _loadingAccounts = false;

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categories.isEmpty && !_loadingCategories) {
      _fetchCategories();
    }
    if (_accounts.isEmpty && !_loadingAccounts) {
      _fetchAccounts();
    }
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
                            _buildAccountSection(),
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
    if (_loadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _categories.isEmpty ? null : _selectedCategory,
          items:
              _categories
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c['name'] as String,
                      child: Text(c['name'] as String),
                    ),
                  )
                  .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _selectedCategory = v);
            }
          },
          decoration: const InputDecoration(labelText: 'Select Category'),
          validator: (v) {
            if ((v == null || v.isEmpty) && _categories.isNotEmpty)
              return 'Pick a category';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    if (_loadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _accounts.isEmpty ? null : _selectedAccountName,
          items:
              _accounts
                  .map(
                    (a) => DropdownMenuItem<String>(
                      value: a['name'] as String,
                      child: Text(a['name'] as String),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _selectedAccountName = v),
          decoration: const InputDecoration(labelText: 'Select Account'),
          validator: (v) {
            if ((v == null || v.isEmpty) && _accounts.isNotEmpty) {
              return 'Pick an account';
            }
            return null;
          },
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
      final auth = context.read<AuthState>();
      final service =
          context.read<FinanceProvider>().service..token = auth.accessToken;
      final amount = double.parse(_amountController.text);
      await service.createTransaction(
        amount: amount,
        merchant: _merchantController.text,
        description: _notesController.text,
        categoryId: _categoryNameToId[_selectedCategory],
        accountId: _accountNameToId[_selectedAccountName],
        txnTime: _selectedDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense saved'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final finance = context.read<FinanceProvider>().service;
      final list = await finance.fetchCategories();
      _categories.clear();
      for (final c in list) {
        final name = c['name'] ?? c['title'] ?? 'Unnamed';
        final id = c['id'];
        if (id != null) {
          _categoryNameToId[name] =
              id is int ? id : int.tryParse(id.toString()) ?? 0;
        }
        _categories.add({'name': name});
      }
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['name'];
      }
    } catch (_) {
      // silent fail keeps UI functional
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  final Map<String, int> _accountNameToId = {};
  Future<void> _fetchAccounts() async {
    setState(() => _loadingAccounts = true);
    try {
      final finance = context.read<FinanceProvider>().service;
      final accModels = await finance.fetchAccounts();
      _accounts = accModels.map((a) => {'id': a.id, 'name': a.name}).toList();
      _accountNameToId.clear();
      for (final a in _accounts) {
        final idRaw = a['id'];
        final id = int.tryParse(idRaw.toString());
        if (id != null) _accountNameToId[a['name'] as String] = id;
      }
      if (_accounts.isNotEmpty) {
        _selectedAccountName = _accounts.first['name'] as String;
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingAccounts = false);
    }
  }
}
