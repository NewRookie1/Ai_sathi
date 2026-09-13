import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => AppConfig.isAuthenticated;
  String? get error => _error;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      if (result.success && result.data != null) {
        final token = result.data!['token'];
        final userData = result.data!['user'];
        await AppConfig.setAuth(userData['id'], token);
        _user = User.fromJson(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = result.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? shopName,
    String? language,
    String role = 'artisan',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          if (shopName != null) 'shop_name': shopName,
          if (language != null) 'preferred_language': language,
          'role': role,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      if (result.success && result.data != null) {
        final token = result.data!['token'];
        final userData = result.data!['user'];
        await AppConfig.setAuth(userData['id'], token);
        _user = User.fromJson(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = result.message ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Offline demo login: creates a local demo session without any
  /// network call, so testers are never blocked by backend availability.
  Future<bool> enterDemoMode() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AppConfig.setAuth('demo-user-id', 'demo-token');
      final now = DateTime.now();
      _user = User(
        id: 'demo-user-id',
        name: 'Demo Artisan',
        email: 'demo@artisanai.com',
        phone: '',
        preferredLanguage: AppConfig.userLanguage,
        shopName: 'Demo Craft Shop',
        location: 'India',
        createdAt: now,
        updatedAt: now,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Could not start demo mode.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Offline buyer demo: browse + cart flow without the backend.
  Future<bool> enterBuyerDemoMode() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AppConfig.setAuth('demo-buyer-id', 'demo-token');
      final now = DateTime.now();
      _user = User(
        id: 'demo-buyer-id',
        name: 'Demo Buyer',
        email: 'buyer@demo.com',
        phone: '',
        preferredLanguage: AppConfig.userLanguage,
        role: 'buyer',
        location: 'India',
        createdAt: now,
        updatedAt: now,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Could not start buyer demo mode.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AppConfig.clearAuth();
    _user = null;
    notifyListeners();
  }

  /// Seller ↔ buyer switching without logging out.
  /// Offline-first: flips locally instantly, syncs to backend best-effort.
  Future<bool> switchRole(String role) async {
    if (role != 'artisan' && role != 'buyer') return false;
    final previous = _user?.role;
    if (_user != null) {
      _user = _user!.copyWith(role: role);
      notifyListeners();
    }
    if (!AppConfig.isAuthenticated || AppConfig.authToken == 'demo-token') {
      return true; // demo mode: local-only roles
    }
    try {
      final result = await _api.put<Map<String, dynamic>>(
        '/auth/role',
        data: {'role': role},
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      if (result.success && result.data != null) {
        _user = User.fromJson(result.data!);
        notifyListeners();
        return true;
      }
      // Backend rejected: roll back to previous role.
      if (_user != null && previous != null) {
        _user = _user!.copyWith(role: previous);
        notifyListeners();
      }
      _error = result.message ?? 'Could not switch role';
      return false;
    } catch (_) {
      // Offline: keep the local switch, sync on next loadUser().
      return true;
    }
  }

  Future<void> loadUser() async {
    if (!AppConfig.isAuthenticated) return;

    try {
      final result = await _api.get<Map<String, dynamic>>(
        '/auth/me',
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      if (result.success && result.data != null) {
        _user = User.fromJson(result.data!);
        notifyListeners();
      }
    } catch (e) {
      await logout();
    }
  }
}
