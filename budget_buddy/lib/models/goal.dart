class GoalModel {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String status; // active, paused, completed, canceled
  final String? notes;
  final List<GoalContribution>? contributions;

  // Derived fields for UI
  double get progressPercentage => currentAmount / targetAmount;
  bool get isCompleted =>
      currentAmount >= targetAmount || status == 'completed';

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.status,
    this.notes,
    this.contributions,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    List<GoalContribution>? contributions;
    if (json['contributions'] != null) {
      contributions = List<GoalContribution>.from(
        json['contributions'].map((x) => GoalContribution.fromJson(x)),
      );
    }

    return GoalModel(
      id: json['id'],
      name: json['name'] ?? '',
      targetAmount:
          (json['target_amount'] is num)
              ? (json['target_amount'] as num).toDouble()
              : double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      currentAmount:
          (json['current_amount'] is num)
              ? (json['current_amount'] as num).toDouble()
              : double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0,
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      status: json['status'] ?? 'active',
      notes: json['notes'],
      contributions: contributions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      if (deadline != null) 'deadline': deadline!.toIso8601String(),
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}

class GoalContribution {
  final int? id;
  final double amount;
  final DateTime contributedAt;
  final int? sourceAccountId;
  final String? note;

  GoalContribution({
    this.id,
    required this.amount,
    required this.contributedAt,
    this.sourceAccountId,
    this.note,
  });

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'],
      amount:
          (json['amount'] is num)
              ? (json['amount'] as num).toDouble()
              : double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      contributedAt: DateTime.parse(json['contributed_at']),
      sourceAccountId: json['source_account'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'contributed_at': contributedAt.toIso8601String(),
      if (sourceAccountId != null) 'source_account': sourceAccountId,
      if (note != null) 'note': note,
    };
  }
}
