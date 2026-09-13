import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/community_service.dart';
import '../../services/localization_service.dart';

class _Scheme {
  final String id;
  final IconData icon;
  final String title;
  final String desc;
  final String perk;
  const _Scheme(this.id, this.icon, this.title, this.desc, this.perk);
}

class SellerSupportScreen extends StatefulWidget {
  const SellerSupportScreen({super.key});

  @override
  State<SellerSupportScreen> createState() => _SellerSupportScreenState();
}

class _SellerSupportScreenState extends State<SellerSupportScreen> {
  static const _schemes = [
    _Scheme('zero_fee', Icons.money_off, 'Zero-Fee Launch',
        '0% commission for your first 90 days.', 'Save ~₹2,000'),
    _Scheme('spotlight', Icons.star, 'Artisan Spotlight',
        'Home-page feature + festival collection push.', '+3x views'),
    _Scheme('training', Icons.school, 'Skill Training',
        '2-week course: photos, pricing, online selling.', 'Certificate + stipend'),
    _Scheme('delivery', Icons.local_shipping, 'Delivery Help',
        'Discounted pickup + free packaging for 20 orders.', 'Save ~₹800'),
    _Scheme('marketing', Icons.campaign, 'Marketing Kit',
        'Product photos, reel captions, festival banners.', 'Ready in 2 days'),
    _Scheme('credit', Icons.savings, 'Raw-Material Credit',
        'Low-interest credit via partner self-help groups.', 'Up to ₹25,000'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<CommunityService>().refreshFromBackend());
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CommunityService>();
    final registered = service.supportRegistered;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('seller_support')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => service.refreshFromBackend(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.12),
                    Colors.orange.withOpacity(0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    context.t('seller_support'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t('support_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  if (registered) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${context.t('registered_badge')} • ${service.supportScheme}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Support schemes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._schemes.map((s) {
              final applied = service.isSchemeApplied(s.id) ||
                  (registered && service.supportScheme == s.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(s.icon, color: AppTheme.primaryColor),
                  ),
                  title: Text(s.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${s.desc}\n${s.perk}',
                      style: const TextStyle(fontSize: 12)),
                  isThreeLine: true,
                  trailing: applied
                      ? const Chip(
                          label: Text('Applied',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.green,
                          visualDensity: VisualDensity.compact,
                        )
                      : OutlinedButton(
                          onPressed: () async {
                            await service.applyForScheme(s.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                    content: Text('Applied: ${s.title} ✓')));
                            }
                          },
                          child: const Text('Apply'),
                        ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Training & help',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _benefitTile(context, Icons.photo_camera,
                'Product photography (12 min video)'),
            _benefitTile(
                context, Icons.price_check, 'Pricing masterclass (Hindi/Marathi)'),
            _benefitTile(context, Icons.chat,
                'WhatsApp support: reply within 2 hours, 9am–7pm'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await service.setSupportRegistered(!registered,
                      scheme: service.supportScheme);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(registered
                            ? 'Support paused'
                            : 'Welcome to Seller Support ✓')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      registered ? Colors.grey : AppTheme.primaryColor,
                ),
                child: Text(context.t(registered
                    ? 'support_registered'
                    : 'register_support')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitTile(BuildContext context, IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
