import 'package:flutter/material.dart';
import '../core/config/theme.dart';
import '../models/market_analysis.dart';

class MarketCard extends StatelessWidget {
  final MarketAnalysis analysis;
  final VoidCallback? onTap;

  const MarketCard({
    super.key,
    required this.analysis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildDemandIndicator(analysis.demandScore),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                analysis.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Avg Price', '₹${analysis.averagePrice.toStringAsFixed(0)}'),
                  _buildStat('Listings', '${analysis.totalListings}'),
                  _buildStat(
                    'Confidence',
                    '${(analysis.confidence * 100).toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemandIndicator(double score) {
    Color color;
    String label;

    if (score >= 0.8) {
      color = Colors.green;
      label = 'High';
    } else if (score >= 0.5) {
      color = Colors.orange;
      label = 'Medium';
    } else {
      color = Colors.red;
      label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label Demand',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
