import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/config/app_config.dart';
import 'tts_service.dart';

/// App-owned voice: speaks through OUR backend (/api/speech/speak),
/// so the app NEVER depends on the device's system TTS engine
/// (many BlueStacks images ship with none → total silence).
///
/// Strategy: backend audio first (same soft neural voice on every
/// device, strict to the selected app language), device TTS only
/// as an offline fallback.
class AppVoiceService {
  final TtsService _deviceTts;
  final AudioPlayer _player = AudioPlayer();
  bool _isSpeaking = false;
  String? _currentText;
  String _currentLang = 'en';

  bool get isSpeaking => _isSpeaking;

  AppVoiceService(this._deviceTts);

  Future<void> init() async {
    try {
      await _deviceTts.init();
    } catch (_) {}
  }

  Future<void> stop() async {
    _isSpeaking = false;
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _deviceTts.stop();
    } catch (_) {}
  }

  /// Speak [text] in the selected app [language].
  /// Set [preferBackend] false to force device voice (offline).
  Future<void> speak(String text,
      {String language = 'en', bool preferBackend = true}) async {
    final cleaned = _deviceTts.cleanForSpeech(text);
    if (cleaned.isEmpty) return;
    await stop();
    _currentText = cleaned;
    _currentLang = language;
    _isSpeaking = true;

    if (preferBackend) {
      try {
        final ok = await _speakViaBackend(cleaned, language)
            .timeout(const Duration(seconds: 45));
        if (ok) return; // _isSpeaking cleared when playback completes.
      } catch (e) {
        debugPrint('Backend voice failed, device fallback: $e');
      }
    }
    // Offline fallback: device engine (may be silent if none installed).
    try {
      await _deviceTts.speak(cleaned, language: language);
    } finally {
      _isSpeaking = false;
    }
  }

  /// POST text to backend, play returned mp3. Returns true if heard.
  Future<bool> _speakViaBackend(String text, String language) async {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 40),
      headers: {'Content-Type': 'application/json'},
    ));
    final token = AppConfig.authToken;
    final res = await dio.post<List<int>>(
      '/speech/speak',
      data: {'text': text, 'language': language},
      options: Options(
        responseType: ResponseType.bytes,
        headers: {if (token.isNotEmpty) 'Authorization': 'Bearer $token'},
      ),
    );
    final bytes = res.data;
    if (res.statusCode != 200 || bytes == null || bytes.isEmpty) return false;

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/app_voice_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);

    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) {
        done.complete();
        _isSpeaking = false;
      }
    }

    final sub = _player.onPlayerComplete.listen((_) => finish());
    try {
      await _player.play(DeviceFileSource(file.path));
      await done.future.timeout(const Duration(seconds: 60));
      return true;
    } catch (_) {
      return false;
    } finally {
      try {
        await sub.cancel();
      } catch (_) {}
      finish();
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  Future<void> replay() async {
    if (_currentText == null) return;
    await speak(_currentText!, language: _currentLang);
  }

  // Passthroughs for the softness settings UI (device fallback tuning).
  double get userRate => _deviceTts.userRate;
  double get userPitch => _deviceTts.userPitch;
  Future<void> setUserTuning({double? rate, double? pitch}) =>
      _deviceTts.setUserTuning(rate: rate, pitch: pitch);
  Future<bool> hasDeviceEngine() => _deviceTts.hasEngine();

  void dispose() {
    stop();
  }
}
