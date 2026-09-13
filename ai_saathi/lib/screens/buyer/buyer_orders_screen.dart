import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/marketplace_service.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<MarketplaceService>().loadMyOrders());
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'new':
        return Colors.blue;
      case 'pending':
      case 'accepted':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<MarketplaceService>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: RefreshIndicator(
        onRefresh: () => shop.loadMyOrders(),
        child: shop.myOrders.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet.\nShop handmade products and your orders appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/buyer-home'),
                    child: const Text('Start Shopping'),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: shop.myOrders.length,
                itemBuilder: (context, i) {
                  final o = shop.myOrders[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                    '${o.items.length} item(s) • ₹${o.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(o.status)
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(o.status,
                                    style: TextStyle(
                                        color:
                                            _statusColor(o.status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...o.items.map((it) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4),
                                child: Text(
                                    '• ${it.productName} × ${it.quantity} — ₹${it.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 13)),
                              )),
                          if (o.shippingAddress != null) ...[
                            const SizedBox(height: 4),
                            Text('📍 ${o.shippingAddress!}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
