import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Consumer<CartController>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final isSelected = cart.selectedItems[item.uniqueKey] ?? false;

              return Dismissible(
                key: Key(item.uniqueKey),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => cart.removeFromCart(item.uniqueKey),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Checkbox bên trái (Tiêu chuẩn UX)
                        Checkbox(
                          value: isSelected,
                          activeColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => cart.toggleItemSelection(item.uniqueKey, val),
                        ),
                        // 2. Ảnh sản phẩm
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                              Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 3. Thông tin & Bộ đếm (Dùng Expanded để không bị tràn)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (item.size != null || item.color != null)
                                Text(
                                  "Phân loại: ${item.size ?? ''}${item.size != null ? ', ' : ''}${item.color ?? ''}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currencyFormat.format(item.price),
                                    style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  // Bộ đếm số lượng
                                  _buildQuantitySelector(context, cart, item),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomSheet: _buildBottomBar(context, currencyFormat),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, CartController cart, dynamic item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityBtn(Icons.remove, () {
            if (item.quantity > 1) {
              cart.updateQuantity(item.uniqueKey, item.quantity - 1);
            } else {
              _confirmDelete(context, cart, item.uniqueKey);
            }
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.grey[300]!))),
            child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          _quantityBtn(Icons.add, () => cart.updateQuantity(item.uniqueKey, item.quantity + 1)),
        ],
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, NumberFormat format) {
    final cart = context.watch<CartController>();
    if (cart.items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Checkbox(
              value: cart.selectAll,
              activeColor: Colors.deepOrange,
              onChanged: (val) => cart.toggleSelectAll(val),
            ),
            const Text("Tất cả", style: TextStyle(fontSize: 14)),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Tổng cộng", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  format.format(cart.totalPrice),
                  style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: cart.totalCheckedItems > 0
                    ? () {
                        final auth = context.read<AuthController>();
                        if (!auth.isLoggedIn) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Mua hàng (${cart.totalCheckedItems})"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Giỏ hàng trống rỗng", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CartController cart, String key) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              cart.removeFromCart(key);
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
