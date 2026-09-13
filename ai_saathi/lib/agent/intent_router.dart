import '../models/agent_action.dart';
import '../core/constants/app_constants.dart';

class IntentRouter {
  static const Map<String, List<String>> _intentPatterns = {
    'NAVIGATE_HOME': ['home', 'go home', 'main screen', 'dashboard'],
    'NAVIGATE_PRODUCTS': ['products', 'catalog', 'my products', 'show products'],
    'NAVIGATE_ORDERS': ['orders', 'my orders', 'show orders'],
    'NAVIGATE_MARKET': ['market', 'market analysis', 'trends'],
    'NAVIGATE_PROFILE': ['profile', 'my profile', 'account'],
    'NAVIGATE_SCANNER': ['scanner', 'scan', 'camera', 'open scanner'],
    'NAVIGATE_BACK': ['back', 'go back', 'previous screen'],
    
    'SCAN_PRODUCT': ['scan this', 'scan product', 'scan it', 'take a picture'],
    'IDENTIFY_PRODUCT': ['what is this', 'identify', 'what product is this'],
    'ANALYZE_PRODUCT': ['analyze', 'analysis', 'analyze product'],
    'VIEW_PRODUCTS': ['show products', 'my products', 'catalog', 'view products'],
    'SEARCH_PRODUCTS': ['find', 'search', 'look for'],
    'VIEW_PRODUCT_DETAILS': ['open product', 'product details', 'show product'],
    'CREATE_PRODUCT': ['add product', 'create product', 'new product', 'add to catalog'],
    'EDIT_PRODUCT': ['edit product', 'update product', 'change product'],
    'DELETE_PRODUCT': ['delete product', 'remove product'],
    'PUBLISH_PRODUCT': ['publish', 'list product', 'make available'],
    
    'CAPTURE_IMAGE': ['capture', 'take photo', 'take picture'],
    'ENHANCE_IMAGE': ['enhance', 'improve image', 'better quality'],
    'REMOVE_BACKGROUND': ['remove background', 'clear background'],
    'SUMMARIZE_IMAGE': ['describe', 'what is in this image', 'tell me about this'],
    'ANALYZE_IMAGE': ['analyze image', 'analyze photo'],
    
    'MARKET_ANALYSIS': ['market analysis', 'market demand', 'market info'],
    'MARKET_TRENDS': ['trends', 'what is trending', 'trending products'],
    'PRODUCT_DEMAND': ['demand', 'is this in demand', 'will this sell'],
    'PRODUCT_PERFORMANCE': ['performance', 'how are my products doing', 'best selling'],
    'TRENDING_PRODUCTS': ['trending', 'popular products'],
    'PRODUCT_RECOMMENDATION': ['recommend', 'what should i make', 'suggestions'],
    
    'SUGGEST_PRICE': ['price', 'how much', 'charge', 'pricing', 'cost'],
    'PRICE_ANALYSIS': ['price analysis', 'price comparison'],
    'COMPARE_PRICE': ['compare price', 'competitor price'],
    'RAW_MATERIAL_COST_ANALYSIS': ['raw material', 'material cost', 'cost analysis'],
    
    'VIEW_ORDERS': ['show orders', 'my orders', 'orders'],
    'NEW_ORDERS': ['new orders', 'any new orders', 'recent orders'],
    'PENDING_ORDERS': ['pending orders', 'pending'],
    'ORDER_DETAILS': ['open order', 'order details', 'show order'],
    'UPDATE_ORDER': ['update order', 'change order'],
    'CANCEL_ORDER': ['cancel order', 'cancel order'],
    'ACCEPT_ORDER': ['accept order', 'confirm order'],
    'REJECT_ORDER': ['reject order', 'decline order'],
    
    'HELP': ['help', 'what can you do', 'commands'],
  };

  AgentResponse route(String text, {
    String? currentScreen,
    Map<String, dynamic>? context,
  }) {
    final normalized = text.toLowerCase().trim();
    
    String? bestIntent;
    double bestScore = 0;
    
    for (final entry in _intentPatterns.entries) {
      for (final pattern in entry.value) {
        if (normalized.contains(pattern)) {
          final score = pattern.length / normalized.length;
          if (score > bestScore) {
            bestScore = score;
            bestIntent = entry.key;
          }
        }
      }
    }
    
    if (bestIntent == null || bestScore < AppConstants.clarifyConfidenceThreshold) {
      return AgentResponse(
        intent: 'UNKNOWN',
        actions: [],
        confidence: 0,
        response: 'I am not sure what you want. Can you tell me more?',
      );
    }
    
    final actions = _buildActions(bestIntent, context);
    final confidence = bestScore.clamp(0.0, 1.0);
    
    return AgentResponse(
      intent: bestIntent,
      actions: actions,
      confidence: confidence,
      requiresConfirmation: _requiresConfirmation(bestIntent),
      response: _generateResponse(bestIntent, context),
      originalText: text,
      normalizedText: normalized,
    );
  }

  List<AgentAction> _buildActions(String intent, Map<String, dynamic>? context) {
    switch (intent) {
      case 'NAVIGATE_HOME':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'home'})];
      case 'NAVIGATE_PRODUCTS':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'products'})];
      case 'NAVIGATE_ORDERS':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'orders'})];
      case 'NAVIGATE_MARKET':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'market'})];
      case 'NAVIGATE_PROFILE':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'profile'})];
      case 'NAVIGATE_SCANNER':
        return [AgentAction(tool: 'open_scanner', parameters: {})];
      case 'NAVIGATE_BACK':
        return [AgentAction(tool: 'navigate_back', parameters: {})];
      
      case 'SCAN_PRODUCT':
        return [
          AgentAction(tool: 'open_scanner', parameters: {}),
          AgentAction(tool: 'capture_image', parameters: {}),
          AgentAction(tool: 'analyze_image', parameters: {'purpose': 'product_analysis'}),
        ];
      
      case 'IDENTIFY_PRODUCT':
        return [
          AgentAction(tool: 'analyze_image', parameters: {'purpose': 'identify'}),
        ];
      
      case 'CREATE_PRODUCT':
        return [
          AgentAction(tool: 'open_scanner', parameters: {}),
          AgentAction(tool: 'capture_image', parameters: {}),
          AgentAction(tool: 'analyze_image', parameters: {'purpose': 'product_creation'}),
          AgentAction(tool: 'generate_product_listing', parameters: {}),
          AgentAction(
            tool: 'confirm_action',
            parameters: {'message': 'Create this product?'},
            requiresConfirmation: true,
          ),
          AgentAction(tool: 'create_product', parameters: {}),
        ];
      
      case 'VIEW_PRODUCTS':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'products'})];
      
      case 'SEARCH_PRODUCTS':
        final query = context?['query'] ?? '';
        return [AgentAction(tool: 'search_products', parameters: {'query': query})];
      
      case 'VIEW_PRODUCT_DETAILS':
        final productId = context?['product_id'];
        return [AgentAction(tool: 'get_product_details', parameters: {'product_id': productId})];
      
      case 'EDIT_PRODUCT':
        final productId = context?['product_id'];
        return [AgentAction(tool: 'update_product', parameters: {'product_id': productId})];
      
      case 'DELETE_PRODUCT':
        final productId = context?['product_id'];
        return [
          AgentAction(
            tool: 'confirm_action',
            parameters: {'message': 'Delete this product?'},
            requiresConfirmation: true,
          ),
          AgentAction(tool: 'delete_product', parameters: {'product_id': productId}),
        ];
      
      case 'VIEW_ORDERS':
        return [AgentAction(tool: 'navigate', parameters: {'target': 'orders'})];
      
      case 'NEW_ORDERS':
        return [AgentAction(tool: 'get_new_orders', parameters: {})];
      
      case 'SUGGEST_PRICE':
        final productId = context?['product_id'];
        return [AgentAction(tool: 'suggest_price', parameters: {'product_id': productId})];
      
      case 'MARKET_ANALYSIS':
        final category = context?['category'];
        return [AgentAction(tool: 'get_market_analysis', parameters: {'category': category})];
      
      case 'MARKET_TRENDS':
        return [AgentAction(tool: 'get_market_trends', parameters: {})];
      
      case 'PRODUCT_PERFORMANCE':
        return [AgentAction(tool: 'get_product_performance', parameters: {})];
      
      case 'HELP':
        return [AgentAction(tool: 'show_help', parameters: {})];
      
      default:
        return [];
    }
  }

  bool _requiresConfirmation(String intent) {
    return [
      'DELETE_PRODUCT',
      'CANCEL_ORDER',
      'ACCEPT_ORDER',
      'REJECT_ORDER',
      'PUBLISH_PRODUCT',
    ].contains(intent);
  }

  String _generateResponse(String intent, Map<String, dynamic>? context) {
    switch (intent) {
      case 'NAVIGATE_HOME':
        return 'Opening home screen.';
      case 'NAVIGATE_PRODUCTS':
        return 'Opening your products.';
      case 'NAVIGATE_ORDERS':
        return 'Opening your orders.';
      case 'NAVIGATE_MARKET':
        return 'Opening market analysis.';
      case 'NAVIGATE_PROFILE':
        return 'Opening your profile.';
      case 'NAVIGATE_SCANNER':
        return 'Opening scanner. Point your camera at a product.';
      case 'NAVIGATE_BACK':
        return 'Going back.';
      case 'SCAN_PRODUCT':
        return 'Opening scanner to scan your product.';
      case 'IDENTIFY_PRODUCT':
        return 'Analyzing the product...';
      case 'CREATE_PRODUCT':
        return 'Let me help you create a new product. First, take a photo.';
      case 'VIEW_PRODUCTS':
        return 'Here are your products.';
      case 'SEARCH_PRODUCTS':
        return 'Searching for products...';
      case 'VIEW_PRODUCT_DETAILS':
        return 'Opening product details.';
      case 'EDIT_PRODUCT':
        return 'Opening product editor.';
      case 'DELETE_PRODUCT':
        return 'Are you sure you want to delete this product?';
      case 'VIEW_ORDERS':
        return 'Here are your orders.';
      case 'NEW_ORDERS':
        return 'Checking for new orders...';
      case 'SUGGEST_PRICE':
        return 'Let me suggest a price for this product.';
      case 'MARKET_ANALYSIS':
        return 'Analyzing market data...';
      case 'MARKET_TRENDS':
        return 'Here are the current market trends.';
      case 'PRODUCT_PERFORMANCE':
        return 'Showing your product performance.';
      case 'HELP':
        return 'I can help you with: scanning products, managing your catalog, checking orders, market analysis, and pricing. What would you like to do?';
      default:
        return 'I am not sure what you want. Can you tell me more?';
    }
  }
}
