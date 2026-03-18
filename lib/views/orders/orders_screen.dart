import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  final Color primaryOrange = Colors.deepOrange;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userId =
        authController.user?.uid ?? 'demoUser'; // Replace with real user id
    final tabs = ['Chờ xác nhận', 'Đang giao', 'Đã giao', 'Đã hủy'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0.5,
          title: Text(
            'Đơn hàng của tôi',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black87,
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: primaryOrange,
            labelColor: primaryOrange,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((status) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getOrdersByStatus(userId, status),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                final orders = snapshot.data!.docs
                    .map(
                      (doc) => OrderModel.fromJson(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                final currencyFormat = NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                );

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(
                      context,
                      order,
                      currencyFormat,
                      isDark,
                      cardColor,
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    NumberFormat currencyFormat,
    bool isDark,
    Color cardColor,
  ) {
    String itemName = 'Sản phẩm';
    String itemImage = '';
    int itemQty = 1;
    double itemPrice = 0.0;

    if (order.items.isNotEmpty) {
      final firstItem = order.items.first;
      if (firstItem is Map) {
        itemName = firstItem['name'] ?? 'Sản phẩm';
        itemImage = firstItem['image'] ?? '';
        itemQty = firstItem['quantity'] ?? 1;
        itemPrice = (firstItem['price'] ?? 0).toDouble();
      } else {
        try {
          itemName = (firstItem as dynamic).name;
          itemImage = (firstItem as dynamic).image;
          itemQty = (firstItem as dynamic).quantity;
          itemPrice = (firstItem as dynamic).price.toDouble();
        } catch (_) {}
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tên Shop & Trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0011B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'Mall',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cửa hàng chính hãng',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),

          // Body: Preview sản phẩm (1 sản phẩm)
          InkWell(
            onTap: () => _showOrderDetails(context, order, isDark),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? Colors.grey[850] : const Color(0xFFFAFAFA),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      itemImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'x$itemQty',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              currencyFormat.format(itemPrice),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Xem thêm sản phẩm (Nếu có)
          if (order.items.length > 1)
            InkWell(
              onTap: () => _showOrderDetails(context, order, isDark),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Text(
                  'Xem thêm ${order.items.length - 1} sản phẩm',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),

          // Footer: Tổng tiền & Nút
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} sản phẩm',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Thành tiền: ',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          currencyFormat.format(order.totalPrice),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () =>
                          _showOrderDetails(context, order, isDark),
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        final cartController = Provider.of<CartController>(
                          context,
                          listen: false,
                        );
                        int added = 0;
                        for (final it in order.items) {
                          try {
                            CartItemModel item;
                            if (it is Map) {
                              item = CartItemModel.fromJson(
                                Map<String, dynamic>.from(it),
                              );
                            } else {
                              final m = Map<String, dynamic>.from(
                                it as dynamic,
                              );
                              item = CartItemModel.fromJson(m);
                            }
                            cartController.addToCart(item);
                            added++;
                          } catch (_) {}
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã thêm $added sản phẩm vào giỏ hàng',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        'Mua lại',
                        style: TextStyle(color: Colors.white, fontSize: 13),
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
  }

  // --- UI CHI TIẾT ĐƠN HÀNG ĐƯỢC LÀM MỚI ---
  void _showOrderDetails(BuildContext context, OrderModel order, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Background trong suốt để bo góc chuẩn
      builder: (ctx) {
        final currencyFormat = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: 'đ',
        );
        final sheetColor = isDark ? Colors.grey[900] : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Container(
          height:
              MediaQuery.of(context).size.height * 0.75, // Chiếm 75% màn hình
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header Bottom Sheet
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Để cân bằng với icon close
                    Text(
                      'Chi tiết đơn hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Nội dung chi tiết cuộn được
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Khối Trạng thái & Mã đơn
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[850]
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mã đơn hàng:',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  order.id,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Trạng thái:',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  order.status.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Ngày đặt:',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(order.createdAt),
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Khối Sản phẩm
                      Text(
                        'Sản phẩm đã đặt',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) => Divider(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        itemBuilder: (context, i) {
                          final it = order.items[i];
                          String name = 'Sản phẩm';
                          String image = '';
                          int qty = 1;
                          double price = 0.0;

                          if (it is Map) {
                            name = it['name'] ?? name;
                            image = it['image'] ?? '';
                            qty = it['quantity'] ?? 1;
                            price = (it['price'] ?? 0).toDouble();
                          } else {
                            try {
                              name = (it as dynamic).name;
                              image = (it as dynamic).image;
                              qty = (it as dynamic).quantity;
                              price = (it as dynamic).price.toDouble();
                            } catch (_) {}
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[400],
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
                                      name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'x$qty',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(price),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer: Tổng tiền
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currencyFormat.format(order.totalPrice),
                        style: TextStyle(
                          color: primaryOrange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
