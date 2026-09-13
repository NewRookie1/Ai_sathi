class AppConstants {
  static const String appName = 'Artisan AI';
  static const String appTagline = 'Your AI Business Manager';
  
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;
  static const int maxImageSizeBytes = 5 * 1024 * 1024;
  
  static const int audioSampleRate = 16000;
  static const int maxRecordingDurationSeconds = 60;
  
  static const double minConfidenceForAction = 0.85;
  static const double clarifyConfidenceThreshold = 0.60;
  
  static const int maxConversationHistory = 20;
  static const int maxRetryAttempts = 3;
  
  static const List<String> supportedLanguages = [
    'en', 'mr', 'hi', 'gu', 'bn', 'ta', 'te', 'kn', 'ml', 'pa',
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'mr': 'Marathi',
    'hi': 'Hindi',
    'gu': 'Gujarati',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'te': 'Telugu',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'pa': 'Punjabi',
  };
}
