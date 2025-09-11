class CategoryModel {
  final int id;
  final String name;
  final String type; // 'expense' or 'income'
  final String? icon;
  final String? color;
  final double? defaultBudgetLimit;
  final bool isCustom;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.defaultBudgetLimit,
    this.isCustom = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'expense',
      icon: json['icon'],
      color: json['color'],
      defaultBudgetLimit:
          (json['default_budget_limit'] is num)
              ? (json['default_budget_limit'] as num).toDouble()
              : double.tryParse(
                json['default_budget_limit']?.toString() ?? '0',
              ),
      isCustom: json['is_custom'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (defaultBudgetLimit != null)
        'default_budget_limit': defaultBudgetLimit,
      'is_custom': isCustom,
    };
  }
}
