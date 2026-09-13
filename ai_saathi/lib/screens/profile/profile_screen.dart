import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../providers/localization_provider.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';
import '../../services/localization_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
    'gu': 'ગુજરાતી',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ',
    'ml': 'മലയാളം',
    'pa': 'ਪੰਜਾਬੀ',
  };

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('profile')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, authService),
          const SizedBox(height: 16),
          _buildRoleSwitchCard(context, authService),
          const SizedBox(height: 24),
          _buildSettingsSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
          const SizedBox(height: 24),
          _buildLogoutButton(context, authService),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthService authService) {
    final settings = context.watch<SettingsService>();
    final authShop = authService.user?.shopName;
    final shopName = (authShop != null && authShop.isNotEmpty)
        ? authShop
        : (settings.shopName.isNotEmpty ? settings.shopName : null);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authService.user?.name ?? context.t('hello_artisan'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              authService.user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            if (shopName != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(shopName),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitchCard(
      BuildContext context, AuthService authService) {
    final isBuyer = authService.user?.isBuyer ?? false;
    return Card(
      color: const Color(0xFFE65100).withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  AppTheme.primaryColor.withOpacity(0.12),
              child: Icon(
                isBuyer
                    ? Icons.handyman_outlined
                    : Icons.shopping_bag_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuyer ? 'Buyer Mode' : 'Seller Mode',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    isBuyer
                        ? 'Shopping as buyer — switch to sell'
                        : 'Selling as artisan — switch to shop',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final target = isBuyer ? 'artisan' : 'buyer';
                final ok =
                    await authService.switchRole(target);
                if (!context.mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBuyer
                          ? 'Switched to Seller ✓'
                          : 'Switched to Buyer ✓'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  if (isBuyer) {
                    context.go('/home');
                  } else {
                    context.go('/buyer-home');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not switch role')),
                  );
                }
              },
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(isBuyer ? 'Sell' : 'Buy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final langCode = context.watch<LocalizationProvider>().currentLanguage;
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: context.t('language'),
            subtitle: _languageNames[langCode] ?? 'English',
            onTap: () => context.push('/settings/language'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: context.t('notifications'),
            onTap: () => context.push('/settings/notifications'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.store_outlined,
            title: context.t('shop_settings'),
            onTap: () => context.push('/settings/shop'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.payment,
            title: context.t('payment_settings'),
            onTap: () => context.push('/settings/payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: context.t('help_support'),
            onTap: () => context.push('/settings/help'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.school_outlined,
            title: 'App Tutorial',
            subtitle: 'Learn in 2 minutes',
            onTap: () => context.push('/tutorial'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: context.t('about'),
            subtitle: context.t('version'),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.star_outline,
            title: context.t('rate_app'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.t('thanks_rating'))),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('app_name')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t('about_text')),
            const SizedBox(height: 12),
            Text(
              context.t('version'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
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

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return OutlinedButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.t('logout')),
            content: Text(context.t('logout_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.t('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(context.t('logout')),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await authService.logout();
          context.go('/login');
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      ),
      child: Text(context.t('logout')),
    );
  }
}