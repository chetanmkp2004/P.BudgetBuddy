class AccountModel {
  final String id;
  final String name;
  final String type; // checking, savings, credit, investment, etc.
  final double balance;
  final String? currency;
  final String? institution;
  final bool? isActive;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency,
    this.institution,
    this.isActive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
    id: j['id'].toString(),
    name: j['name'] ?? '',
    type: j['type'] ?? '',
    balance:
        (j['balance'] is num)
            ? (j['balance'] as num).toDouble()
            : double.tryParse(j['balance']?.toString() ?? '0') ?? 0,
    currency: j['currency'],
    institution: j['institution'],
    isActive: j['is_active'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'balance': balance,
    if (currency != null) 'currency': currency,
    if (institution != null) 'institution': institution,
    if (isActive != null) 'is_active': isActive,
  };
}
