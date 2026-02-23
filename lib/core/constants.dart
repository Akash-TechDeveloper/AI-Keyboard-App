import 'package:flutter/material.dart';

/// App-wide color palette
class AppColors {
  static const Color background = Color(0xFF0D0D0D);
  static const Color keyFill = Color(0xFF1C1C1E);
  static const Color keyBorder = Color(0xFF2C2C2E);
  static const Color accent = Color(0xFF00E5FF);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF30D158);
  static const Color recordingRed = Color(0xFFFF3B30);
  static const Color keyPressed = Color(0xFF3A3A3C);
}

/// MethodChannel names
class ChannelNames {
  static const String commit = 'ai_keyboard/commit';
  static const String context = 'ai_keyboard/context';
}

/// Animation durations
class AppDurations {
  static const Duration keyPress = Duration(milliseconds: 20);
  static const Duration micPulse = Duration(milliseconds: 800);
  static const Duration processingRotation = Duration(milliseconds: 1200);
  static const Duration doneFlash = Duration(milliseconds: 1500);
  static const Duration statusTransition = Duration(milliseconds: 300);
}

/// Performance budgets
class PerformanceBudgets {
  static const Duration sttFirstWord = Duration(milliseconds: 800);
  static const Duration fullTranscript = Duration(milliseconds: 2500);
  static const Duration geminiRewrite = Duration(milliseconds: 1500);
  static const Duration commitText = Duration(milliseconds: 50);
  static const Duration sttTimeout = Duration(seconds: 8);
}

/// Secure storage keys
class StorageKeys {
  static const String geminiApiKey = 'gemini_api_key';
  static const String openaiApiKey = 'openai_api_key';
  static const String ttsEnabled = 'tts_enabled';
  static const String ttsVoice = 'tts_voice';
  static const String defaultToneOverride = 'default_tone_override';
  static const String whisperFallbackEnabled = 'whisper_fallback_enabled';
  static const String showRawTranscript = 'show_raw_transcript';
}
