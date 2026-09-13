import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/localization_service.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/language_selection/language_selection_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/voice_assistant/voice_assistant_screen.dart';
import '../../screens/scanner/scanner_screen.dart';
import '../../screens/image_studio/image_studio_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/product_details/product_details_screen.dart';
import '../../screens/add_product/add_product_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/order_details/order_details_screen.dart';
import '../../screens/market/market_screen.dart';
import '../../screens/pricing/pricing_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/community/community_hub_screen.dart';
import '../../screens/community/collective_orders_screen.dart';
import '../../screens/community/second_hand_screen.dart';
import '../../screens/community/collaboration_screen.dart';
import '../../screens/community/budget_bazaar_screen.dart';
import '../../screens/community/seller_support_screen.dart';
import '../../screens/community/easy_delivery_screen.dart';
import '../../screens/tutorial/tutorial_screen.dart';
import '../../screens/buyer/buyer_home_screen.dart';
import '../../screens/buyer/buyer_product_screen.dart';
import '../../screens/buyer/buyer_orders_screen.dart';
import '../../screens/settings/language_settings_screen.dart';
import '../../screens/settings/notification_settings_screen.dart';
import '../../screens/settings/shop_settings_screen.dart';
import '../../screens/settings/payment_settings_screen.dart';
import '../../screens/settings/help_support_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/language-selection',
    routes: [
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/market',
            builder: (context, state) => const MarketScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityHubScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Buyer flow: separate bottom nav (Shop / My Orders / Profile).
      ShellRoute(
        builder: (context, state, child) => BuyerScaffold(child: child),
        routes: [
          GoRoute(
            path: '/buyer-home',
            builder: (context, state) => const BuyerHomeScreen(),
          ),
          GoRoute(
            path: '/buyer-orders',
            builder: (context, state) => const BuyerOrdersScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/buyer-product/:id',
        builder: (context, state) => BuyerProductScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/voice-assistant',
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/image-studio',
        builder: (context, state) => const ImageStudioScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailsScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/add-product',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) => OrderDetailsScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/easy-delivery',
        builder: (context, state) => const EasyDeliveryScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/collective-orders',
        builder: (context, state) => const CollectiveOrdersScreen(),
      ),
      GoRoute(
        path: '/second-hand',
        builder: (context, state) => const SecondHandScreen(),
      ),
      GoRoute(
        path: '/collaboration',
        builder: (context, state) => const CollaborationScreen(),
      ),
      GoRoute(
        path: '/budget-bazaar',
        builder: (context, state) => const BudgetBazaarScreen(),
      ),
      GoRoute(
        path: '/seller-support',
        builder: (context, state) => const SellerSupportScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/shop',
        builder: (context, state) => const ShopSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/payment',
        builder: (context, state) => const PaymentSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
    ],
  );
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final index = _calculateIndex(context);
    return Scaffold(
      body: child,
      // Center voice assistant floating above the bar.
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE65100).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/voice-assistant'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: context.t('voice_assistant'),
          child: const Icon(Icons.mic, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(context, 0, index, Icons.home_outlined, Icons.home,
                  context.t('nav_home')),
              _navItem(context, 1, index, Icons.inventory_2_outlined,
                  Icons.inventory_2, context.t('nav_products')),
              _navItem(context, 2, index, Icons.shopping_bag_outlined,
                  Icons.shopping_bag, context.t('nav_orders')),
              const Spacer(flex: 2),
              _navItem(context, 3, index, Icons.trending_up_outlined,
                  Icons.trending_up, context.t('nav_market')),
              _navItem(context, 4, index, Icons.groups_outlined,
                  Icons.groups, context.t('nav_community')),
              _navItem(context, 5, index, Icons.person_outlined,
                  Icons.person, context.t('nav_profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int itemIndex, int currentIndex,
      IconData icon, IconData activeIcon, String label) {
    final selected = itemIndex == currentIndex;
    final color =
        selected ? const Color(0xFFE65100) : Colors.grey.shade600;
    return Expanded(
      child: InkWell(
        onTap: () => _onTap(context, itemIndex),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/orders') ||
        location.startsWith('/order/')) return 2;
    if (location.startsWith('/market')) return 3;
    if (location.startsWith('/community') ||
        location.startsWith('/collective-orders') ||
        location.startsWith('/second-hand') ||
        location.startsWith('/collaboration') ||
        location.startsWith('/budget-bazaar') ||
        location.startsWith('/seller-support') ||
        location.startsWith('/easy-delivery')) return 4;
    if (location.startsWith('/profile') ||
        location.startsWith('/settings')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/products');
      case 2:
        context.go('/orders');
      case 3:
        context.go('/market');
      case 4:
        context.go('/community');
      case 5:
        context.go('/profile');
    }
  }
}
