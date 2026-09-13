import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.get<List<dynamic>>(
        ApiConstants.products,
        fromJson: (data) => (data as List).map((e) => Product.fromJson(e)).toList(),
      );

      if (result.success && result.data != null) {
        _products = result.data!.cast<Product>();
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = 'Failed to load products';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Product?> getProduct(String id) async {
    try {
      final result = await _api.get<Product>(
        ApiConstants.productById(id),
        fromJson: (data) => Product.fromJson(data),
      );

      if (result.success && result.data != null) {
        return result.data;
      }
    } catch (e) {
      _error = 'Failed to load product';
    }
    return null;
  }

  Future<Product?> createProduct(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.post<Product>(
        ApiConstants.products,
        data: data,
        fromJson: (data) => Product.fromJson(data),
      );

      if (result.success && result.data != null) {
        _products.insert(0, result.data!);
        _isLoading = false;
        notifyListeners();
        return result.data;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to create product';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<Product?> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final result = await _api.put<Product>(
        ApiConstants.productById(id),
        data: data,
        fromJson: (data) => Product.fromJson(data),
      );

      if (result.success && result.data != null) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = result.data!;
        }
        notifyListeners();
        return result.data;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to update product';
    }
    return null;
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final result = await _api.delete(ApiConstants.productById(id));

      if (result.success) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to delete product';
    }
    return false;
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final result = await _api.get<List<dynamic>>(
        ApiConstants.products,
        queryParameters: {'search': query},
        fromJson: (data) => (data as List).map((e) => Product.fromJson(e)).toList(),
      );

      if (result.success && result.data != null) {
        return result.data!.cast<Product>();
      }
    } catch (e) {
      _error = 'Search failed';
    }
    return [];
  }
}
