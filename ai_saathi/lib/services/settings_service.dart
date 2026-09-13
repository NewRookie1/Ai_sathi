import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings persisted locally: notifications, shop profile and
/// payout details. All offline-first; nothing needs the backend.
class SettingsService extends ChangeNotifier {
  static const _kNotifOrders = 'notif_orders';
  static const _kNotifPrice = 'notif_price';
  static const _kNotifMarket = 'notif_market';
  static const _kNotifVoice = 'notif_voice';
  static const _kShopName = 'shop_name';
  static const _kShopLocation = 'shop_location';
  static const _kShopDesc = 'shop_desc';
  static const _kUpiId = 'upi_id';
  static const _kPayoutMethod = 'payout_method';
  static const _kAccountName = 'account_name';

  bool notifOrders = true;
  bool notifPrice = true;
  bool notifMarket = false;
  bool notifVoice = true;

  String shopName = '';
  String shopLocation = '';
  String shopDesc = '';

  String upiId = '';
  String payoutMethod = 'upi';
  String accountName = '';

  SettingsService() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      notifOrders = prefs.getBool(_kNotifOrders) ?? true;
      notifPrice = prefs.getBool(_kNotifPrice) ?? true;
      notifMarket = prefs.getBool(_kNotifMarket) ?? false;
      notifVoice = prefs.getBool(_kNotifVoice) ?? true;
      shopName = prefs.getString(_kShopName) ?? '';
      shopLocation = prefs.getString(_kShopLocation) ?? '';
      shopDesc = prefs.getString(_kShopDesc) ?? '';
      upiId = prefs.getString(_kUpiId) ?? '';
      payoutMethod = prefs.getString(_kPayoutMethod) ?? 'upi';
      accountName = prefs.getString(_kAccountName) ?? '';
      notifyListeners();
    } catch (_) {
      // Defaults stand when prefs are unavailable.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifOrders, notifOrders);
      await prefs.setBool(_kNotifPrice, notifPrice);
      await prefs.setBool(_kNotifMarket, notifMarket);
      await prefs.setBool(_kNotifVoice, notifVoice);
      await prefs.setString(_kShopName, shopName);
      await prefs.setString(_kShopLocation, shopLocation);
      await prefs.setString(_kShopDesc, shopDesc);
      await prefs.setString(_kUpiId, upiId);
      await prefs.setString(_kPayoutMethod, payoutMethod);
      await prefs.setString(_kAccountName, accountName);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  Future<void> setNotification(String key, bool value) async {
    switch (key) {
      case 'orders':
        notifOrders = value;
      case 'price':
        notifPrice = value;
      case 'market':
        notifMarket = value;
      case 'voice':
        notifVoice = value;
    }
    notifyListeners();
    await _save();
  }

  Future<void> saveShop({
    required String name,
    required String location,
    required String desc,
  }) async {
    shopName = name;
    shopLocation = location;
    shopDesc = desc;
    notifyListeners();
    await _save();
  }

  Future<void> savePayout({
    required String upi,
    required String method,
    required String account,
  }) async {
    upiId = upi;
    payoutMethod = method;
    accountName = account;
    notifyListeners();
    await _save();
  }

  static bool isValidUpi(String value) {
    return RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$').hasMatch(value.trim());
  }
}
