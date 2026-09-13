import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _TutorialStep {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String? ctaLabel;
  final String? route;
  const _TutorialStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.route,
  });
}

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = [
    _TutorialStep(
      icon: Icons.waving_hand,
      color: Color(0xFFE65100),
      title: 'Welcome to AI Saathi!',
      body:
          'Your voice-first business helper. Speak instead of typing — '
          'in your own language.\n\nSwipe to learn, or tap Skip to start.',
    ),
    _TutorialStep(
      icon: Icons.mic,
      color: Color(0xFFE65100),
      title: '1. Voice Assistant',
      body:
          'Tap the orange mic in the bottom bar.\n'
          '• Tap mic → speak (stops by itself)\n'
          '• Or tap keyboard → type\n\n'
          'Try: “Show new orders”, “Scan product”, “Suggest price”.',
      ctaLabel: 'Open Voice Assistant',
      route: '/voice-assistant',
    ),
    _TutorialStep(
      icon: Icons.camera_alt,
      color: Color(0xFF1B5E20),
      title: '2. Scan a product',
      body:
          'Home → Scan Product.\n'
          'Capture or pick a photo → AI fills name, material, '
          'description → Add to Catalog → Save.\n\nGood light = best results.',
      ctaLabel: 'Open Scanner',
      route: '/scanner',
    ),
    _TutorialStep(
      icon: Icons.inventory_2,
      color: Color(0xFF1565C0),
      title: '3. Products & Pricing',
      body:
          'Products tab = your catalog.\n'
          'Tap a product → Get Price for AI suggestion with range + reasoning.\n'
          '+ button adds a product manually.',
      ctaLabel: 'Open Products',
      route: '/products',
    ),
    _TutorialStep(
      icon: Icons.shopping_bag,
      color: Color(0xFF6A1B9A),
      title: '4. Orders & Delivery',
      body:
          'Orders tab: New / Pending / All.\n'
          'Accept or Reject new orders.\n'
          'Each order has Easy Delivery: Pickup (free), Standard (₹49), '
          'Express (₹99) + open-box switch. Saves instantly.',
      ctaLabel: 'Open Orders',
      route: '/orders',
    ),
    _TutorialStep(
      icon: Icons.trending_up,
      color: Color(0xFF00838F),
      title: '5. Market trends',
      body:
          'Market tab shows what sells now: demand badge, avg price, '
          'listings. Pull down to refresh.\n\nCheck before you price!',
      ctaLabel: 'Open Market',
      route: '/market',
    ),
    _TutorialStep(
      icon: Icons.groups,
      color: Color(0xFF2E7D32),
      title: '6. Community',
      body:
          'Community tab (between Market and Profile):\n'
          '• Collective Orders → Join bulk deals\n'
          '• Second Hand → Buy / Contact / Sell item\n'
          '• Collaboration → Interested / Create post\n'
          '• Seller Support → Apply for 6 schemes\n'
          '• Easy Delivery hub\n\nButtons turn green instantly.',
      ctaLabel: 'Open Community',
      route: '/community',
    ),
    _TutorialStep(
      icon: Icons.person,
      color: Color(0xFF5D4037),
      title: '7. Profile & Language',
      body:
          'Profile tab: change language (10 options), notifications, '
          'shop + payment settings, Help & Support.\n\n'
          'Stuck? Profile → Help & Support → App tutorial (this guide).',
      ctaLabel: 'Open Profile',
      route: '/profile',
    ),
    _TutorialStep(
      icon: Icons.rocket_launch,
      color: Color(0xFFE65100),
      title: 'You’re ready!',
      body:
          'Quick start:\n'
          '1. Scan your first product\n'
          '2. Get its AI price\n'
          '3. Join one collective order\n\n'
          'Tip: Demo Mode (login screen) lets you practice offline.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i < 0 || i >= _steps.length) return;
    _controller.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Tutorial'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (!last)
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              child: const Text('Skip'),
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_page + 1) / _steps.length,
            minHeight: 4,
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _steps.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final s = _steps[i];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(s.icon, size: 56, color: s.color),
                      ),
                      const SizedBox(height: 24),
                      Text('Step ${i + 1} of ${_steps.length}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(s.body,
                          style: const TextStyle(fontSize: 15, height: 1.5)),
                      if (s.route != null) ...[
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () => context.push(s.route!),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(s.ctaLabel ?? 'Try it'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                if (_page > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _go(_page - 1),
                      child: const Text('Back'),
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: 12),
                Row(
                  children: List.generate(
                    _steps.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: _page == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _page == i
                            ? const Color(0xFFE65100)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (last) {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      } else {
                        _go(_page + 1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                    ),
                    child: Text(last ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
