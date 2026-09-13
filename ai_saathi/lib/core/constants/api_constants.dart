class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  
  // Speech
  static const String transcribe = '/speech/transcribe';
  
  // Translation
  static const String translate = '/translate';
  
  // Voice Chat
  static const String voiceChat = '/voice-chat';
  
  // Image
  static const String analyzeImage = '/image/analyze';
  static const String enhanceImage = '/image/enhance';
  static const String classifyImage = '/image/classify';
  
  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static String productPrice(String id) => '/products/$id/price-suggestion';
  static String productPerformance(String id) => '/products/$id/performance';
  
  // Market
  static const String marketAnalysis = '/market/analysis';
  static const String marketTrends = '/market/trends';
  static const String trendingProducts = '/market/trending';
  
  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // Community
  static const String collectives = '/community/collectives';
  static String collectiveToggle(String id) =>
      '/community/collectives/$id/toggle';
  static const String collabs = '/community/collabs';
  static String collabToggle(String id) => '/community/collabs/$id/toggle';
  static const String supportStatus = '/community/support/status';
  static const String supportRegister = '/community/support/register';
  static const String deliveryPrefs = '/community/delivery';
  static String deliveryByOrder(String orderId) =>
      '/community/delivery/$orderId';
  
  // Agent
  static const String agentExecute = '/agent/execute';
  
  // Generous timeouts: Render free tier cold-starts can take ~50s
  // after idle, and AI replies (vision/chat) can take 30s+.
  static const Duration timeout = Duration(seconds: 90);
  static const Duration uploadTimeout = Duration(seconds: 120);
}
