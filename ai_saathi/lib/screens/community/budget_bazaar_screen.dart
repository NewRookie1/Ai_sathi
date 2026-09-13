import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/theme.dart';
import '../../services/localization_service.dart';

class _BudgetItem {
  final String title;
  final double price;
  final String seller;

  const _BudgetItem({
    required this.title,
    required this.price,
    required this.seller,
  });
}

class BudgetBazaarScreen extends StatefulWidget {
  const BudgetBazaarScreen({super.key});

  @override
  State<BudgetBazaarScreen> createState() => _BudgetBazaarScreenState();
}

class _BudgetBazaarScreenState extends State<BudgetBazaarScreen> {
  double _maxPrice = 999;

  static const List<_BudgetItem> _items = [
    _BudgetItem(title: 'Clay Diya Set (12 pc)', price: 299, seller: 'Clay Works'),
    _BudgetItem(title: 'Jute Shopping Bag', price: 199, seller: 'Eco Crafts'),
    _BudgetItem(title: 'Bamboo Pen Stand', price: 349, seller: 'Ravi Kumar'),
    _BudgetItem(title: 'Cotton Face Masks (5 pc)', price: 249, seller: 'Meera Arts'),
    _BudgetItem(title: 'Paper Mache Box', price: 499, seller: 'Kashmir Crafts'),
    _BudgetItem(title: 'Wooden Keychain Pair', price: 149, seller: 'Karan Mistry'),
    _BudgetItem(title: 'Terracotta Planter', price: 799, seller: 'Clay Works'),
    _BudgetItem(title: 'Handloom Stole', price: 899, seller: 'Loom House'),
  ];

  @override
  Widget build(BuildContext context) {
    final visible =
        _items.where((item) => item.price <= _maxPrice).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('budget_bazaar')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.t('budget_desc'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _priceChip(context, 299, 'under_299'),
              _priceChip(context, 499, 'under_499'),
              _priceChip(context, 999, 'under_999'),
            ],
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(context.t('no_products'))),
            ),
          ...visible.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.savings,
                        color: Colors.orange, size: 28),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.seller),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _priceChip(BuildContext context, double max, String labelKey) {
    final selected = _maxPrice == max;
    return ChoiceChip(
      label: Text(context.t(labelKey)),
      selected: selected,
      onSelected: (_) => setState(() => _maxPrice = max),
      selectedColor: AppTheme.primaryColor.withOpacity(0.15),
    );
  }
}
