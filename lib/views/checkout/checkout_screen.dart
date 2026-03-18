import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../services/firestore_service.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../home/home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> selectedItems;
  final String? voucherCode;
  final double discountPercent;

  const CheckoutScreen({
    Key? key,
    required this.selectedItems,
    this.voucherCode,
    this.discountPercent = 0.0,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _isLoading = false;
  final Color primaryOrange = Colors.deepOrange;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final selectedItems = widget.selectedItems;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    final rawTotal = selectedItems.fold<double>(
      0,
      (s, e) => s + e.price * e.quantity,
    );
    final discountAmount = (rawTotal * widget.discountPercent).roundToDouble();
    final finalTotal = (rawTotal - discountAmount)
        .clamp(0.0, double.infinity)
        .toDouble();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0.5,
        title: Text(
          'Thanh toán',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ĐỊA CHỈ NHẬN HÀNG ---
            Container(
              margin: const EdgeInsets.only(top: 8),
              color: cardColor,
              child: Column(
                children: [
                  // Dải viền trang trí sọc phong cách bì thư (Tùy chọn)
                  Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.blueAccent],
                        stops: [0.5, 0.5],
                        tileMode: TileMode.repeated,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: primaryOrange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Địa chỉ nhận hàng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  hintText: 'Nhập địa chỉ giao hàng cụ thể...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: primaryOrange,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                maxLines: 2,
                                minLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. DANH SÁCH SẢN PHẨM ---
            Container(
              margin: const EdgeInsets.only(top: 10),
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Shop
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront,
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sản phẩm',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  // List Products
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = selectedItems[index];
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[850]
                              : const Color(0xFFFAFAFA),
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.grey[800]! : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.size != null || item.color != null)
                                    Text(
                                      'Phân loại: ${item.color ?? ''}${item.color != null && item.size != null ? ', ' : ''}${item.size ?? ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        currencyFormat.format(item.price),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'x${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Tạm tính
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng số tiền (${selectedItems.length} sản phẩm):',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Text(
                          currencyFormat.format(rawTotal),
                          style: TextStyle(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. PHƯƠNG THỨC THANH TOÁN ---
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 20, color: primaryOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Phương thức thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  RadioListTile<String>(
                    value: 'COD',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                    activeColor: primaryOrange,
                    title: const Text(
                      'Thanh toán khi nhận hàng (COD)',
                      style: TextStyle(fontSize: 14),
                    ),
                    secondary: const Icon(Icons.local_atm, color: Colors.green),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Divider(
                    height: 1,
                    indent: 48,
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  RadioListTile<String>(
                    value: 'Momo',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                    activeColor: primaryOrange,
                    title: const Text(
                      'Ví điện tử Momo',
                      style: TextStyle(fontSize: 14),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),

            // Padding an toàn dưới cùng
            const SizedBox(height: 100),
          ],
        ),
      ),

      // --- 4. THANH BOTTOM BAR ĐẶT HÀNG ---
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vùng hiển thị Voucher (Nếu có)
              if (widget.discountPercent > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: isDark
                      ? Colors.orange.withOpacity(0.1)
                      : const Color(0xFFFFF7E6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_activity,
                        size: 16,
                        color: primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đã áp dụng mã ${widget.voucherCode}',
                        style: TextStyle(fontSize: 12, color: primaryOrange),
                      ),
                    ],
                  ),
                ),
              // Vùng hiển thị Tổng tiền & Nút
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Tổng thanh toán',
                              style: TextStyle(fontSize: 13),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (widget.discountPercent > 0) ...[
                                  Text(
                                    currencyFormat.format(rawTotal),
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  currencyFormat.format(finalTotal),
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.discountPercent > 0)
                              Text(
                                'Tiết kiệm ${currencyFormat.format(discountAmount)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _isLoading
                          ? null
                          : () => _handleCheckout(
                              context,
                              cartController,
                              finalTotal,
                              discountAmount,
                            ),
                      child: Container(
                        width: 130,
                        height: double.infinity,
                        color: _isLoading ? Colors.grey : primaryOrange,
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Đặt hàng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC ĐẶT HÀNG ĐƯỢC GIỮ NGUYÊN (Tách ra hàm riêng cho code sạch) ---
  Future<void> _handleCheckout(
    BuildContext context,
    CartController cartController,
    double finalTotal,
    double discountAmount,
  ) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng')),
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
          const SnackBar(content: Text('Bạn cần đăng nhập để đặt hàng!')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final orderData = {
        'items': widget.selectedItems.map((e) => e.toJson()).toList(),
        'address': _addressController.text,
        'paymentMethod': _paymentMethod,
        'status': 'Chờ xác nhận',
        'createdAt': DateTime.now(),
        'totalPrice': finalTotal,
        'voucherCode': widget.voucherCode,
        'discountPercent': widget.discountPercent,
        'discountAmount': discountAmount,
      };

      final savedId = await FirestoreService().saveOrder(userId, orderData);

      cartController.removeSelectedItems();

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Đặt hàng thành công!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cảm ơn bạn đã mua sắm cùng chúng tôi.'),
              const SizedBox(height: 8),
              Text(
                'Mã đơn hàng: $savedId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'VỀ TRANG CHỦ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt hàng thất bại, vui lòng thử lại sau!'),
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
