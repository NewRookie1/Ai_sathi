import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_service.dart';

/// Buyer marketplace: browse every seller's products, buy, track orders.
/// Offline demo data keeps Buyer Demo Mode usable without the backend.
class MarketplaceService extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  List<Order> _myOrders = [];
  bool _isLoading = false;
  bool _isOrdering = false;
  String? _error;

  List<Product> get products => _products;
  List<Order> get myOrders => _myOrders;
  bool get isLoading => _isLoading;
  bool get isOrdering => _isOrdering;
  String? get error => _error;

  bool get _demo => !AppConfig.isAuthenticated ||
      AppConfig.authToken == 'demo-token';

  Future<void> browse({String? search, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (_demo) {
        _products = _demoProducts(search: search, category: category);
      } else {
        final res = await _api.get<List<dynamic>>(
          '/marketplace/products',
          queryParameters: {
            if (search != null && search.isNotEmpty) 'search': search,
            if (category != null && category.isNotEmpty) 'category': category,
          },
          fromJson: (b) => (b as List).toList(),
        );
        if (res.success && res.data != null) {
          _products = res.data!
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          _error = res.message ?? 'Could not load products';
          _products = _demoProducts(search: search, category: category);
        }
      }
    } catch (_) {
      _error = 'Could not load products';
      _products = _demoProducts(search: search, category: category);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> placeOrder({
    required List<Map<String, dynamic>> items, // {productId, quantity}
    String? shippingAddress,
    String? buyerPhone,
  }) async {
    _isOrdering = true;
    _error = null;
    notifyListeners();
    try {
      if (_demo) {
        await Future.delayed(const Duration(milliseconds: 600));
        _isOrdering = false;
        notifyListeners();
        await loadMyOrders();
        return true;
      }
      final res = await _api.post<List<dynamic>>(
        '/marketplace/orders',
        data: {
          'items': [
            for (final i in items)
              {'product_id': i['productId'], 'quantity': i['quantity'] ?? 1}
          ],
          if (shippingAddress != null) 'shipping_address': shippingAddress,
          if (buyerPhone != null) 'buyer_phone': buyerPhone,
        },
        fromJson: (b) => (b as List).toList(),
      );
      _isOrdering = false;
      if (res.success) {
        notifyListeners();
        await loadMyOrders();
        await browse();
        return true;
      }
      _error = res.message ?? 'Order failed';
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Order failed. Please try again.';
      _isOrdering = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMyOrders() async {
    try {
      if (_demo) {
        _myOrders = [];
        notifyListeners();
        return;
      }
      final res = await _api.get<List<dynamic>>(
        '/marketplace/my-orders',
        fromJson: (b) => (b as List).toList(),
      );
      if (res.success && res.data != null) {
        _myOrders = res.data!
            .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  List<Product> _demoProducts({String? search, String? category}) {
    final now = DateTime.now();
    final stats = ProductStats();
    final all = [
      Product(
        id: 'd1', userId: 's1', name: 'Handmade Clay Diyas (12 pc)',
        description: 'Festive terracotta diyas, hand-painted.',
        category: 'Pottery', craftType: 'Pottery', material: 'Clay',
        price: 299, quantity: 20, stats: stats, createdAt: now, updatedAt: now,
      ),
      Product(
        id: 'd2', userId: 's2', name: 'Block-Print Cotton Saree',
        description: 'Jaipur block print, pure cotton.',
        category: 'Textiles', craftType: 'Weaving', material: 'Cotton',
        price: 2500, quantity: 8, stats: stats, createdAt: now, updatedAt: now,
      ),
      Product(
        id: 'd3', userId: 's3', name: 'Bamboo Storage Basket',
        description: 'Handwoven multipurpose basket.',
        category: 'Home Decor', craftType: 'Weaving', material: 'Bamboo',
        price: 850, quantity: 15, stats: stats, createdAt: now, updatedAt: now,
      ),
    ];
    return all.where((p) {
      if (search != null && search.isNotEmpty &&
          !p.name.toLowerCase().contains(search.toLowerCase())) {
        return false;
      }
      if (category != null && category.isNotEmpty && p.category != category) {
        return false;
      }
      return true;
    }).toList();
  }
}
