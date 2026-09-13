import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/community_service.dart';
import '../../services/localization_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final orderService = context.read<OrderService>();
    final order = await orderService.getOrder(widget.orderId);
    setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t('order_details'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t('order_details'))),
        body: Center(child: Text(context.t('order_not_found'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('order_details')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBuyerInfo(),
            const SizedBox(height: 16),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 16),
            _buildDeliverySection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('buyer_info'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    _order!.buyerName[0],
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _order!.buyerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (_order!.buyerPhone != null)
                        Text(
                          _order!.buyerPhone!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('order_items'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._order!.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: item.productImage != null
                          ? Image.network(
                              item.productImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image);
                              },
                            )
                          : const Icon(Icons.image),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('order_summary'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.t('total_amount')),
                Text(
                  '₹${_order!.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            if (_order!.shippingAddress != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                context.t('shipping_address'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _order!.shippingAddress!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    final community = context.watch<CommunityService>();
    final method = community.deliveryMethod(widget.orderId);
    final openBox = community.openBox(widget.orderId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('easy_delivery'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile<String>(
              value: 'pickup',
              groupValue: method,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(context.t('pickup')),
              onChanged: (v) => _saveDelivery(v!, openBox),
            ),
            RadioListTile<String>(
              value: 'standard',
              groupValue: method,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(context.t('standard_delivery')),
              onChanged: (v) => _saveDelivery(v!, openBox),
            ),
            RadioListTile<String>(
              value: 'express',
              groupValue: method,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(context.t('express_delivery')),
              onChanged: (v) => _saveDelivery(v!, openBox),
            ),
            const Divider(),
            SwitchListTile(
              value: openBox,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(context.t('open_box')),
              subtitle: Text(context.t('open_box_desc')),
              onChanged: (v) => _saveDelivery(method, v),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDelivery(String method, bool openBox) async {
    await context
        .read<CommunityService>()
        .setDelivery(widget.orderId, method, openBox);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('delivery_saved'))),
      );
    }
  }

  Widget _buildActionButtons() {
    if (_order!.status == 'new') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _rejectOrder,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: Text(context.t('reject')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _acceptOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(context.t('accept')),
            ),
          ),
        ],
      );
    }

    if (_order!.status == 'pending' || _order!.status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _cancelOrder,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: Text(context.t('cancel_order')),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _acceptOrder() async {
    final orderService = context.read<OrderService>();
    final success = await orderService.acceptOrder(widget.orderId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('order_accepted'))),
      );
      _loadOrder();
    }
  }

  Future<void> _rejectOrder() async {
    final orderService = context.read<OrderService>();
    final success = await orderService.rejectOrder(widget.orderId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('order_rejected'))),
      );
      _loadOrder();
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('cancel_order')),
        content: Text(context.t('cancel_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.t('no')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.t('yes_cancel')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final orderService = context.read<OrderService>();
      final success = await orderService.cancelOrder(widget.orderId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('order_cancelled'))),
        );
        _loadOrder();
      }
    }
  }
}