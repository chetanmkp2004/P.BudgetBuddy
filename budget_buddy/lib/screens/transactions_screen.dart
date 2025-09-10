import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../core/api/finance_provider.dart';
import '../core/api/finance_service.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _filter = 'All';
  bool _loading = false;
  int _page = 1;
  bool _hasMore = true;
  final List<TransactionModel> _all = [];
  FinanceService? _service;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthState>();
    if (_service == null || _service!.token != auth.accessToken) {
      final provider = context.read<FinanceProvider>();
      _service = provider.service;
      _loadPage(refresh: true);
    }
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
        !_loading &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _loadPage({bool refresh = false}) async {
    setState(() => _loading = true);
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _all.clear();
    }
    try {
      final svc = _service;
      if (svc == null) return;
      final items = await svc.fetchTransactions(page: _page);
      if (items.isEmpty) {
        _hasMore = false;
      } else {
        _all.addAll(items);
        _page += 1;
      }
    } catch (e) {
      // ignore for now; reach could show snackbar
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _all.where((t) {
          final name = (t.merchant ?? t.description ?? '').toLowerCase();
          final matchesQuery =
              _query.isEmpty || name.contains(_query.toLowerCase());
          final matchesFilter =
              _filter == 'All' ||
              (_filter == 'Income' && t.isIncome) ||
              (_filter == 'Expense' && t.isExpense);
          return matchesQuery && matchesFilter;
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      hintText: 'Search merchant...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => _filter = v),
                  itemBuilder:
                      (c) => const [
                        PopupMenuItem(value: 'All', child: Text('All')),
                        PopupMenuItem(value: 'Income', child: Text('Income')),
                        PopupMenuItem(value: 'Expense', child: Text('Expense')),
                      ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _filter,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadPage(refresh: true),
              child:
                  filtered.isEmpty && !_loading
                      ? Center(
                        child: Text(
                          'No transactions found',
                          style: AppTextStyles.body1,
                        ),
                      )
                      : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: filtered.length + (_loading ? 1 : 0),
                        itemBuilder: (c, i) {
                          if (i >= filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return TransactionTile(tx: filtered[i]);
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
