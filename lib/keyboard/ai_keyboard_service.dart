import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

/// Bridge between Flutter and the native AiKeyboardService via MethodChannel.
class AiKeyboardServiceBridge {
  static const MethodChannel _channel = MethodChannel(ChannelNames.commit);

  /// Commits the given text into the currently active text field.
  static Future<bool> commitText(
    String text, {
    int newCursorPosition = 1,
  }) async {
    try {
      final result = await _channel.invokeMethod('commitText', {
        'text': text,
        'newCursorPosition': newCursorPosition,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('commitText failed: ${e.message}');
      return false;
    }
  }

  /// Deletes text around the cursor.
  static Future<bool> deleteSurroundingText({
    int before = 1,
    int after = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod('deleteSurroundingText', {
        'before': before,
        'after': after,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('deleteSurroundingText failed: ${e.message}');
      return false;
    }
  }

  /// Sends a key event (e.g., Enter key).
  static Future<bool> sendKeyEvent(int keyCode) async {
    try {
      final result = await _channel.invokeMethod('sendKeyEvent', {
        'keyCode': keyCode,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('sendKeyEvent failed: ${e.message}');
      return false;
    }
  }

  /// Gets information about the currently active editor.
  static Future<Map<String, dynamic>?> getEditorInfo() async {
    try {
      final result = await _channel.invokeMethod('getEditorInfo');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('getEditorInfo failed: ${e.message}');
      return null;
    }
  }

  /// Performs an editor action (e.g., IME_ACTION_DONE, IME_ACTION_SEND).
  static Future<bool> performEditorAction(int action) async {
    try {
      final result = await _channel.invokeMethod('performEditorAction', {
        'action': action,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('performEditorAction failed: ${e.message}');
      return false;
    }
  }

  /// Listens for callbacks from native side (onStartInput, onFinishInput).
  static void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    _channel.setMethodCallHandler(handler);
  }
}
