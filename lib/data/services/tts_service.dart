import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around flutter_tts for word pronunciation.
///
/// Later you can play recorded audio files from Firebase Storage here
/// instead, without touching the UI.
class TtsService {
  TtsService() {
    _init();
  }

  /// Language code → TTS locale.
  static const _locales = {
    'en': 'en-US',
    'ar': 'ar-SA',
    'tr': 'tr-TR',
    'fr': 'fr-FR',
    'zh': 'zh-CN',
  };

  final FlutterTts _tts = FlutterTts();
  String? _currentLocale;

  Future<void> _init() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
  }

  /// Speaks [text] in [languageCode]. Returns `false` if speech failed
  /// (e.g. the voice is not installed on the device).
  Future<bool> speak(String text, String languageCode) async {
    try {
      final locale = _locales[languageCode] ?? 'en-US';
      if (locale != _currentLocale) {
        await _tts.setLanguage(locale);
        _currentLocale = locale;
      }
      await _tts.stop();
      final result = await _tts.speak(text);
      return result == 1 || result == true || result == null;
    } catch (e) {
      debugPrint('TTS speak failed: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
