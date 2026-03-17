import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../services/firestore_service.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../checkout/checkout_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final selectedItems = cartController.selectedCartItems;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ nhận hàng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(hintText: 'Nhập địa chỉ'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'COD',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
                const Text('COD'),
                Radio<String>(
                  value: 'Momo',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
                const Text('Momo'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sản phẩm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  return ListTile(
                    leading: Image.network(
                      item.image,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Text('x${item.quantity}'),
                    trailing: Text(
                      currencyFormat.format(item.price * item.quantity),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_addressController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng nhập địa chỉ'),
                            ),
                          );
                          return;
                        }
                        setState(() => _isLoading = true);
                        try {
                          final authController = Provider.of<AuthController>(
                            context,
                            listen: false,
                          );
                          final userId = authController.user?.uid ?? '';
                          if (userId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bạn cần đăng nhập để đặt hàng!'),
                              ),
                            );
                            setState(() => _isLoading = false);
                            return;
                          }
                          final orderData = {
                            'items': selectedItems
                                .map((e) => e.toJson())
                                .toList(),
                            'address': _addressController.text,
                            'paymentMethod': _paymentMethod,
                            'status': 'Chờ xác nhận',
                            'createdAt': DateTime.now(),
                            'totalPrice': cartController.totalPrice,
                          };
                          await FirestoreService().saveOrder(userId, orderData);
                          cartController.removeSelectedItems();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Đặt hàng thành công!'),
                              content: const Text('Cảm ơn bạn đã mua hàng.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đặt hàng thất bại!')),
                          );
                        }
                        setState(() => _isLoading = false);
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
