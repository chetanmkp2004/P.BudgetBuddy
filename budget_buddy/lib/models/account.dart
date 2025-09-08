class AccountModel {
  final String id;
  final String name;
  final String type; // checking, savings, credit, investment
  final double balance;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });
}
