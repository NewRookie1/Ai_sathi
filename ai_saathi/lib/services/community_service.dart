import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';
import '../models/community.dart';
import 'api_service.dart';

/// Offline-first community features with backend sync when logged in:
/// collective orders, second-hand shelf, artisan collaboration,
/// seller-support program, budget bazaar and per-order delivery prefs.
class CommunityService extends ChangeNotifier {
  static const _kJoinedCollectives = 'joined_collectives';
  static const _kInterestedCollabs = 'interested_collabs';
  static const _kSupportRegistered = 'support_registered';
  static const _kSupportScheme = 'support_scheme';
  static const _kAppliedSchemes = 'applied_schemes';
  static const _kDeliveryMethods = 'delivery_methods';
  static const _kOpenBox = 'open_box_orders';
  static const _kCustomCollabs = 'custom_collabs';

  List<CollectiveOrder> _collectives = [];
  List<SecondHandItem> _secondHand = [];
  List<CollabPost> _collabs = [];
  Set<String> _joinedCollectives = {};
  Set<String> _interestedCollabs = {};
  Set<String> _appliedSchemes = {};
  bool _supportRegistered = false;
  String _supportScheme = 'general';
  Map<String, String> _deliveryMethods = {};
  Set<String> _openBoxOrders = {};
  bool _isSyncing = false;
  String? _lastError;

  List<CollectiveOrder> get collectives => _collectives;
  List<SecondHandItem> get secondHand => _secondHand;
  List<CollabPost> get collabs => _collabs;
  bool get supportRegistered => _supportRegistered;
  String get supportScheme => _supportScheme;
  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;

  bool isJoined(String id) => _joinedCollectives.contains(id);
  bool isInterested(String id) => _interestedCollabs.contains(id);
  bool isSchemeApplied(String id) => _appliedSchemes.contains(id);
  String deliveryMethod(String orderId) =>
      _deliveryMethods[orderId] ?? 'standard';
  bool openBox(String orderId) => _openBoxOrders.contains(orderId);
  Map<String, String> get allDeliveries => Map.unmodifiable(_deliveryMethods);

  CommunityService() {
    _seed();
    _load();
  }

  void _seed() {
    // NOTE: must stay mutable — const lists throw on toggle/add.
    _collectives = [
      const CollectiveOrder(
        id: 'c1',
        title: 'Diwali Bulk Order',
        productName: 'Handmade Clay Diyas (set of 12)',
        price: 299,
        targetQty: 100,
        joinedQty: 64,
        endsIn: '2 days',
      ),
      const CollectiveOrder(
        id: 'c2',
        title: 'Export Collective',
        productName: 'Block-Print Cotton Fabric (per meter)',
        price: 450,
        targetQty: 200,
        joinedQty: 151,
        endsIn: '5 days',
      ),
      const CollectiveOrder(
        id: 'c3',
        title: 'Wedding Season Pool',
        productName: 'Brass Decorative Plates',
        price: 899,
        targetQty: 50,
        joinedQty: 12,
        endsIn: '9 days',
      ),
    ];
    _secondHand = [
      const SecondHandItem(
        id: 's1',
        title: 'Refurbished Wooden Chair',
        price: 1200,
        mrp: 2800,
        condition: 'Like New',
        seller: 'Ravi Kumar',
      ),
      const SecondHandItem(
        id: 's2',
        title: 'Pre-owned Brass Lamp',
        price: 650,
        mrp: 1500,
        condition: 'Good',
        seller: 'Meera Arts',
      ),
      const SecondHandItem(
        id: 's3',
        title: 'Second-hand Loom (working)',
        price: 8500,
        mrp: 15000,
        condition: 'Fair',
        seller: 'Loom House',
      ),
      const SecondHandItem(
        id: 's4',
        title: 'Gently Used Ceramic Set',
        price: 499,
        mrp: 1299,
        condition: 'Like New',
        seller: 'Clay Works',
      ),
    ];
    _collabs = [
      const CollabPost(
        id: 'k1',
        title: 'Need 500 jute bags in 10 days',
        type: 'Need help',
        description:
            'Big festival order, need 2 artisans for stitching and printing.',
        author: 'Sunita Devi',
        location: 'Jaipur',
        interestedCount: 4,
      ),
      const CollabPost(
        id: 'k2',
        title: 'Sharing teak wood stock',
        type: 'Share material',
        description: 'Extra seasoned teak available at cost price this month.',
        author: 'Karan Mistry',
        location: 'Saharanpur',
        interestedCount: 7,
      ),
      const CollabPost(
        id: 'k3',
        title: 'Joint blue-pottery dinner set',
        type: 'Joint product',
        description:
            'Potter + painter needed for a 24-piece export dinner set.',
        author: 'Blue Pottery Co.',
        location: 'Khurja',
        interestedCount: 2,
      ),
    ];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _joinedCollectives =
          (prefs.getStringList(_kJoinedCollectives) ?? []).toSet();
      _interestedCollabs =
          (prefs.getStringList(_kInterestedCollabs) ?? []).toSet();
      _appliedSchemes =
          (prefs.getStringList(_kAppliedSchemes) ?? []).toSet();
      _supportRegistered = prefs.getBool(_kSupportRegistered) ?? false;
      _supportScheme = prefs.getString(_kSupportScheme) ?? 'general';
      _openBoxOrders = (prefs.getStringList(_kOpenBox) ?? []).toSet();
      final methods = prefs.getString(_kDeliveryMethods);
      if (methods != null && methods.isNotEmpty) {
        _deliveryMethods = Map<String, String>.from(
          json.decode(methods) as Map,
        );
      }
      final custom = prefs.getStringList(_kCustomCollabs) ?? [];
      for (final raw in custom) {
        try {
          final post =
              CollabPost.fromJson(json.decode(raw) as Map<String, dynamic>);
          if (_collabs.every((c) => c.id != post.id)) _collabs.add(post);
        } catch (_) {
          // Skip one bad entry, keep the rest.
        }
      }
      // Re-apply persisted join/interest counts onto seed data.
      for (var i = 0; i < _collectives.length; i++) {
        if (_joinedCollectives.contains(_collectives[i].id)) {
          _collectives[i] =
              _collectives[i].copyWith(joinedQty: _collectives[i].joinedQty);
        }
      }
      notifyListeners();
    } catch (_) {
      // Prefs unavailable: demo data still works in memory.
    }
    // Best-effort backend sync (logged-in users only).
    refreshFromBackend();
  }

  Future<void> _save(SharedPreferences prefs) async {
    try {
      await prefs.setStringList(
          _kJoinedCollectives, _joinedCollectives.toList());
      await prefs.setStringList(
          _kInterestedCollabs, _interestedCollabs.toList());
      await prefs.setStringList(_kAppliedSchemes, _appliedSchemes.toList());
      await prefs.setBool(_kSupportRegistered, _supportRegistered);
      await prefs.setString(_kSupportScheme, _supportScheme);
      await prefs.setStringList(_kOpenBox, _openBoxOrders.toList());
      await prefs.setString(_kDeliveryMethods, json.encode(_deliveryMethods));
    } catch (_) {
      // Best-effort persistence.
    }
  }

  bool get _useBackend => AppConfig.isAuthenticated;

  ApiService _api() => ApiService();

  /// Pull server state and merge over local demo data.
  Future<void> refreshFromBackend() async {
    if (!_useBackend) return;
    _isSyncing = true;
    _lastError = null;
    notifyListeners();
    try {
      final api = _api();
      final col = await api.get<List<dynamic>>('/community/collectives',
          fromJson: (b) => (b as List).toList());
      if (col.success && col.data != null) {
        final server = <CollectiveOrder>[];
        final joined = <String>{};
        for (final raw in col.data!) {
          final m = Map<String, dynamic>.from(raw as Map);
          server.add(CollectiveOrder(
            id: '${m['id']}', title: '${m['title']}',
            productName: '${m['product_name'] ?? m['productName'] ?? ''}',
            price: (m['price'] as num? ?? 0).toDouble(),
            targetQty: (m['target_qty'] ?? m['targetQty'] ?? 0) as int,
            joinedQty: (m['joined_qty'] ?? m['joinedQty'] ?? 0) as int,
            endsIn: '${m['ends_in'] ?? m['endsIn'] ?? ''}',
          ));
          if (m['joined'] == true) joined.add('${m['id']}');
        }
        if (server.isNotEmpty) {
          _collectives = server;
          _joinedCollectives = joined;
        }
      }
      final posts = await api.get<List<dynamic>>('/community/collabs',
          fromJson: (b) => (b as List).toList());
      if (posts.success && posts.data != null) {
        final server = <CollabPost>[];
        final interested = <String>{};
        for (final raw in posts.data!) {
          final m = Map<String, dynamic>.from(raw as Map);
          server.add(CollabPost(
            id: '${m['id']}', title: '${m['title']}',
            type: '${m['type']}', description: '${m['description'] ?? ''}',
            author: '${m['author'] ?? ''}', location: '${m['location'] ?? ''}',
            interestedCount: (m['interested_count'] ?? m['interestedCount'] ?? 0) as int,
            interested: m['interested'] == true,
          ));
          if (m['interested'] == true) interested.add('${m['id']}');
        }
        // Keep locally-created posts that the server doesn't know yet.
        final serverIds = server.map((e) => e.id).toSet();
        for (final local in _collabs) {
          if (local.id.startsWith('k') && local.id.length > 5 &&
              !serverIds.contains(local.id)) {
            server.insert(0, local);
          }
        }
        if (server.isNotEmpty) _collabs = server;
        _interestedCollabs = interested;
      }
      final sup = await api.get<Map<String, dynamic>>('/community/support/status',
          fromJson: (b) => Map<String, dynamic>.from(b as Map));
      if (sup.success && sup.data != null) {
        _supportRegistered = sup.data!['registered'] == true;
        _supportScheme = '${sup.data!['scheme'] ?? _supportScheme}';
      }
      final del = await api.get<List<dynamic>>('/community/delivery',
          fromJson: (b) => (b as List).toList());
      if (del.success && del.data != null) {
        for (final raw in del.data!) {
          final m = Map<String, dynamic>.from(raw as Map);
          _deliveryMethods['${m['order_id']}'] = '${m['method']}';
          if (m['open_box'] == true) {
            _openBoxOrders.add('${m['order_id']}');
          } else {
            _openBoxOrders.remove('${m['order_id']}');
          }
        }
      }
    } catch (e) {
      _lastError = '$e';
    }
    _isSyncing = false;
    notifyListeners();
    try {
      _save(await SharedPreferences.getInstance());
    } catch (_) {}
  }

  Future<bool> toggleJoinCollective(String id) async {
    final idx = _collectives.indexWhere((c) => c.id == id);
    if (idx < 0) return false;
    final order = _collectives[idx];
    final wasJoined = _joinedCollectives.contains(id);
    // Optimistic UI — update instantly so the button visibly changes.
    if (wasJoined) {
      _joinedCollectives.remove(id);
      _collectives[idx] =
          order.copyWith(joinedQty: (order.joinedQty - 1).clamp(0, 1 << 30));
    } else {
      _joinedCollectives.add(id);
      _collectives[idx] = order.copyWith(joinedQty: order.joinedQty + 1);
    }
    notifyListeners();
    try {
      _save(await SharedPreferences.getInstance());
    } catch (_) {}
    if (_useBackend && !id.startsWith('c')) {
      // Seed ids (c1..c3) exist server-side too after seeding, so sync them.
    }
    if (_useBackend) {
      try {
        final res = await _api().post<Map<String, dynamic>>(
            '/community/collectives/$id/toggle',
            fromJson: (b) => Map<String, dynamic>.from(b as Map));
        if (res.success && res.data != null) {
          final m = res.data!;
          final serverJoined = m['joined'] == true;
          final qty = (m['joined_qty'] ?? m['joinedQty'] ?? _collectives[idx].joinedQty) as int;
          if (serverJoined) {
            _joinedCollectives.add(id);
          } else {
            _joinedCollectives.remove(id);
          }
          _collectives[idx] = _collectives[idx].copyWith(joinedQty: qty);
          notifyListeners();
        }
      } catch (_) {
        // Offline: keep local optimistic state.
      }
    }
    return !wasJoined;
  }

  Future<bool> toggleInterest(String id) async {
    final idx = _collabs.indexWhere((c) => c.id == id);
    if (idx < 0) return false;
    final post = _collabs[idx];
    final wasInterested =
        _interestedCollabs.contains(id) || post.interested;
    if (_interestedCollabs.contains(id)) {
      _interestedCollabs.remove(id);
      _collabs[idx] = post.copyWith(
        interested: false,
        interestedCount: (post.interestedCount - 1).clamp(0, 1 << 30),
      );
    } else {
      _interestedCollabs.add(id);
      _collabs[idx] = post.copyWith(
        interested: true,
        interestedCount: post.interestedCount + 1,
      );
    }
    notifyListeners();
    try {
      _save(await SharedPreferences.getInstance());
    } catch (_) {}
    if (_useBackend && !id.startsWith('k1') && !id.startsWith('k2') && !id.startsWith('k3') ||
        (_useBackend && id.length > 10)) {
      try {
        final res = await _api().post<Map<String, dynamic>>(
            '/community/collabs/$id/toggle',
            fromJson: (b) => Map<String, dynamic>.from(b as Map));
        if (res.success && res.data != null) {
          final m = res.data!;
          final serverInterested = m['interested'] == true;
          final count =
              (m['interested_count'] ?? m['interestedCount'] ?? 0) as int;
          if (serverInterested) {
            _interestedCollabs.add(id);
          } else {
            _interestedCollabs.remove(id);
          }
          _collabs[idx] = _collabs[idx]
              .copyWith(interested: serverInterested, interestedCount: count);
          notifyListeners();
        }
      } catch (_) {}
    }
    return !wasInterested;
  }

  Future<void> addCollabPost({
    required String title,
    required String type,
    required String description,
  }) async {
    final post = CollabPost(
      id: 'k${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      description: description,
      author: 'You',
      location: 'Your area',
    );
    _collabs.insert(0, post);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getStringList(_kCustomCollabs) ?? [];
      custom.add(json.encode(post.toJson()));
      await prefs.setStringList(_kCustomCollabs, custom);
    } catch (_) {}
    if (_useBackend) {
      try {
        final res = await _api().post<Map<String, dynamic>>(
            '/community/collabs',
            data: {'title': title, 'type': type, 'description': description},
            fromJson: (b) => Map<String, dynamic>.from(b as Map));
        if (res.success && res.data != null) {
          final m = res.data!;
          _collabs[0] = CollabPost(
            id: '${m['id']}', title: '${m['title']}',
            type: '${m['type']}', description: '${m['description'] ?? ''}',
            author: '${m['author'] ?? 'You'}',
            location: '${m['location'] ?? ''}',
            interestedCount: 0, interested: false,
          );
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<void> addSecondHandItem({
    required String title,
    required double price,
    required double mrp,
    required String condition,
    required String seller,
  }) async {
    final item = SecondHandItem(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      price: price,
      mrp: mrp,
      condition: condition,
      seller: seller.isEmpty ? 'You' : seller,
    );
    _secondHand.insert(0, item);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _kCustomCollabs, prefs.getStringList(_kCustomCollabs) ?? []);
    } catch (_) {}
  }

  Future<void> setSupportRegistered(bool value,
      {String scheme = 'general'}) async {
    _supportRegistered = value;
    if (value) _supportScheme = scheme;
    notifyListeners();
    try {
      _save(await SharedPreferences.getInstance());
    } catch (_) {}
    if (_useBackend && value) {
      try {
        await _api().post<Map<String, dynamic>>('/community/support/register',
            data: {'scheme': scheme},
            fromJson: (b) => Map<String, dynamic>.from(b as Map));
      } catch (_) {}
    }
  }

  Future<void> applyForScheme(String schemeId) async {
    _appliedSchemes.add(schemeId);
    _supportRegistered = true;
    _supportScheme = schemeId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kAppliedSchemes, _appliedSchemes.toList());
      await _save(prefs);
    } catch (_) {}
    if (_useBackend) {
      try {
        await _api().post<Map<String, dynamic>>('/community/support/register',
            data: {'scheme': schemeId},
            fromJson: (b) => Map<String, dynamic>.from(b as Map));
      } catch (_) {}
    }
  }

  Future<void> setDelivery(String orderId, String method, bool openBox) async {
    _deliveryMethods[orderId] = method;
    if (openBox) {
      _openBoxOrders.add(orderId);
    } else {
      _openBoxOrders.remove(orderId);
    }
    notifyListeners();
    try {
      _save(await SharedPreferences.getInstance());
    } catch (_) {}
    if (_useBackend) {
      try {
        await _api().put<Map<String, dynamic>>('/community/delivery/$orderId',
            data: {'method': method, 'open_box': openBox},
            fromJson: (b) => Map<String, dynamic>.from(b as Map));
      } catch (_) {}
    }
  }
}
