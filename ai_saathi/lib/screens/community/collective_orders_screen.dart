import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/community_service.dart';
import '../../services/localization_service.dart';

class CollectiveOrdersScreen extends StatefulWidget {
  const CollectiveOrdersScreen({super.key});

  @override
  State<CollectiveOrdersScreen> createState() => _CollectiveOrdersScreenState();
}

class _CollectiveOrdersScreenState extends State<CollectiveOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Pull server state in background; local demo data shows instantly.
    Future.microtask(
        () => context.read<CommunityService>().refreshFromBackend());
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CommunityService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('collective_orders')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: service.isSyncing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () => service.refreshFromBackend(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.t('collective_desc'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            ...service.collectives.map((order) {
              final joined = service.isJoined(order.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${context.t('ends_in')} ${order.endsIn}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.productName,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: order.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.joinedQty}/${order.targetQty} • ${order.spotsLeft} ${context.t('spots_left')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          '₹${order.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final nowJoined = await service
                              .toggleJoinCollective(order.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(nowJoined
                                      ? '${context.t('joined')} ✓ (${order.joinedQty + 1})'
                                      : context.t('join')),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                          }
                        },
                        icon: Icon(
                            joined ? Icons.check_circle : Icons.group_add,
                            size: 18),
                        label:
                            Text(context.t(joined ? 'joined' : 'join')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: joined
                              ? Colors.green
                              : AppTheme.primaryColor,
                        ),
                      ),
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
