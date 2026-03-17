class ProductModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final double price;
  final String category;
  final double rating;
  final int sold;
  final List<String>? variations; // e.g. size, color
  final double? oldPrice;
  final String? tag;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    required this.rating,
    required this.sold,
    this.variations,
    this.oldPrice,
    this.tag,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? '',
      rating: (json['rating'] is Map && json['rating']['rate'] != null)
          ? (json['rating']['rate'] as num).toDouble()
          : 0.0,
      sold: (json['rating'] is Map && json['rating']['count'] != null)
          ? (json['rating']['count'] as num).toInt()
          : 0,
      variations: null, // To be set in UI or extended API
      oldPrice: null, // To be set in UI or extended API
      tag: null, // To be set in UI or extended API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'category': category,
      'rating': rating,
      'sold': sold,
      'variations': variations,
      'oldPrice': oldPrice,
      'tag': tag,
    };
  }
}
