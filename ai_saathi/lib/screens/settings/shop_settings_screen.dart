import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/localization_service.dart';

class ShopSettingsScreen extends StatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  State<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends State<ShopSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descController;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _initFrom(SettingsService settings) {
    if (_initialized) return;
    _initialized = true;
    _nameController = TextEditingController(text: settings.shopName);
    _locationController = TextEditingController(text: settings.shopLocation);
    _descController = TextEditingController(text: settings.shopDesc);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    _initFrom(settings);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('shop_settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.t('shop_name'),
                prefixIcon: const Icon(Icons.storefront),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? context.t('enter_name') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: context.t('shop_location'),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.t('shop_desc'),
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : () => _save(settings),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.t('save_changes')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(SettingsService settings) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await settings.saveShop(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      desc: _descController.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('saved'))),
      );
      context.pop();
    }
  }
}
