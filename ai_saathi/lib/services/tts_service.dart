import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Soft, natural-sounding TTS locked to the user's selected app language.
///
/// - Warm defaults (rate/pitch/volume) instead of flat robotic output.
/// - Picks the most natural voice available for each locale (Google
///   Neural/Natural/Female when present, else system default).
/// - Stops previous speech before starting new speech (no overlap).
/// - Cleans markdown/emojis/URLs and speaks long replies in short
///   sentence chunks so Android never truncates them.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String? _currentText;
  String _currentLang = 'en';
  Map<dynamic, dynamic>? _pickedVoice;

  /// User-tunable softness (persisted). Defaults are calm + soft.
  double _userRate = 0.75;
  double _userPitch = 1.15;

  bool get isSpeaking => _isSpeaking;
  double get userRate => _userRate;
  double get userPitch => _userPitch;

  static const Map<String, String> _languageMap = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
    'gu': 'gu-IN',
    'bn': 'bn-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
  };

  /// Softer, human-like rate per language family.
  /// Calm + slow reads as "soft"; fast + loud reads as "hard".
  double _rateFor(String language) {
    final base = language == 'en' ? 0.75 : 0.70;
    // Blend user tuning with safe soft ceiling (never harsh-fast).
    return _userRate.clamp(0.3, 0.9) * 0.6 + base * 0.4;
  }

  double _pitchFor() => _userPitch.clamp(0.7, 1.4);

  Future<void> setUserTuning({double? rate, double? pitch}) async {
    if (rate != null) _userRate = rate.clamp(0.3, 1.0);
    if (pitch != null) _userPitch = pitch.clamp(0.5, 1.5);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_rate', _userRate);
      await prefs.setDouble('tts_pitch', _userPitch);
    } catch (_) {}
  }

  Future<void> init() async {
    try {
      try {
        final prefs = await SharedPreferences.getInstance();
        _userRate = (prefs.getDouble('tts_rate') ?? 0.75).clamp(0.3, 1.0);
        _userPitch = (prefs.getDouble('tts_pitch') ?? 1.15).clamp(0.5, 1.5);
      } catch (_) {}
      await _flutterTts.setSpeechRate(_rateFor('en'));
      await _flutterTts.setVolume(0.85);
      await _flutterTts.setPitch(_pitchFor());

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _flutterTts.awaitSpeakCompletion(true);
      }

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('TTS Error: $message');
        _isSpeaking = false;
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
      });
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// True when at least one system TTS engine exists.
  /// On some BlueStacks images there is NO engine at all
  /// (tts_default_synth = null) → speak() is silent no matter what.
  Future<bool> hasEngine() async {
    try {
      final engines = await _flutterTts.getEngines;
      if (engines is List && engines.isNotEmpty) return true;
      final voices = await _flutterTts.getVoices;
      if (voices is List && voices.isNotEmpty) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Pick the warmest voice for [locale] (cached per call).
  Future<void> _selectBestVoice(String locale) async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is! List || voices.isEmpty) return;
      final langPrefix = locale.split('-').first.toLowerCase();

      List<Map> candidates = [];
      for (final v in voices) {
        if (v is! Map) continue;
        final vLocale = '${v['locale'] ?? ''}'.toLowerCase();
        if (vLocale.startsWith(langPrefix)) candidates.add(v);
      }
      if (candidates.isEmpty) return;

      int score(Map v) {
        final name = '${v['name'] ?? ''}'.toLowerCase();
        var s = 0;
        if (name.contains('neural')) s += 40;
        if (name.contains('natural')) s += 30;
        if (name.contains('wavenet')) s += 25;
        if (name.contains('google')) s += 15;
        if (name.contains('female') || name.contains('f1')) s += 10;
        if (name.contains('compact') || name.contains('low')) s -= 20;
        return s;
      }

      candidates.sort((a, b) => score(b).compareTo(score(a)));
      final best = candidates.first;
      await _flutterTts.setVoice({
        'name': '${best['name']}',
        'locale': '${best['locale']}',
      });
      _pickedVoice = best;
    } catch (e) {
      debugPrint('TTS voice pick error: $e');
    }
  }

  /// Strip everything a human wouldn't say out loud.
  String cleanForSpeech(String text) {
    var out = text
        .replaceAll(RegExp(r'https?://\S+'), ' ')
        .replaceAll(RegExp(r'\*\*|__|`|#{1,6}\s?'), '')
        .replaceAll(RegExp(r'^\s*[-*•\d]+[.)]\s*', multiLine: true), '')
        // Emoji + symbols.
        .replaceAll(
            RegExp(
                r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}]',
                unicode: true),
            ' ')
        .replaceAll(RegExp(r'[<>{}\[\]|_~^]'), ' ')
        .replaceAll(RegExp(r'\n{2,}'), '. ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    // India-only app: always say "rupees" — never "dollar".
    out = out.replaceAll('₹', ' rupees ');
    out = out.replaceAll('\$', ' rupees ');
    out = out.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    // Gentle pauses so it sounds human, not rushed.
    out = out.replaceAll(RegExp(r'\s*([,.!?;:])\s*'), r'$1 ');
    // Say "AI" as letters, not "ai".
    out = out.replaceAllMapped(
        RegExp(r'\bAI\b'), (m) => 'A. I.');
    return out.isEmpty ? text : out;
  }

  /// Split into short spoken chunks (Android truncates ~4000 chars).
  List<String> _chunks(String text) {
    const max = 320;
    if (text.length <= max) return [text];
    final sentences = text.split(RegExp(r'(?<=[.!?।])\s+'));
    final out = <String>[];
    final buf = StringBuffer();
    for (final s in sentences) {
      if ((buf.length + s.length + 1) > max && buf.isNotEmpty) {
        out.add(buf.toString().trim());
        buf.clear();
      }
      buf.write(s);
      buf.write(' ');
    }
    if (buf.isNotEmpty) out.add(buf.toString().trim());
    return out.isEmpty ? [text] : out;
  }

  Future<void> speak(String text, {String language = 'en'}) async {
    final cleaned = cleanForSpeech(text);
    if (cleaned.isEmpty) return;

    try {
      // No overlap: a new reply always replaces the old one.
      try {
        await _flutterTts.stop();
      } catch (_) {}
      _isSpeaking = false;

      _currentText = cleaned;
      _currentLang = language;
      final String ttsLocale = _languageMap[language] ?? 'en-US';
      await _flutterTts.setLanguage(ttsLocale);
      await _selectBestVoice(ttsLocale);
      await _flutterTts.setSpeechRate(_rateFor(language));
      await _flutterTts.setVolume(0.85);
      await _flutterTts.setPitch(_pitchFor());
      _isSpeaking = true;
      for (final part in _chunks(cleaned)) {
        if (!_isSpeaking) break;
        await _flutterTts.speak(part);
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    _isSpeaking = false;
    try {
      await _flutterTts.stop();
      _currentText = null;
    } catch (e) {
      debugPrint('TTS stop error: $e');
      _isSpeaking = false;
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_currentText != null) {
        _isSpeaking = true;
        await _flutterTts.speak(_currentText!);
      }
    } catch (e) {
      debugPrint('TTS resume error: $e');
      _isSpeaking = false;
    }
  }

  /// Re-speak the last reply in its language.
  Future<void> replay() async {
    if (_currentText == null) return;
    await speak(_currentText!, language: _currentLang);
  }

  void dispose() {
    stop();
  }
}
