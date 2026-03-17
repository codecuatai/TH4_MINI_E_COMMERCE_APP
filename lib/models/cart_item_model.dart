class CartItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final String? size;
  final String? color;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    this.size,
    this.color,
    this.quantity = 1,
  });

  String get uniqueKey => '$productId-${size ?? ''}-${color ?? ''}';

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'],
      name: json['name'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }
}
