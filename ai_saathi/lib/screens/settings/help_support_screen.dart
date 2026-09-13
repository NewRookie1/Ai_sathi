import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/localization_service.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<List<String>> _faqs = [
    ['faq_q1', 'faq_a1'],
    ['faq_q2', 'faq_a2'],
    ['faq_q3', 'faq_a3'],
    ['faq_q4', 'faq_a4'],
    ['faq_q5', 'faq_a5'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('help_support')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFE65100).withOpacity(0.08),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE65100),
                child:
                    Icon(Icons.school_outlined, color: Colors.white),
              ),
              title: const Text('App Tutorial',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Step-by-step tour: voice, scan, orders, community'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/tutorial'),
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(
                    context.t(faq[0]),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(context.t(faq[1])),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.headset_mic_outlined),
              title: Text(context.t('contact_support')),
              subtitle: Text(context.t('contact_desc')),
            ),
          ),
        ],
      ),
    );
  }
}
