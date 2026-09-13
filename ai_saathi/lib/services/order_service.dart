import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Order> get newOrders => _orders.where((o) => o.status == 'new').toList();
  List<Order> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.get<List<dynamic>>(
        ApiConstants.orders,
        fromJson: (data) => (data as List).map((e) => Order.fromJson(e)).toList(),
      );

      if (result.success && result.data != null) {
        _orders = result.data!.cast<Order>();
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = 'Failed to load orders';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> getOrder(String id) async {
    try {
      final result = await _api.get<Order>(
        ApiConstants.orderById(id),
        fromJson: (data) => Order.fromJson(data),
      );

      if (result.success && result.data != null) {
        return result.data;
      }
    } catch (e) {
      _error = 'Failed to load order';
    }
    return null;
  }

  Future<Order?> updateOrderStatus(String id, String status) async {
    try {
      final result = await _api.put<Order>(
        ApiConstants.orderById(id),
        data: {'status': status},
        fromJson: (data) => Order.fromJson(data),
      );

      if (result.success && result.data != null) {
        final index = _orders.indexWhere((o) => o.id == id);
        if (index != -1) {
          _orders[index] = result.data!;
        }
        notifyListeners();
        return result.data;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to update order';
    }
    return null;
  }

  Future<bool> acceptOrder(String id) async {
    final order = await updateOrderStatus(id, 'accepted');
    return order != null;
  }

  Future<bool> rejectOrder(String id) async {
    final order = await updateOrderStatus(id, 'rejected');
    return order != null;
  }

  Future<bool> cancelOrder(String id) async {
    final order = await updateOrderStatus(id, 'cancelled');
    return order != null;
  }
}
