import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/theme.dart';
import 'core/config/routes.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'services/camera_service.dart';
import 'services/speech_service.dart';
import 'services/translation_service.dart';
import 'services/vision_service.dart';
import 'services/agent_service.dart';
import 'services/tts_service.dart';
import 'services/app_voice_service.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'services/market_service.dart';
import 'services/marketplace_service.dart';
import 'services/community_service.dart';
import 'services/settings_service.dart';
import 'providers/localization_provider.dart';
import 'agent/intent_router.dart';
import 'agent/action_executor.dart';
import 'agent/conversation_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('conversations');
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  await AppConfig.init();
  
  runApp(const ArtisanAiApp());
}

class ArtisanAiApp extends StatelessWidget {
  const ArtisanAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => MarketService()),
        ChangeNotifierProvider(create: (_) => MarketplaceService()),
        ChangeNotifierProvider(create: (_) => CommunityService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => ConversationManager()),
        ChangeNotifierProvider(create: (_) => ActionExecutor()),
        Provider(create: (_) => IntentRouter()),
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => AudioService()),
        Provider(create: (_) => CameraService()),
        Provider(create: (_) => SpeechService()),
        Provider(create: (_) => TranslationService()),
        Provider(create: (_) => VisionService()),
        Provider(create: (_) => AgentService()),
        Provider(create: (_) => TtsService()),
        // App-owned voice (backend audio first, device TTS fallback).
        // Must come after TtsService.
        Provider(create: (ctx) => AppVoiceService(ctx.read<TtsService>())),
      ],
      child: Consumer<LocalizationProvider>(
        builder: (context, locProvider, child) {
          return MaterialApp.router(
            title: 'Artisan AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
