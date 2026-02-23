import 'ai_keyboard_service.dart';

/// High-level helper for input connection operations.
/// Wraps the raw MethodChannel bridge with convenient methods.
class KeyboardInputConnection {
  /// Type a single character into the active field.
  Future<bool> typeCharacter(String char) {
    return AiKeyboardServiceBridge.commitText(char);
  }

  /// Type a full string (e.g., AI-rewritten text) into the active field.
  Future<bool> typeText(String text) {
    return AiKeyboardServiceBridge.commitText(text);
  }

  /// Delete one character before the cursor (backspace).
  Future<bool> backspace() {
    return AiKeyboardServiceBridge.deleteSurroundingText(before: 1, after: 0);
  }

  /// Delete multiple characters before the cursor.
  Future<bool> deleteMultiple(int count) {
    return AiKeyboardServiceBridge.deleteSurroundingText(before: count, after: 0);
  }

  /// Send Enter key action.
  Future<bool> sendEnter() {
    // KeyEvent.KEYCODE_ENTER = 66
    return AiKeyboardServiceBridge.sendKeyEvent(66);
  }

  /// Perform the default editor action (Send, Done, Next, etc.).
  Future<bool> performAction(int action) {
    return AiKeyboardServiceBridge.performEditorAction(action);
  }

  /// Insert AI-rewritten text, replacing any existing selection.
  Future<bool> insertAiText(String text) async {
    return AiKeyboardServiceBridge.commitText(text);
  }
}
