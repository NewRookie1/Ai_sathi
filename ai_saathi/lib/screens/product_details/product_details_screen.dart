import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/market_service.dart';
import '../../services/localization_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final productService = context.read<ProductService>();
    final product = await productService.getProduct(widget.productId);
    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t('product_details'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t('product_details'))),
        body: Center(child: Text(context.t('product_not_found'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('product_details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/add-product', extra: _product),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: 24),
                  _buildPriceSection(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      color: Colors.grey[200],
      child: _product!.images.isNotEmpty
          ? PageView.builder(
              itemCount: _product!.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _product!.images[index].url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, size: 60, color: Colors.grey),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Icon(Icons.image, size: 60, color: Colors.grey),
            ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _product!.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (_product!.category != null)
          Chip(
            label: Text(_product!.category!),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          ),
        const SizedBox(height: 12),
        Text(
          _product!.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        if (_product!.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _product!.tags.map((tag) {
              return Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('pricing'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.t('current_price')),
                Text(
                  '₹${_product!.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            if (_product!.minPrice != null && _product!.maxPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.t('suggested_range')),
                  Text(
                    '₹${_product!.minPrice!.toStringAsFixed(0)} - ₹${_product!.maxPrice!.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _product!.stats;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('performance'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context.t('views'), stats.views.toString()),
                _buildStatItem(context.t('orders'), stats.orders.toString()),
                _buildStatItem(context.t('sold'), stats.quantitySold.toString()),
                _buildStatItem(context.t('revenue'), '₹${stats.revenue.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _getPriceSuggestion,
            icon: const Icon(Icons.attach_money),
            label: Text(context.t('get_price')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _analyzeMarket,
            icon: const Icon(Icons.trending_up),
            label: Text(context.t('market')),
          ),
        ),
      ],
    );
  }

  Future<void> _getPriceSuggestion() async {
    final marketService = context.read<MarketService>();
    final suggestion = await marketService.suggestPrice(productId: widget.productId);

    if (suggestion != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.t('price_suggestion')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${suggestion.suggestedPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Range: ₹${suggestion.priceRange.min.toStringAsFixed(0)} - ₹${suggestion.priceRange.max.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(suggestion.reasoning),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.t('close')),
            ),
          ],
        ),
      );
    }
  }

  void _analyzeMarket() {
    context.push('/market', extra: _product!.category);
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('delete_product')),
        content: Text('${context.t('delete_confirm')}${_product!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productService = context.read<ProductService>();
      final success = await productService.deleteProduct(widget.productId);
      if (success && mounted) {
        context.pop();
      }
    }
  }
}