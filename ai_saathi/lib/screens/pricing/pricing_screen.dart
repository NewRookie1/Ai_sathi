import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/localization_service.dart';
import '../../services/market_service.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _laborCostController = TextEditingController();
  Map<String, dynamic>? _suggestion;
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _materialCostController.dispose();
    _laborCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('price_assistant')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildInputForm(),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_suggestion != null)
                _buildSuggestionResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.t('pricing_info'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('product_details'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: context.t('product_category'),
                hintText: context.t('category_hint'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.t('enter_category');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _materialCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.t('material_cost'),
                hintText: '0',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _laborCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.t('labor_cost'),
                hintText: '0',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getPriceSuggestion,
              child: Text(context.t('get_price')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.t('suggested_price'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_suggestion!['is_estimate'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.t('estimate'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '₹${_suggestion!['suggested_price']?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Range: ₹${_suggestion!['price_range']?['min']?.toStringAsFixed(0) ?? '0'} - ₹${_suggestion!['price_range']?['max']?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              _suggestion!['reasoning'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${context.t('confidence')}: ${((_suggestion!['confidence'] ?? 0) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getPriceSuggestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final marketService = context.read<MarketService>();
      final suggestion = await marketService.suggestPrice(
        productId: '',
        rawMaterialCost: double.tryParse(_materialCostController.text),
        laborCost: double.tryParse(_laborCostController.text),
      );

      if (suggestion != null) {
        setState(() {
          _suggestion = suggestion.toJson();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('price_failed'))),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}