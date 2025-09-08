class TransactionModel {
  final String id;
  final String merchant;
  final String category;
  final double amount;
  final DateTime date;
  final bool isExpense;

  TransactionModel({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
}
