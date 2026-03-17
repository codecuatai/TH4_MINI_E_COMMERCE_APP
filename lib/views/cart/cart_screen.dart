import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartController.items.length,
              itemBuilder: (context, index) {
                final item = cartController.items[index];
                return Dismissible(
                  key: Key(item.uniqueKey),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    cartController.removeFromCart(item.uniqueKey);
                  },
                  child: ListTile(
                    leading: Image.network(
                      item.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.size != null) Text('Size: ${item.size}'),
                        if (item.color != null) Text('Màu: ${item.color}'),
                        Text(currencyFormat.format(item.price)),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => cartController.updateQuantity(
                                item.uniqueKey,
                                item.quantity - 1,
                              ),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => cartController.updateQuantity(
                                item.uniqueKey,
                                item.quantity + 1,
                              ),
                            ),
                          ],
                        ),
                        Checkbox(
                          value:
                              cartController.selectedItems[item.uniqueKey] ??
                              false,
                          onChanged: (v) => cartController.selectItem(
                            item.uniqueKey,
                            v ?? false,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(
                  value: cartController.selectAll,
                  onChanged: (v) => cartController.selectAllItems(v ?? false),
                ),
                const Text('Chọn tất cả'),
                const Spacer(),
                Text(
                  'Tổng: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(cartController.totalPrice),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: cartController.selectedCartItems.isNotEmpty
                ? () {
                    final authController = Provider.of<AuthController>(
                      context,
                      listen: false,
                    );
                    if (!authController.isLoggedIn) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      // Navigate to checkout screen with selected items
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckoutScreen()),
                      );
                    }
                  }
                : null,
            child: const Text('Thanh toán'),
          ),
        ),
      ),
    );
  }
}
