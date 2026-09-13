import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/localization_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('notifications')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: settings.notifOrders,
            title: Text(context.t('notif_orders')),
            secondary: const Icon(Icons.shopping_bag_outlined),
            onChanged: (v) => settings.setNotification('orders', v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: settings.notifPrice,
            title: Text(context.t('notif_price')),
            secondary: const Icon(Icons.price_change_outlined),
            onChanged: (v) => settings.setNotification('price', v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: settings.notifMarket,
            title: Text(context.t('notif_market')),
            secondary: const Icon(Icons.trending_up),
            onChanged: (v) => settings.setNotification('market', v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: settings.notifVoice,
            title: Text(context.t('notif_voice')),
            secondary: const Icon(Icons.mic_outlined),
            onChanged: (v) => settings.setNotification('voice', v),
          ),
        ],
      ),
    );
  }
}
