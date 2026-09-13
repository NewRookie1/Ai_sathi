import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/localization_service.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _upiController;
  late final TextEditingController _accountController;
  late String _method;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _upiController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _initFrom(SettingsService settings) {
    if (_initialized) return;
    _initialized = true;
    _upiController = TextEditingController(text: settings.upiId);
    _accountController = TextEditingController(text: settings.accountName);
    _method = settings.payoutMethod;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    _initFrom(settings);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('payment_settings')),
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
              controller: _accountController,
              decoration: InputDecoration(
                labelText: context.t('account_name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? context.t('enter_name') : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _method,
              decoration: InputDecoration(
                labelText: context.t('payout_method'),
                prefixIcon: const Icon(Icons.account_balance_outlined),
              ),
              items: [
                DropdownMenuItem(
                  value: 'upi',
                  child: Text(context.t('pay_upi')),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Text(context.t('pay_bank')),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _method = v);
              },
            ),
            const SizedBox(height: 16),
            if (_method == 'upi')
              TextFormField(
                controller: _upiController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.t('upi_id'),
                  hintText: 'name@okbank',
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.t('enter_upi');
                  }
                  if (!SettingsService.isValidUpi(v)) {
                    return context.t('valid_upi');
                  }
                  return null;
                },
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
    await settings.savePayout(
      upi: _upiController.text.trim(),
      method: _method,
      account: _accountController.text.trim(),
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
