import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';
import '../../core/config/theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

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
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 12),
              _buildSubtitle(),
              const SizedBox(height: 36),
              Expanded(
                child: _buildLanguageGrid(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.language,
          size: 48,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(height: 16),
        const Text(
          'Choose Your Language',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'भाषा चुनें',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildSubtitle() {
    return const Text(
      'Select your preferred language',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildLanguageGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        return _buildLanguageCard(
          context: context,
          language: languages[index],
          index: index,
        );
      },
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required Map<String, String> language,
    required int index,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _selectLanguage(context, language['code']!),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  language['native']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  language['english']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 400.ms,
          delay: Duration(milliseconds: 100 * index),
        );
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    context.read<LocalizationProvider>().setLanguage(languageCode);
    context.go('/onboarding');
  }
}
