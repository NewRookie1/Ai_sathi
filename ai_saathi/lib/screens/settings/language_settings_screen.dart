import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/localization_service.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  static const List<Map<String, String>> languages = [
    {'english': 'English', 'native': 'English', 'code': 'en'},
    {'english': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'english': 'Marathi', 'native': 'मराठी', 'code': 'mr'},
    {'english': 'Gujarati', 'native': 'ગુજરાતી', 'code': 'gu'},
    {'english': 'Bengali', 'native': 'বাংলা', 'code': 'bn'},
    {'english': 'Tamil', 'native': 'தமிழ்', 'code': 'ta'},
    {'english': 'Telugu', 'native': 'తెలుగు', 'code': 'te'},
    {'english': 'Kannada', 'native': 'ಕನ್ನಡ', 'code': 'kn'},
    {'english': 'Malayalam', 'native': 'മലയാളം', 'code': 'ml'},
    {'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'code': 'pa'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocalizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('language')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        itemCount: languages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final selected = provider.currentLanguage == lang['code'];
          return ListTile(
            leading: Text(
              lang['native']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            title: Text(lang['english']!),
            trailing: selected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              provider.setLanguage(lang['code']!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.t('saved'))),
              );
            },
          );
        },
      ),
    );
  }
}
