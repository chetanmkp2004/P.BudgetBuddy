class BudgetModel {
  final int id;
  final int categoryId;
  final String categoryName; // Pre-resolved for UI convenience
  final String period; // monthly, weekly, yearly, custom
  final DateTime startDate;
  final DateTime endDate;
  final double limitAmount;
  final double spentAmount; // Calculated value from API
  final double remainingAmount; // Calculated value from API
  final String? categoryIcon;
  final String? categoryColor;

  // Derived fields for UI
  double get progressPercentage => spentAmount / limitAmount;
  bool get isExceeded => spentAmount > limitAmount;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    this.categoryIcon,
    this.categoryColor,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['budget_id'] ?? json['id'],
      categoryId: json['category_id'],
      categoryName: json['category'] ?? '',
      period: json['period'] ?? 'monthly',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      limitAmount:
          (json['limit_amount'] is num)
              ? (json['limit_amount'] as num).toDouble()
              : double.tryParse(json['limit_amount']?.toString() ?? '0') ?? 0,
      spentAmount:
          (json['spent'] is num)
              ? (json['spent'] as num).toDouble()
              : double.tryParse(json['spent']?.toString() ?? '0') ?? 0,
      remainingAmount:
          (json['remaining'] is num)
              ? (json['remaining'] as num).toDouble()
              : double.tryParse(json['remaining']?.toString() ?? '0') ?? 0,
      categoryIcon: json['category_icon'],
      categoryColor: json['category_color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': categoryId,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'limit_amount': limitAmount,
    };
  }
}
