import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save order to Firestore and return created document id (for debugging)
  Future<String> saveOrder(
    String userId,
    Map<String, dynamic> orderData,
  ) async {
    final ref = await _db
        .collection('orders')
        .doc(userId)
        .collection('user_orders')
        .add(orderData);
    return ref.id;
  }

  // Fetch orders by status
  Stream<QuerySnapshot> getOrdersByStatus(String userId, String status) {
    return _db
        .collection('orders')
        .doc(userId)
        .collection('user_orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Optionally: Sync cart with Firestore after login (BONUS)
  Future<void> syncCart(
    String userId,
    List<Map<String, dynamic>> cartItems,
  ) async {
    await _db.collection('carts').doc(userId).set({'items': cartItems});
  }

  // Optionally: Load cart from Firestore
  Future<List<Map<String, dynamic>>> loadCart(String userId) async {
    final doc = await _db.collection('carts').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final items = doc.data()!['items'] as List<dynamic>;
      return items.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
