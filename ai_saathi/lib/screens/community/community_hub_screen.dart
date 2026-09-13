import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/theme.dart';
import '../../services/localization_service.dart';

class _HubTile {
  final IconData icon;
  final String labelKey;
  final String descKey;
  final Color color;
  final String route;

  const _HubTile({
    required this.icon,
    required this.labelKey,
    required this.descKey,
    required this.color,
    required this.route,
  });
}

class CommunityHubScreen extends StatelessWidget {
  const CommunityHubScreen({super.key});

  static const List<_HubTile> _tiles = [
    _HubTile(
      icon: Icons.group,
      labelKey: 'collective_orders',
      descKey: 'collective_desc',
      color: Colors.teal,
      route: '/collective-orders',
    ),
    _HubTile(
      icon: Icons.recycling,
      labelKey: 'second_hand',
      descKey: 'second_hand_desc',
      color: Colors.green,
      route: '/second-hand',
    ),
    _HubTile(
      icon: Icons.handshake,
      labelKey: 'collaboration',
      descKey: 'collaboration_desc',
      color: Colors.purple,
      route: '/collaboration',
    ),
    _HubTile(
      icon: Icons.savings,
      labelKey: 'budget_bazaar',
      descKey: 'budget_desc',
      color: Colors.orange,
      route: '/budget-bazaar',
    ),
    _HubTile(
      icon: Icons.volunteer_activism,
      labelKey: 'seller_support',
      descKey: 'support_desc',
      color: Colors.red,
      route: '/seller-support',
    ),
    _HubTile(
      icon: Icons.local_shipping,
      labelKey: 'easy_delivery',
      descKey: 'delivery_desc',
      color: Colors.blue,
      route: '/easy-delivery',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('community')),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.t('community_desc'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: _tiles.length,
            itemBuilder: (context, index) {
              final tile = _tiles[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(tile.route),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: tile.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(tile.icon,
                              color: tile.color, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.t(tile.labelKey),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t(tile.descKey),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
