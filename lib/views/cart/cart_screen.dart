import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';
import '../home/home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryOrange = Colors.deepOrange;

  String? _appliedVoucher;
  double _discountPercent = 0.0;

  // Giả lập danh sách voucher từ server
  final List<Map<String, dynamic>> _availableVouchers = [
    {
      'code': 'FREESHIP',
      'percent': 0.05,
      'title': 'Miễn phí vận chuyển',
      'desc': 'Giảm 5% phí vận chuyển, đơn tối thiểu đ0',
      'icon': Icons.local_shipping_outlined,
      'color': Colors.teal,
    },
    {
      'code': 'SAVE10',
      'percent': 0.10,
      'title': 'Giảm 10%',
      'desc': 'Áp dụng cho mọi đơn hàng',
      'icon': Icons.local_activity_outlined,
      'color': Colors.deepOrange,
    },
    {
      'code': 'VIP20',
      'percent': 0.20,
      'title': 'Giảm 20%',
      'desc': 'Dành riêng cho thành viên VIP',
      'icon': Icons.star_border,
      'color': Colors.purple,
    },
  ];

  void _applyVoucherCode(String code) {
    final normalized = code.trim().toUpperCase();

    // Tìm voucher trong danh sách
    final match = _availableVouchers
        .where((v) => v['code'] == normalized)
        .toList();

    if (match.isNotEmpty) {
      setState(() {
        _appliedVoucher = normalized;
        _discountPercent = match.first['percent'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Áp dụng voucher $normalized thành công!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã voucher không hợp lệ hoặc đã hết hạn.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _discountPercent = 0.0;
    });
  }

  // --- UI CHỌN VOUCHER MỚI (BOTTOM SHEET) ---
  void _showVoucherBottomSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để bottom sheet chiếm nhiều diện tích hơn
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBgColor = isDark ? Colors.grey[900] : Colors.grey[100];
        final cardColor = isDark ? Colors.grey[800] : Colors.white;

        return StatefulBuilder(
          // Dùng StatefulBuilder để update UI trong BottomSheet nếu cần
          builder: (context, setModalState) {
            return Container(
              height:
                  MediaQuery.of(ctx).size.height * 0.75, // Chiếm 75% màn hình
              decoration: BoxDecoration(
                color: sheetBgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24), // Spacer
                        Text(
                          'Chọn Shopee Voucher',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Nhập mã thủ công
                  Container(
                    color: cardColor,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: controller,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Nhập mã voucher',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              Navigator.pop(ctx);
                              _applyVoucherCode(controller.text);
                            }
                          },
                          child: const Text(
                            'ÁP DỤNG',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Danh sách Voucher có sẵn
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _availableVouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final v = _availableVouchers[index];
                        final isSelected = _appliedVoucher == v['code'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            if (isSelected) {
                              _removeVoucher(); // Click lại để hủy
                            } else {
                              _applyVoucherCode(v['code']);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? primaryOrange
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Cột Icon (giống mác xé)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: v['color'],
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(8),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        v['icon'],
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        v['code'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Cột Nội dung
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v['title'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          v['desc'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Radio button (dạng Check)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: isSelected
                                        ? primaryOrange
                                        : Colors.grey[400],
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    final rawTotal = cartController.totalPrice;
    final discountAmount = (rawTotal * _discountPercent).roundToDouble();
    final double discountedTotal = (rawTotal - discountAmount)
        .clamp(0.0, double.infinity)
        .toDouble();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0.5,
        title: Text(
          'Giỏ hàng ${cartController.items.isNotEmpty ? '(${cartController.items.length})' : ''}',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Sửa',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: Badge(
              backgroundColor: primaryOrange,
              label: const Text('9+'),
              child: const Icon(Icons.chat_outlined),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: cartController.items.isEmpty
            ? _buildEmptyState(context, isDark)
            : SingleChildScrollView(
                key: const ValueKey('cart_list'),
                child: Column(
                  children: [
                    // Giao diện 1 Shop chứa tất cả sản phẩm
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            height: 1,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                          // Danh sách sản phẩm thực tế từ Logic của bạn
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartController.items.length,
                            itemBuilder: (context, index) {
                              final item = cartController.items[index];
                              final selected =
                                  cartController.selectedItems[item
                                      .uniqueKey] ??
                                  false;

                              return Dismissible(
                                key: Key(item.uniqueKey),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red.shade600,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                onDismissed: (_) => cartController
                                    .removeFromCart(item.uniqueKey),
                                child: _buildProductItem(
                                  item: item,
                                  selected: selected,
                                  isDark: isDark,
                                  currencyFormat: currencyFormat,
                                  cartController: cartController,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Khối Vouchers & Xu
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      color: cardColor,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.local_activity,
                              color: Colors.orange,
                            ),
                            title: Text(
                              'Voucher / Mã giảm giá',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: _appliedVoucher != null
                                ? Text(
                                    'Đã áp dụng: $_appliedVoucher - Giảm ${(100 * _discountPercent).toInt()}%',
                                    style: const TextStyle(color: Colors.green),
                                  )
                                : null,
                            trailing: _appliedVoucher == null
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Chọn hoặc nhập mã',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: _removeVoucher,
                                        child: const Text('Xóa mã'),
                                      ),
                                    ],
                                  ),
                            onTap:
                                _showVoucherBottomSheet, // Gọi BottomSheet thay vì Dialog
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: cartController.items.isEmpty
          ? null
          : _buildStickyBottomBar(
              context,
              cartController,
              currencyFormat,
              isDark,
              cardColor,
              discountedTotal: discountedTotal,
              rawTotal: rawTotal,
              discountAmount: discountAmount,
            ),
    );
  }

  Widget _buildProductItem({
    required CartItemModel item,
    required bool selected,
    required bool isDark,
    required NumberFormat currencyFormat,
    required CartController cartController,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: selected,
            activeColor: primaryOrange,
            onChanged: (v) =>
                cartController.selectItem(item.uniqueKey, v ?? false),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Icon(
                  Icons.image_outlined,
                  color: isDark ? Colors.grey[600] : Colors.grey,
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (item.size != null || item.color != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Phân loại: ${item.color ?? ''}${item.color != null && item.size != null ? ', ' : ''}${item.size ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.black54,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: isDark ? Colors.grey[300] : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(item.price),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                    Row(
                      children: [
                        _buildQtyButton(
                          icon: Icons.remove,
                          isDark: isDark,
                          onTap: () {
                            if (item.quantity > 1) {
                              cartController.updateQuantity(
                                item.uniqueKey,
                                item.quantity - 1,
                              );
                            } else {
                              cartController.removeFromCart(item.uniqueKey);
                            }
                          },
                        ),
                        Container(
                          width: 32,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        _buildQtyButton(
                          icon: Icons.add,
                          isDark: isDark,
                          onTap: () => cartController.updateQuantity(
                            item.uniqueKey,
                            item.quantity + 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          color: isDark ? Colors.grey[850] : Colors.white,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(
    BuildContext context,
    CartController cartController,
    NumberFormat currencyFormat,
    bool isDark,
    Color cardColor, {
    required double discountedTotal,
    required double rawTotal,
    required double discountAmount,
  }) {
    final hasSelectedItem = cartController.selectedCartItems.isNotEmpty;

    return Container(
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
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: cartController.selectAll,
                    activeColor: primaryOrange,
                    onChanged: (v) => cartController.selectAllItems(v ?? false),
                  ),
                  Text(
                    'Tất cả',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (discountAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tổng: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Text(
                              currencyFormat.format(rawTotal),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currencyFormat.format(discountedTotal),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Bạn tiết kiệm: ${currencyFormat.format(discountAmount)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Text(
                          'Tổng thanh toán: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Text(
                          currencyFormat.format(rawTotal),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: hasSelectedItem
                    ? () {
                        final authController = Provider.of<AuthController>(
                          context,
                          listen: false,
                        );
                        if (!authController.isLoggedIn) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } else {
                          // Truyền thêm dữ liệu voucher sang CheckoutScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                selectedItems: cartController.selectedCartItems,
                                voucherCode: _appliedVoucher,
                                discountPercent: _discountPercent,
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: Container(
                  width: 110,
                  height: double.infinity,
                  color: hasSelectedItem
                      ? primaryOrange
                      : (isDark ? Colors.grey[800] : Colors.grey[400]),
                  alignment: Alignment.center,
                  child: Text(
                    'Mua hàng (${cartController.selectedCartItems.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: primaryOrange.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sản phẩm để bắt đầu mua sắm.',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'TIẾP TỤC MUA SẮM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
