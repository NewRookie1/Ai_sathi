import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/community_service.dart';
import '../../services/order_service.dart';
import '../../services/localization_service.dart';

class EasyDeliveryScreen extends StatefulWidget {
  const EasyDeliveryScreen({super.key});

  @override
  State<EasyDeliveryScreen> createState() => _EasyDeliveryScreenState();
}

class _EasyDeliveryScreenState extends State<EasyDeliveryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<OrderService>().loadOrders();
      if (mounted) await context.read<CommunityService>().refreshFromBackend();
    });
  }

  static const _options = [
    ('pickup', Icons.store, 'Pickup', 'Free • ready in 1 day', '₹0'),
    ('standard', Icons.local_shipping, 'Standard', '3–5 days • tracked', '₹49'),
    ('express', Icons.bolt, 'Express', '1–2 days • priority', '₹99'),
  ];

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityService>();
    final orders = context.watch<OrderService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('easy_delivery')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: community.isSyncing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderService>().loadOrders();
          await context.read<CommunityService>().refreshFromBackend();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.blue.withOpacity(0.12),
                  Colors.cyan.withOpacity(0.12),
                ]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping,
                      size: 40, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.t('easy_delivery'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(context.t('delivery_desc'),
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Delivery options',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._options.map((o) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(o.$2, color: Colors.blue),
                    title: Text(o.$3,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(o.$4),
                    trailing: Text(o.$5,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor)),
                  ),
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your orders',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () => context.push('/orders'),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(context.t('view_all')),
                ),
              ],
            ),
            if (orders.isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()))
            else if (orders.orders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(context.t('no_orders')),
                      const SizedBox(height: 4),
                      const Text(
                          'Delivery choices will appear here once you have orders.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else
              ...orders.orders.map((order) {
                final method = community.deliveryMethod(order.id);
                final openBox = community.openBox(order.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(order.buyerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Text('₹${order.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor)),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onPressed: () =>
                                  context.push('/order/${order.id}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                                value: 'pickup',
                                label: Text('Pickup',
                                    style: TextStyle(fontSize: 12)),
                                icon: Icon(Icons.store, size: 14)),
                            ButtonSegment(
                                value: 'standard',
                                label: Text('Standard',
                                    style: TextStyle(fontSize: 12)),
                                icon:
                                    Icon(Icons.local_shipping, size: 14)),
                            ButtonSegment(
                                value: 'express',
                                label: Text('Express',
                                    style: TextStyle(fontSize: 12)),
                                icon: Icon(Icons.bolt, size: 14)),
                          ],
                          selected: {method},
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.compact),
                          onSelectionChanged: (s) async {
                            await community.setDelivery(
                                order.id, s.first, openBox);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                    content:
                                        Text(context.t('delivery_saved')),
                                    duration:
                                        const Duration(seconds: 1)));
                            }
                          },
                        ),
                        SwitchListTile(
                          value: openBox,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.t('open_box'),
                              style: const TextStyle(fontSize: 13)),
                          onChanged: (v) =>
                              community.setDelivery(order.id, method, v),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
