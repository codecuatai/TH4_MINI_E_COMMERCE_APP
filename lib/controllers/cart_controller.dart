import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import 'dart:convert';

class CartController extends ChangeNotifier {
  List<CartItemModel> _items = [];
  Map<String, bool> selectedItems = {};
  bool selectAll = false;

  List<CartItemModel> get items => _items;

  CartController() {
    loadCart();
  }

  // Getter cho số lượng item đang được chọn
  int get totalCheckedItems => _items.where((e) => selectedItems[e.uniqueKey] == true).length;

  // Add item to cart
  void addToCart(CartItemModel item) {
    final index = _items.indexWhere(
      (e) =>
          e.productId == item.productId &&
          e.size == item.size &&
          e.color == item.color,
    );
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
      selectedItems[item.uniqueKey] = true;
    }
    _updateSelectAll();
    saveCart();
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(String uniqueKey) {
    _items.removeWhere((e) => e.uniqueKey == uniqueKey);
    selectedItems.remove(uniqueKey);
    _updateSelectAll();
    saveCart();
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String uniqueKey, int quantity) {
    final index = _items.indexWhere((e) => e.uniqueKey == uniqueKey);
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(uniqueKey);
      } else {
        _items[index].quantity = quantity;
        saveCart();
        notifyListeners();
      }
    }
  }

  // Alias cho selectItem để khớp với CartScreen mới
  void toggleItemSelection(String uniqueKey, bool? selected) {
    selectedItems[uniqueKey] = selected ?? false;
    _updateSelectAll();
    notifyListeners();
  }

  // Alias cho selectAllItems để khớp với CartScreen mới
  void toggleSelectAll(bool? value) {
    selectAll = value ?? false;
    for (var item in _items) {
      selectedItems[item.uniqueKey] = selectAll;
    }
    notifyListeners();
  }

  // Update selectAll state
  void _updateSelectAll() {
    selectAll =
        _items.isNotEmpty &&
        _items.every((e) => selectedItems[e.uniqueKey] == true);
  }

  // Get selected items
  List<CartItemModel> get selectedCartItems =>
      _items.where((e) => selectedItems[e.uniqueKey] == true).toList();

  // Get total price of selected items
  double get totalPrice =>
      selectedCartItems.fold(0, (sum, e) => sum + e.price * e.quantity);

  // Save cart to local storage
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((e) => e.toJson()).toList());
    final selectedJson = jsonEncode(selectedItems);
    await prefs.setString('cart_items', cartJson);
    await prefs.setString('cart_selected', selectedJson);
  }

  // Load cart from local storage
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart_items');
    final selectedJson = prefs.getString('cart_selected');
    if (cartJson != null) {
      final List list = jsonDecode(cartJson);
      _items = list.map((e) => CartItemModel.fromJson(e)).toList();
    }
    if (selectedJson != null) {
      selectedItems = Map<String, bool>.from(jsonDecode(selectedJson));
    }
    _updateSelectAll();
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    selectedItems.clear();
    selectAll = false;
    saveCart();
    notifyListeners();
  }

  // Remove selected items after checkout
  void removeSelectedItems() {
    _items.removeWhere((e) => selectedItems[e.uniqueKey] == true);
    selectedItems.removeWhere((key, value) => value == true);
    _updateSelectAll();
    saveCart();
    notifyListeners();
  }
}
