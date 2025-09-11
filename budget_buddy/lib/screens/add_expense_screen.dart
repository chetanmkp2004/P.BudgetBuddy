import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_state.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddExpenseScreen({super.key, this.transaction});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Animations
  late final AnimationController _slideCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  // State
  CategoryModel? _selectedCategory;
  AccountModel? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _loading = false;
  bool _recurring = false;
  String _recurringFrequency = 'Monthly';
  bool _splitEnabled = false;
  final List<SplitPerson> _splitWith = [];
  File? _receiptImage;
  bool _showImageSheet = false;
  bool _editing = false;

  // Data
  List<CategoryModel> _categories = [];
  List<AccountModel> _accounts = [];
  final _recurringOptions = const [
    'Daily',
    'Weekly',
    'Bi-weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
  ];

  // Services
  late final TransactionService _txService;
  late final CategoryService _catService;
  late final AccountService _acctService;

  @override
  void initState() {
    super.initState();
    _editing = widget.transaction != null;
    _initAnimations();
    _initServices();
    if (_editing) _fillFromTransaction();
    _loadData();
  }

  void _initAnimations() {
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, .2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(
      begin: .95,
      end: 1,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideCtrl.forward();
      _scaleCtrl.forward();
    });
  }

  void _initServices() {
    final auth = context.read<AuthState>();
    _txService = TransactionService(auth);
    _catService = CategoryService(auth);
    _acctService = AccountService(auth);
  }

  void _fillFromTransaction() {
    final t = widget.transaction!;
    _amountCtrl.text = t.amount.toStringAsFixed(2);
    _descCtrl.text = t.description ?? t.merchant ?? '';
    final base = t.date ?? t.txnTime;
    _selectedDate = base;
    _selectedTime = TimeOfDay.fromDateTime(base);
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cats = await _catService.getCategories();
      final accs = await _acctService.getAccounts();
      setState(() {
        _categories =
            cats.where((c) => c.type.toLowerCase() == 'expense').toList();
        _accounts = accs;
        if (_accounts.isNotEmpty && _selectedAccount == null) {
          _selectedAccount = _accounts.first;
        }
        if (_editing) {
          final txn = widget.transaction!;
          if (txn.categoryId != null && _categories.isNotEmpty) {
            _selectedCategory = _categories.firstWhere(
              (c) => c.id == txn.categoryId,
              orElse: () => _categories.first,
            );
          }
          if (txn.accountId != null && _accounts.isNotEmpty) {
            _selectedAccount = _accounts.firstWhere(
              (a) => a.id == txn.accountId,
              orElse: () => _accounts.first,
            );
          }
        }
      });
    } catch (e) {
      _snack('Failed to load data: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _scaleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Expense' : 'Add Expense'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          _loading && _categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SlideTransition(
                position: _slide,
                child: ScaleTransition(scale: _scale, child: _formBody()),
              ),
    );
  }

  Widget _formBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _amountField(),
          _textField(
            controller: _descCtrl,
            label: 'Description',
            icon: Icons.description_outlined,
            validator:
                (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Please enter a description'
                        : null,
          ),
          const SizedBox(height: 16),
          _categorySelector(),
          const SizedBox(height: 16),
          _dateTimeRow(),
          const SizedBox(height: 16),
          _accountDropdown(),
          const SizedBox(height: 16),
          _textField(
            controller: _notesCtrl,
            label: 'Notes',
            icon: Icons.note_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _receiptCard(),
          const SizedBox(height: 16),
          _recurringTile(),
          if (_recurring) ...[const SizedBox(height: 12), _frequencyDropdown()],
          const SizedBox(height: 16),
          _splitTile(),
          if (_splitEnabled) _splitSection(),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              child:
                  _loading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(_editing ? 'Update Expense' : 'Save Expense'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text('₹', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter an amount';
                final d = double.tryParse(v);
                if (d == null || d <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _categorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final c = _categories[i];
              final selected = _selectedCategory?.id == c.id;
              final color = _categoryColor(c);
              return InkWell(
                onTap: () => setState(() => _selectedCategory = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 84,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? color.withValues(alpha: 0.18)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          selected
                              ? color
                              : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.4),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_categoryIcon(c), color: color, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        c.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: _categories.length,
          ),
        ),
      ],
    );
  }

  Widget _dateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Time',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_selectedTime.format(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountDropdown() {
    return DropdownButtonFormField<AccountModel>(
      value: _selectedAccount,
      decoration: InputDecoration(
        labelText: 'Account',
        prefixIcon: const Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          _accounts
              .map(
                (a) => DropdownMenuItem(
                  value: a,
                  child: Text('${a.name} (${a.balance.toStringAsFixed(2)})'),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => _selectedAccount = v),
    );
  }

  Widget _receiptCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_outlined),
                const SizedBox(width: 8),
                Text(
                  'Receipt Image',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_receiptImage != null)
                  IconButton(
                    onPressed: () => setState(() => _receiptImage = null),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_receiptImage == null)
              InkWell(
                onTap: () => setState(() => _showImageSheet = true),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 6),
                        const Text('Add Receipt Image'),
                        Text(
                          'Take a photo or upload from gallery',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _receiptImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (_showImageSheet)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take Photo'),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from Gallery'),
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.close),
                      title: const Text('Cancel'),
                      onTap: () => setState(() => _showImageSheet = false),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _recurringTile() {
    return SwitchListTile(
      title: const Text('Recurring Expense'),
      subtitle: const Text('Set this as a repeating expense'),
      value: _recurring,
      onChanged: (v) => setState(() => _recurring = v),
      secondary: const Icon(Icons.repeat),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _frequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _recurringFrequency,
      decoration: InputDecoration(
        labelText: 'Frequency',
        prefixIcon: const Icon(Icons.calendar_view_month),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          _recurringOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      onChanged:
          (v) => setState(() => _recurringFrequency = v ?? _recurringFrequency),
    );
  }

  Widget _splitTile() {
    return ListTile(
      title: const Text('Split Expense'),
      subtitle: const Text('Divide this expense with others'),
      leading: const Icon(Icons.people_outline),
      trailing: Switch(
        value: _splitEnabled,
        onChanged: (_) => setState(() => _splitEnabled = !_splitEnabled),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _splitSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split With', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(_splitWith.length, (i) {
              final p = _splitWith[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: p.name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged:
                            (v) => setState(
                              () => _splitWith[i] = p.copyWith(name: v),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: p.amount > 0 ? p.amount.toString() : '',
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged:
                            (v) => setState(
                              () =>
                                  _splitWith[i] = p.copyWith(
                                    amount: double.tryParse(v) ?? 0,
                                  ),
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _splitWith.removeAt(i)),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            }),
            Center(
              child: OutlinedButton.icon(
                onPressed:
                    () => setState(
                      () => _splitWith.add(
                        const SplitPerson(name: '', amount: 0),
                      ),
                    ),
                icon: const Icon(Icons.add),
                label: const Text('Add Person'),
              ),
            ),
            if (_splitWith.isNotEmpty && _amountCtrl.text.isNotEmpty) ...[
              const Divider(height: 32),
              Row(
                children: [
                  Text(
                    'Your share: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '₹${_yourShare().toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _categoryColor(CategoryModel c) {
    if ((c.color ?? '').isNotEmpty) {
      try {
        return Color(int.parse(c.color!.replaceAll('#', '0xFF')));
      } catch (_) {}
    }
    switch (c.name.toLowerCase()) {
      case 'food & drink':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'bills & utilities':
        return Colors.red;
      case 'entertainment':
        return Colors.pink;
      case 'healthcare':
        return Colors.teal;
      case 'groceries':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(CategoryModel c) {
    switch (c.name.toLowerCase()) {
      case 'food & drink':
        return Icons.restaurant_rounded;
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills & utilities':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'healthcare':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'groceries':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _showImageSheet = false);
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (file != null) setState(() => _receiptImage = File(file.path));
  }

  double _yourShare() {
    final total = double.tryParse(_amountCtrl.text) ?? 0;
    final other = _splitWith.fold<double>(0, (s, p) => s + p.amount);
    return (total - other).clamp(0, total);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      return _snack('Please select a category', isError: true);
    }
    if (_selectedAccount == null) {
      return _snack('Please select an account', isError: true);
    }

    setState(() => _loading = true);
    try {
      final amount = double.parse(_amountCtrl.text);
      final description = _descCtrl.text.trim();
      final date = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final tx = TransactionModel(
        id: _editing ? widget.transaction!.id : '',
        direction: 'out',
        amount: amount,
        txnTime: date,
        merchant: description,
        description: description,
        categoryId: _selectedCategory!.id,
        accountId: _selectedAccount!.id,
        date: date,
        categoryName: _selectedCategory!.name,
      );

      if (_editing) {
        await _txService.updateTransaction(tx);
      } else {
        await _txService.createTransaction(tx);
      }

      if (!mounted) return;
      _snack('Expense saved successfully');
      Navigator.of(context).pop(true);
    } catch (e) {
      _snack('Failed to save expense: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

class SplitPerson {
  final String name;
  final double amount;
  const SplitPerson({required this.name, required this.amount});
  SplitPerson copyWith({String? name, double? amount}) =>
      SplitPerson(name: name ?? this.name, amount: amount ?? this.amount);
}
