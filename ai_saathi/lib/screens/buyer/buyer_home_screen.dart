import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/marketplace_service.dart';

class BuyerScaffold extends StatelessWidget {
  final Widget child;
  const BuyerScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(context, 0, Icons.store_outlined, Icons.store, 'Shop'),
              _item(context, 1, Icons.receipt_long_outlined,
                  Icons.receipt_long, 'My Orders'),
              _item(context, 2, Icons.person_outlined, Icons.person,
                  'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int idx, IconData icon,
      IconData active, String label) {
    final loc = GoRouterState.of(context).uri.toString();
    final current = loc.startsWith('/buyer-orders')
        ? 1
        : loc.startsWith('/profile') || loc.startsWith('/settings')
            ? 2
            : 0;
    final selected = idx == current;
    final color =
        selected ? const Color(0xFFE65100) : Colors.grey.shade600;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (idx == 0) context.go('/buyer-home');
          if (idx == 1) context.go('/buyer-orders');
          if (idx == 2) context.go('/profile');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? active : icon, color: color),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _category = '';

  static const _categories = [
    '',
    'Pottery',
    'Textiles',
    'Home Decor',
    'Jewelry',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MarketplaceService>().browse());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<MarketplaceService>();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Bazaar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Handmade, directly from artisans',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => shop.browse(
            search: _searchCtrl.text.trim(),
            category: _category.isEmpty ? null : _category),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search diyas, sarees, baskets…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    shop.browse(
                        category:
                            _category.isEmpty ? null : _category);
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (v) => shop.browse(
                  search: v.trim(),
                  category: _category.isEmpty ? null : _category),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final sel = c == _category;
                  return ChoiceChip(
                    label: Text(c.isEmpty ? 'All' : c),
                    selected: sel,
                    onSelected: (_) {
                      setState(() => _category = c);
                      shop.browse(
                          search: _searchCtrl.text.trim(),
                          category: c.isEmpty ? null : c);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (shop.isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator()))
            else if (shop.products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(shop.error ?? 'No products found'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: shop.products.length,
                itemBuilder: (context, i) {
                  final p = shop.products[i];
                  final out = p.quantity <= 0;
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          context.push('/buyer-product/${p.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius:
                                    const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                              ),
                              child: Center(
                                child: Icon(Icons.handyman,
                                    size: 44,
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.5)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                if (p.category != null)
                                  Text(p.category!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '₹${p.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                AppTheme.primaryColor,
                                            fontSize: 16)),
                                    Text(
                                        out
                                            ? 'Sold out'
                                            : '${p.quantity} left',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: out
                                                ? Colors.red
                                                : Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
