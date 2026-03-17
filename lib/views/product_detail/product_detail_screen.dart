import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final cartController = context.watch<CartController>();
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(product.image, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(product.price),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          currencyFormat.format(product.oldPrice),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Variations section (placeholder)
                  if (product.variations != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chọn Size / Màu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children: product.variations!
                              .map((v) => Chip(label: Text(v)))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  // Description
                  _ExpandableDescription(description: product.description),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {},
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    // TODO: Navigate to cart screen
                  },
                ),
                if (cartController.items.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cartController.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddToCartSheet(context, product);
                      },
                      child: const Text('Thêm vào giỏ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        // TODO: Buy now logic
                        _showAddToCartSheet(context, product, buyNow: true);
                      },
                      child: const Text('Mua ngay'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToCartSheet(
    BuildContext context,
    ProductModel product, {
    bool buyNow = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int quantity = 1;
        String? selectedSize;
        String? selectedColor;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(product.image),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (product.variations != null)
                      Wrap(
                        spacing: 8,
                        children: product.variations!
                            .map(
                              (v) => ChoiceChip(
                                label: Text(v),
                                selected: selectedSize == v,
                                onSelected: (_) =>
                                    setState(() => selectedSize = v),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Số lượng:'),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final cartItem = CartItemModel(
                                productId: product.id.toString(),
                                name: product.title,
                                image: product.image,
                                price: product.price,
                                size: selectedSize,
                                color: selectedColor,
                                quantity: quantity,
                              );
                              final cartController = context
                                  .read<CartController>();
                              cartController.addToCart(cartItem);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã thêm vào giỏ hàng!'),
                                ),
                              );
                              if (buyNow) {
                                // TODO: Navigate to checkout screen
                              }
                            },
                            child: Text(buyNow ? 'Mua ngay' : 'Xác nhận'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String description;
  const _ExpandableDescription({Key? key, required this.description})
    : super(key: key);

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final lines = widget.description.split('\n');
    final showExpand = lines.length > 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          expanded ? widget.description : lines.take(5).join('\n'),
          style: const TextStyle(fontSize: 15),
        ),
        if (showExpand)
          TextButton(
            onPressed: () => setState(() => expanded = !expanded),
            child: Text(expanded ? 'Thu gọn' : 'Xem thêm'),
          ),
      ],
    );
  }
}
