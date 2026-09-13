import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../models/product.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_service.dart';

class BuyerProductScreen extends StatefulWidget {
  final String productId;
  const BuyerProductScreen({super.key, required this.productId});

  @override
  State<BuyerProductScreen> createState() => _BuyerProductScreenState();
}

class _BuyerProductScreenState extends State<BuyerProductScreen> {
  int _qty = 1;
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _phoneCtrl.text = auth.user?.phone ?? '';
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Product? _find(List<Product> list) {
    for (final p in list) {
      if (p.id == widget.productId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<MarketplaceService>();
    final product = _find(shop.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: product == null
          ? const Center(child: Text('Product not found'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(Icons.handyman,
                        size: 72,
                        color:
                            AppTheme.primaryColor.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                if (product.category != null)
                  Chip(label: Text(product.category!)),
                const SizedBox(height: 8),
                Text(product.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor)),
                    const SizedBox(width: 12),
                    Text(
                        product.quantity > 0
                            ? '${product.quantity} in stock'
                            : 'Sold out',
                        style: TextStyle(
                            color: product.quantity > 0
                                ? Colors.green
                                : Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: _qty > 1
                                  ? () => setState(() => _qty--)
                                  : null,
                            ),
                            Text('$_qty',
                                style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: _qty < product.quantity
                                  ? () => setState(() => _qty++)
                                  : null,
                            ),
                            const Spacer(),
                            Text(
                                'Total: ₹${(product.price * _qty).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Delivery address',
                            prefixIcon:
                                Icon(Icons.location_on_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: product.quantity <= 0 || shop.isOrdering
                        ? null
                        : () => _buy(context, shop, product),
                    icon: shop.isOrdering
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.shopping_bag),
                    label: Text(shop.isOrdering
                        ? 'Placing order…'
                        : 'Buy Now • ₹${(product.price * _qty).toStringAsFixed(0)}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _buy(
      BuildContext context, MarketplaceService shop, Product product) async {
    final ok = await shop.placeOrder(
      items: [
        {'productId': product.id, 'quantity': _qty}
      ],
      shippingAddress:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      buyerPhone:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed ✓ Track in My Orders')),
      );
      context.go('/buyer-orders');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(shop.error ?? 'Order failed')),
      );
    }
  }
}
