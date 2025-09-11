class SchemeModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime validUntil;
  final String? promoCode;
  final String? url;
  final String? category;
  final double? discount;
  final bool isFavorite;

  SchemeModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.validUntil,
    this.promoCode,
    this.url,
    this.category,
    this.discount,
    this.isFavorite = false,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      validUntil: DateTime.parse(json['valid_until']),
      promoCode: json['promo_code'],
      url: json['url'],
      category: json['category'],
      discount:
          json['discount'] != null
              ? (json['discount'] is num)
                  ? (json['discount'] as num).toDouble()
                  : double.tryParse(json['discount'].toString())
              : null,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      'valid_until': validUntil.toIso8601String(),
      if (promoCode != null) 'promo_code': promoCode,
      if (url != null) 'url': url,
      if (category != null) 'category': category,
      if (discount != null) 'discount': discount,
      'is_favorite': isFavorite,
    };
  }
}
