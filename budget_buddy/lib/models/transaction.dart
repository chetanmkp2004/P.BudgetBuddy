class TransactionModel {
  final String id;
  final String? merchant;
  final String? description;
  final String?
  categoryName; // convenience resolved name (extra fetch or local map)
  final int? categoryId;
  final String direction; // 'in' | 'out' | 'transfer'
  final double amount;
  final DateTime txnTime;
  final bool isPending;
  final String? accountId;

  bool get isExpense => direction == 'out';
  bool get isIncome => direction == 'in';

  TransactionModel({
    required this.id,
    required this.direction,
    required this.amount,
    required this.txnTime,
    this.merchant,
    this.description,
    this.categoryName,
    this.categoryId,
    this.isPending = false,
    this.accountId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
    id: j['id'].toString(),
    direction: j['direction'] ?? 'out',
    amount:
        (j['amount'] is num)
            ? (j['amount'] as num).toDouble()
            : double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
    txnTime: DateTime.tryParse(j['txn_time'] ?? '') ?? DateTime.now(),
    merchant: j['merchant'],
    description: j['description'],
    categoryId: j['category'],
    isPending: j['is_pending'] ?? false,
    accountId: j['account']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'direction': direction,
    'amount': amount,
    'txn_time': txnTime.toIso8601String(),
    if (merchant != null) 'merchant': merchant,
    if (description != null) 'description': description,
    if (categoryId != null) 'category': categoryId,
    'is_pending': isPending,
    if (accountId != null) 'account': accountId,
  };
}
