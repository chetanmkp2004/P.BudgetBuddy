class InsightModel {
  final int id;
  final String title;
  final String body;
  final String? severity; // info, warning, critical
  final DateTime generatedAt;
  final bool acknowledged;
  final Map<String, dynamic>? metadata;

  InsightModel({
    required this.id,
    required this.title,
    required this.body,
    this.severity,
    required this.generatedAt,
    this.acknowledged = false,
    this.metadata,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      severity: json['severity'],
      generatedAt: DateTime.parse(json['generated_at']),
      acknowledged: json['acknowledged'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      if (severity != null) 'severity': severity,
      'generated_at': generatedAt.toIso8601String(),
      'acknowledged': acknowledged,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
