import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/theme.dart';
import '../../core/config/app_config.dart';
import '../../services/agent_service.dart';
import '../../services/api_service.dart';
import '../../services/app_voice_service.dart';
import '../../services/localization_service.dart';
import '../../providers/localization_provider.dart';
import '../../agent/conversation_manager.dart';
import '../../models/agent_action.dart';
import '../../widgets/voice_indicator.dart';

typedef _WidgetsBinding = WidgetsFlutterBinding;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  AppVoiceService? _ttsService;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isRecorderReady = false;
  // Continuous conversation: auto-listen for the next command after responding.
  bool _autoListen = true;
  // Stage label under the spinner: 'processing' | 'status_sending' | 'status_thinking'.
  String _statusKey = 'processing';
  String? _transcript;
  AgentResponse? _lastResponse;
  late AnimationController _animationController;
  int _recordingDuration = 0;
  String? _recordingPath;
  final TextEditingController _textController = TextEditingController();
  bool _showTextInput = false;
  // Voice output on/off — strict to the selected app language.
  bool _voiceOutput = true;
  bool? _hasTtsEngine;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _initRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // App-owned voice: backend audio first, needs no system engine.
        _ttsService = context.read<AppVoiceService>();
        await _ttsService!.init();
        // Device-engine check is now informational only: backend voice
        // covers devices with no engine (needs internet). Offline users
        // without an engine stay silent → show the fix hint.
        try {
          final ok = await _ttsService!
              .hasDeviceEngine()
              .timeout(const Duration(seconds: 10));
          if (mounted) setState(() => _hasTtsEngine = ok);
        } catch (_) {
          if (mounted) setState(() => _hasTtsEngine = true);
        }
        // Warm the backend while the user reads the screen, so the first
        // command doesn't pay the Render cold-start wait.
        ApiService().warmup();
      }
    });
  }

  Future<void> _initRecorder() async {
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      if (mounted) {
        setState(() => _isRecorderReady = true);
      }
    } catch (e) {
      print('Failed to init recorder: $e');
      if (mounted) {
        setState(() {
          _isRecorderReady = false;
          _showTextInput = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _autoListen = false;
    _animationController.dispose();
    _recorder?.closeRecorder();
    _ttsService?.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_isRecorderReady || _recorder == null) {
      setState(() => _showTextInput = true);
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('mic_permission_denied')),
            action: SnackBarAction(
              label: context.t('use_text'),
              onPressed: () {
                setState(() => _showTextInput = true);
              },
            ),
          ),
        );
      }
      return;
    }

    try {
      // Stop any speaking reply before listening — no overlap.
      await _ttsService?.stop();
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/voice_command.wav';

      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );

      setState(() {
        _isRecording = true;
        _autoListen = true;
        _recordingDuration = 0;
        _transcript = null;
        _lastResponse = null;
      });

      _animationController.repeat();
      _startTimer();
    } catch (e) {
      print('Failed to start recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('recording_failed')),
            action: SnackBarAction(
              label: context.t('use_text'),
              onPressed: () {
                setState(() => _showTextInput = true);
              },
            ),
          ),
        );
      }
    }
  }

  void _startTimer() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() => _recordingDuration++);
        // Hands-free safety: cap one recording at 20s so uploads stay
        // small and a forgotten mic can't jam the conversation loop.
        if (_recordingDuration >= 20) {
          await _stopRecording();
        }
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder!.stopRecorder();
      _animationController.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null && path.isNotEmpty) {
        await _processAudio(path);
      } else {
        if (mounted) {
          setState(() {
            _showTextInput = true;
            _transcript = null;
            _lastResponse = AgentResponse(
              intent: 'NO_AUDIO',
              actions: [],
              confidence: 0,
              response: context.t('no_audio_captured'),
            );
          });
        }
      }
    } catch (e) {
      print('Failed to stop recording: $e');
      setState(() {
        _isRecording = false;
        _showTextInput = true;
        _lastResponse = AgentResponse(
          intent: 'RECORDING_ERROR',
          actions: [],
          confidence: 0,
          response: context.t('recording_failed_text'),
        );
      });
      _animationController.stop();
    }
  }

  Future<void> _processAudio(String audioPath) async {
    setState(() {
      _isProcessing = true;
      _statusKey = 'status_sending';
    });

    try {
      final agentService = context.read<AgentService>();
      final conversationManager = context.read<ConversationManager>();

      final response = await agentService.processVoice(
        audioPath: audioPath,
        currentScreen: conversationManager.currentScreen,
        conversationId: conversationManager.currentConversation?.id,
        userLanguage: _appLanguage,
      );

      if (response.success && response.data != null) {
        var agentResponse = response.data!;
        final heard = (agentResponse.originalText ?? '').trim();

        // Silence (empty transcript): stay quiet. No TTS, no auto-listen —
        // otherwise the mic re-arms itself forever on background noise.
        if (heard.isEmpty) {
          conversationManager.addAssistantMessage(
            context.t('no_audio_captured'),
            intent: 'NO_SPEECH',
          );
          if (mounted) {
            setState(() {
              _lastResponse = AgentResponse(
                intent: 'NO_SPEECH',
                actions: [],
                confidence: 0,
                response: context.t('no_audio_captured'),
              );
              _transcript = null;
            });
          }
          return;
        }

        // Backend didn't understand: fall through to local handling so
        // the reply (and voice) stays in the user's own language.
        if (agentResponse.intent == 'UNKNOWN') {
          final local = _processLocally(heard);
          agentResponse = AgentResponse(
            intent: local['intent'] as String,
            actions: (local['actions'] as List)
                .map((a) => AgentAction(
                      tool: a['tool'],
                      parameters:
                          Map<String, dynamic>.from(a['parameters']),
                    ))
                .toList(),
            confidence: 0.9,
            response: local['response'] as String,
            detailedResponse: local['response'] as String,
            originalText: agentResponse.originalText,
          );
        }

        conversationManager.addUserMessage(
          agentResponse.originalText ?? '',
          intent: agentResponse.intent,
        );

        conversationManager.addAssistantMessage(
          agentResponse.chatText,
          intent: agentResponse.intent,
          metadata: {'voice': agentResponse.response},
        );

        setState(() {
          _lastResponse = agentResponse;
          _transcript = agentResponse.originalText;
        });

        if (agentResponse.actions.isNotEmpty) {
          await _executeActions(agentResponse.actions);
        }

        // Clear "Processing..." BEFORE speaking: TTS can take a while
        // (or hang on some devices) and must never freeze the UI.
        if (mounted) setState(() => _isProcessing = false);

        await _speakResponse(
          agentResponse.response,
          language: agentResponse.detectedLanguage,
        );
        // Only a understood command re-arms the mic. A miss ends the
        // turn with the mic idle — the user taps to retry.
        if (agentResponse.intent != 'UNKNOWN') {
          await _listenNext();
        }
      } else {
        // STT failed - fall back to text input
        setState(() {
          _showTextInput = true;
          _transcript = null;
          _lastResponse = AgentResponse(
            intent: 'STT_FAILED',
            actions: [],
            confidence: 0,
            response: context.t('stt_failed'),
          );
        });
      }
    } catch (e) {
      // Backend error - fall back to text input with local processing
      setState(() {
        _showTextInput = true;
        _transcript = null;
        _lastResponse = AgentResponse(
          intent: 'CONNECTION_ERROR',
          actions: [],
          confidence: 0,
          response: context.t('connection_error'),
        );
      });
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _processText(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusKey = 'status_thinking';
    });

    try {
      final conversationManager = context.read<ConversationManager>();

      conversationManager.addUserMessage(text);

      // Try backend first, fallback to local processing.
      // A backend UNKNOWN is treated as "not understood" so the local
      // reply stays in the user's own language.
      var response = await _tryBackend(text, conversationManager);
      if (response != null && response.intent == 'UNKNOWN') {
        response = null;
      }

      if (response != null) {
        final agentResponse = response;

        conversationManager.addAssistantMessage(
          agentResponse.chatText,
          intent: agentResponse.intent,
          metadata: {'voice': agentResponse.response},
        );

        setState(() {
          _lastResponse = agentResponse;
          _transcript = text;
        });

        if (agentResponse.actions.isNotEmpty) {
          await _executeActions(agentResponse.actions);
        }

        if (mounted) setState(() => _isProcessing = false);

        // Speak the AI response, then auto-listen for the next command.
        await _speakResponse(
          agentResponse.response,
          language: agentResponse.detectedLanguage,
        );
        await _listenNext();
      } else {
        // Local fallback
        final localResponse = _processLocally(text);

        conversationManager.addAssistantMessage(
          localResponse['response'] as String,
          intent: localResponse['intent'] as String,
          metadata: {'voice': localResponse['response'] as String},
        );

        setState(() {
          _lastResponse = AgentResponse(
            intent: localResponse['intent'] as String,
            actions: (localResponse['actions'] as List).map((a) => AgentAction(
              tool: a['tool'],
              parameters: Map<String, dynamic>.from(a['parameters']),
            )).toList(),
            confidence: 0.9,
            response: localResponse['response'] as String,
            detailedResponse: localResponse['response'] as String,
          );
          _transcript = text;
        });

        final actions = localResponse['actions'] as List;
        if (actions.isNotEmpty) {
          await _executeActions(
            (localResponse['actions'] as List).map((a) => AgentAction(
              tool: a['tool'],
              parameters: Map<String, dynamic>.from(a['parameters']),
            )).toList(),
          );
        }

        if (mounted) setState(() => _isProcessing = false);

        // Speak the local response, then auto-listen for the next command.
        await _speakResponse(localResponse['response'] as String);
        await _listenNext();
      }
    } catch (e) {
      // Even on error, try local fallback
      final localResponse = _processLocally(text);
      final conversationManager = context.read<ConversationManager>();

      conversationManager.addAssistantMessage(
        localResponse['response'] as String,
        intent: localResponse['intent'] as String,
        metadata: {'voice': localResponse['response'] as String},
      );

      setState(() {
        _lastResponse = AgentResponse(
          intent: localResponse['intent'] as String,
          actions: [],
          confidence: 0.9,
          response: localResponse['response'] as String,
          detailedResponse: localResponse['response'] as String,
        );
        _transcript = text;
      });

      // Speak the local response
      await _speakResponse(localResponse['response'] as String);
    }

    _textController.clear();
    setState(() => _isProcessing = false);
  }

  Future<AgentResponse?> _tryBackend(String text, ConversationManager conversationManager) async {
    try {
      if (!AppConfig.isAuthenticated) return null;
      
      final agentService = context.read<AgentService>();
      final response = await agentService.processText(
        text: text,
        currentScreen: conversationManager.currentScreen,
        conversationId: conversationManager.currentConversation?.id,
        userLanguage: _appLanguage,
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      // Backend not available, use local
    }
    return null;
  }

  Map<String, dynamic> _processLocally(String text) {
    final lower = text.toLowerCase().trim();

    // Navigation intents
    if (lower.contains('home') || lower.contains('main')) {
      return {
        'intent': 'NAVIGATE_HOME',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'home'}}],
        'response': context.t('opening_home'),
      };
    }
    // Community + welfare intents (before generic product/order matches)
    if (lower.contains('collective')) {
      return {
        'intent': 'COLLECTIVE_ORDERS',
        'actions': [
          {'tool': 'navigate', 'parameters': {'target': 'collective-orders'}}
        ],
        'response': context.t('opening_collective'),
      };
    }
    if (lower.contains('second hand') ||
        lower.contains('2nd hand') ||
        lower.contains('pre-owned') ||
        lower.contains('used item')) {
      return {
        'intent': 'SECOND_HAND',
        'actions': [
          {'tool': 'navigate', 'parameters': {'target': 'second-hand'}}
        ],
        'response': context.t('opening_secondhand'),
      };
    }
    if (lower.contains('collaborat')) {
      return {
        'intent': 'COLLABORATION',
        'actions': [
          {'tool': 'navigate', 'parameters': {'target': 'collaboration'}}
        ],
        'response': context.t('opening_collab'),
      };
    }
    if (lower.contains('budget') ||
        lower.contains('cheap') ||
        lower.contains('affordable') ||
        lower.contains('poor buyer')) {
      return {
        'intent': 'BUDGET_BAZAAR',
        'actions': [
          {'tool': 'navigate', 'parameters': {'target': 'budget-bazaar'}}
        ],
        'response': context.t('opening_budget'),
      };
    }
    if (lower.contains('poor seller') ||
        lower.contains('seller support') ||
        lower.contains('support program')) {
      return {
        'intent': 'SELLER_SUPPORT',
        'actions': [
          {'tool': 'navigate', 'parameters': {'target': 'seller-support'}}
        ],
        'response': context.t('opening_support'),
      };
    }
    if (lower.contains('community')) {
      return {
        'intent': 'COMMUNITY',
        'actions': [
          {'tool': 'navigate', 'parameters': {'target': 'community'}}
        ],
        'response': context.t('opening_community'),
      };
    }
    if (lower.contains('product') || lower.contains('catalog') || lower.contains('item')) {
      return {
        'intent': 'NAVIGATE_PRODUCTS',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'products'}}],
        'response': context.t('opening_products'),
      };
    }
    if (lower.contains('order')) {
      return {
        'intent': 'NAVIGATE_ORDERS',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'orders'}}],
        'response': context.t('opening_orders'),
      };
    }
    if (lower.contains('market') || lower.contains('trend') || lower.contains('demand')) {
      return {
        'intent': 'NAVIGATE_MARKET',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'market'}}],
        'response': context.t('opening_market'),
      };
    }
    if (lower.contains('profile') || lower.contains('account') || lower.contains('setting')) {
      return {
        'intent': 'NAVIGATE_PROFILE',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'profile'}}],
        'response': context.t('opening_profile'),
      };
    }
    if (lower.contains('scan') || lower.contains('camera') || lower.contains('photo') || lower.contains('picture')) {
      return {
        'intent': 'SCAN_PRODUCT',
        'actions': [{'tool': 'open_scanner', 'parameters': {}}],
        'response': context.t('opening_scanner'),
      };
    }
    if (lower.contains('price') || lower.contains('how much') || lower.contains('charge') || lower.contains('cost')) {
      return {
        'intent': 'SUGGEST_PRICE',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'pricing'}}],
        'response': context.t('opening_pricing'),
      };
    }
    if (lower.contains('add') && lower.contains('product')) {
      return {
        'intent': 'CREATE_PRODUCT',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'add-product'}}],
        'response': context.t('opening_add_product'),
      };
    }
    if (lower.contains('new') && lower.contains('order')) {
      return {
        'intent': 'NEW_ORDERS',
        'actions': [{'tool': 'navigate', 'parameters': {'target': 'orders'}}],
        'response': context.t('checking_orders'),
      };
    }
    if (lower.contains('help') || lower.contains('what can you do') || lower.contains('command')) {
      return {
        'intent': 'HELP',
        'actions': [],
        'response': context.t('help_text'),
      };
    }
    // Small talk: always answer, never dead-end.
    if (lower.contains('your name') || lower.contains('who are you')) {
      return {
        'intent': 'SELF_NAME',
        'actions': [],
        'response':
            'Meet Ai Sathi — the shop helper. Ask to show products, scan something new, or check orders.',
      };
    }
    if (lower.contains('hello') ||
        lower.contains('hey ') ||
        lower.contains('namaste') ||
        lower.contains('good morning') ||
        lower.contains('good afternoon')) {
      return {
        'intent': 'GREETING',
        'actions': [],
        'response':
            'Hello! What shall we do — show products, scan, or check orders?',
      };
    }
    if (lower.contains('thank')) {
      return {
        'intent': 'THANKS',
        'actions': [],
        'response': 'Anytime! Happy to help with the shop.',
      };
    }
    if (lower.contains('bye') || lower.contains('goodbye')) {
      return {
        'intent': 'BYE',
        'actions': [],
        'response': 'Bye! The shop helper stays right here.',
      };
    }
    if (lower.contains('back')) {
      return {
        'intent': 'NAVIGATE_BACK',
        'actions': [{'tool': 'navigate_back', 'parameters': {}}],
        'response': context.t('going_back'),
      };
    }

    // Default: generic but helpful — echo what was heard, explain why it
    // could not be processed, and offer what works. Human tone, and the
    // wording avoids the isolated "Sorry, I" the device voice mangles.
    var heard = text.trim().isEmpty ? '...' : text.trim();
    if (heard.length > 80) heard = '${heard.substring(0, 80)}…';
    return {
      'intent': 'UNKNOWN',
      'actions': [],
      'response':
          'Hmm, $heard — no matching command, so nothing was done. Try “show my products”, “scan product”, or “check new orders”.',
    };
  }

  Future<void> _executeActions(List<AgentAction> actions) async {
    for (final action in actions) {
      if (action.tool == 'navigate') {
        final target = action.parameters['target'] as String?;
        if (target != null && mounted) {
          context.go('/$target');
        }
        break;
      } else if (action.tool == 'open_scanner') {
        if (mounted) {
          context.push('/scanner');
        }
        break;
      } else if (action.tool == 'navigate_back') {
        if (mounted && context.canPop()) {
          context.pop();
        }
        break;
        // Data tools have no on-device handler: take the user to the
        // screen that displays that data instead of doing nothing.
      } else if (action.tool == 'get_market_trends' ||
          action.tool == 'get_market_analysis') {
        if (mounted) {
          context.go('/market');
        }
        break;
      } else if (action.tool == 'get_new_orders') {
        if (mounted) {
          context.go('/orders');
        }
        break;
      } else if (action.tool == 'suggest_price') {
        if (mounted) {
          context.go('/pricing');
        }
        break;
      } else if (action.tool == 'get_product_performance') {
        if (mounted) {
          context.go('/products');
        }
        break;
      }
    }
  }

  /// Current app language, read fresh every time (never cached).
  String get _appLanguage {
    try {
      return context.read<LocalizationProvider>().currentLanguage;
    } catch (_) {
      return 'en';
    }
  }

  /// Hands-free loop: after responding, automatically start listening
  /// for the next command (voice mode only, never on errors).
  Future<void> _listenNext() async {
    if (!mounted || !_autoListen || _showTextInput) return;
    if (_isRecording || _isProcessing) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || !_autoListen || _showTextInput) return;
    if (_isRecording || _isProcessing) return;
    await _startRecording();
  }

  /// Strips markdown/lists so TTS speaks clean sentences instead of
  /// "star star Android star star". Shown chat text is left untouched.
  /// (TtsService.cleanForSpeech does a deeper pass; this is a fast pre-clean.)
  String _cleanForSpeech(String text) {
    var out = text
        .replaceAll(RegExp(r'https?://\S+'), ' ')
        .replaceAll(RegExp(r'\*\*|__|`|#{1,6}\s?'), '')
        .replaceAll(RegExp(r'^\s*[-*•\d]+[.)]\s*', multiLine: true), '')
        .replaceAll(
            RegExp(
                r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}]',
                unicode: true),
            ' ')
        .replaceAll(RegExp(r'\n{2,}'), '. ')
        .trim();
    return out.isEmpty ? text : out;
  }

  Future<void> _speakResponse(String text, {String? language}) async {
    // STRICT: always speak in the user's selected app language.
    // Backend STT detection (e.g. 'hi' when user picked 'en') must NOT
    // switch the voice — that was the main "wrong language" complaint.
    // `language` is accepted for API compatibility but ignored on purpose.
    if (!_voiceOutput) return;
    final lang = _appLanguage;
    if (_ttsService != null && mounted) {
      try {
        await _ttsService!
            .speak(_cleanForSpeech(text), language: lang)
            .timeout(const Duration(seconds: 30));
      } catch (_) {
        // TTS must never break the conversation loop.
      }
    }
  }

    /// Softness controls: slower + slightly higher pitch reads as soft.
  /// Saved on device, applied instantly + testable.
  Future<void> _showVoiceSettings() async {
    final tts = _ttsService;
    if (tts == null) return;
    var rate = tts.userRate;
    var pitch = tts.userPitch;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Voice softness',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Slower + softer = calm voice. Test and keep.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              Text('Speed: ${rate.toStringAsFixed(2)} (slower ← → faster)'),
              Slider(
                value: rate,
                min: 0.3,
                max: 1.0,
                divisions: 14,
                onChanged: (v) => setSheet(() => rate = v),
              ),
              Text('Softness: ${pitch.toStringAsFixed(2)} (deep ← → soft)'),
              Slider(
                value: pitch,
                min: 0.7,
                max: 1.4,
                divisions: 14,
                onChanged: (v) => setSheet(() => pitch = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        tts.speak('Hello! I am your soft voice helper.',
                            language: _appLanguage);
                      },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Test voice'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await tts.setUserTuning(rate: rate, pitch: pitch);
                        if (mounted) Navigator.of(context).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                                content: Text('Voice saved ✓'),
                                duration: Duration(seconds: 1)));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100)),
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Voice plays as app audio (needs internet) — no system engine needed. Sliders tune the offline device-voice backup.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('voice_assistant')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showVoiceSettings,
            tooltip: 'Voice softness',
          ),
          IconButton(
            icon: Icon(
                _voiceOutput ? Icons.volume_up : Icons.volume_off),
            onPressed: () async {
              setState(() => _voiceOutput = !_voiceOutput);
              if (!_voiceOutput) await _ttsService?.stop();
              if (mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(_voiceOutput
                        ? 'Voice output ON (${_appLanguage})'
                        : 'Voice output OFF — text only'),
                    duration: const Duration(seconds: 1),
                  ));
              }
            },
            tooltip: 'Voice output',
          ),
          IconButton(
            icon: Icon(_showTextInput ? Icons.mic : Icons.keyboard),
            onPressed: () {
              setState(() => _showTextInput = !_showTextInput);
            },
            tooltip: _showTextInput ? context.t('switch_to_voice') : context.t('switch_to_text'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_hasTtsEngine == false)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('App voice enabled',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'This device has no system voice engine, so replies play as app voice over the internet — no install needed.\n'
                    'Offline? Install “Google Text-to-Speech” from Play Store for device voice backup.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildChatArea(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    final conversationManager = context.watch<ConversationManager>();
    final messages = conversationManager.recentMessages;

    final hasMessages = messages.isNotEmpty || _lastResponse != null;

    if (!hasMessages) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 80,
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.t('speak_or_type'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('speak_example'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...messages.map((message) {
          final isUser = message.role == 'user';
          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUser)
                    Text(
                      message.content,
                      style: const TextStyle(color: Colors.white),
                    )
                  else
                    MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.45),
                        listBullet:
                            const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  if (!isUser)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => _speakResponse(
                          (message.metadata?['voice'] as String?) ??
                              message.content,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.replay,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        if (_lastResponse != null && messages.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: MarkdownBody(
                data: _lastResponse!.chatText,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.45),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(context.t(_statusKey)),
                ],
              ),
            ),
          if (_transcript != null && !_isProcessing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _transcript!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (_showTextInput)
            _buildTextInput()
          else
            _buildVoiceInput(),
          const SizedBox(height: 8),
          Text(
            _showTextInput
                ? context.t('type_command_lang')
                : _isRecorderReady
                    ? context.t('tap_speak')
                    : context.t('mic_unavailable'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _isProcessing ? null : _toggleRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : AppTheme.primaryColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: _isRecording ? 5 : 0,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: context.t('type_command'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (value) => _processText(value),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isProcessing
              ? null
              : () => _processText(_textController.text),
          icon: const Icon(Icons.send),
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }
}