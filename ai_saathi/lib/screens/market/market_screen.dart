import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/market_service.dart';
import '../../services/localization_service.dart';

class MarketScreen extends StatefulWidget {
  final String? category;

  const MarketScreen({super.key, this.category});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketService>().getTrends();
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketService = context.watch<MarketService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('market_analysis')),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<MarketService>().getTrends(),
        child: marketService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTrendingSection(marketService),
                  const SizedBox(height: 24),
                  _buildInsightsSection(marketService),
                ],
              ),
      ),
    );
  }

  Widget _buildTrendingSection(MarketService marketService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('trending_now'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: marketService.analyses.isEmpty
              ? Center(
                  child: Text(
                    context.t('no_trending'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: marketService.analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = marketService.analyses[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    analysis.category,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  _buildDemandBadge(analysis.demandScore),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                analysis.summary,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${analysis.averagePrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${analysis.totalListings} ${context.t('listings')}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(MarketService marketService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('market_insights'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context.t('avg_price'),
          '₹1,200',
          '+5.2%',
          Icons.attach_money,
        ),
        const SizedBox(height: 8),
        _buildInsightCard(
          context.t('total_listings'),
          '4,500',
          '+12%',
          Icons.inventory_2,
        ),
        const SizedBox(height: 8),
        _buildInsightCard(
          context.t('demand_score'),
          '0.82',
          '+8%',
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildDemandBadge(double score) {
    Color color;
    String label;

    if (score >= 0.8) {
      color = Colors.green;
      label = context.t('demand_high');
    } else if (score >= 0.5) {
      color = Colors.orange;
      label = context.t('demand_medium');
    } else {
      color = Colors.red;
      label = context.t('demand_low');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label ${context.t('demand')}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, String subtitle, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}