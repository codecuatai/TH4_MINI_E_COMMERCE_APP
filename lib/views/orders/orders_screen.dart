import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userId =
        authController.user?.uid ?? 'demoUser'; // Replace with real user id
    final tabs = ['Chờ xác nhận', 'Đang giao', 'Đã giao', 'Đã hủy'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng của tôi'),
          bottom: TabBar(tabs: tabs.map((t) => Tab(text: t)).toList()),
        ),
        body: TabBarView(
          children: tabs.map((status) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getOrdersByStatus(userId, status),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng'));
                }
                final orders = snapshot.data!.docs
                    .map(
                      (doc) => OrderModel.fromJson(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Đơn hàng #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng: ${order.totalPrice}'),
                            Text('Địa chỉ: ${order.address}'),
                            Text('Ngày: ${order.createdAt}'),
                          ],
                        ),
                        trailing: Text(order.status),
                        onTap: () {
                          // TODO: Show order details
                        },
                      ),
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
}
