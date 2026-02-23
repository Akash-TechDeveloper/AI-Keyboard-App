import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../ui/keyboard_layout.dart';
import '../ui/mic_button.dart';
import '../ui/status_bar.dart';
import '../ui/error_widget.dart';

/// Top-level keyboard widget rendered inside the IME.
/// Composes StatusBar + KeyboardLayout with mic button integration.
class KeyboardUI extends StatefulWidget {
  const KeyboardUI({super.key});

  @override
  State<KeyboardUI> createState() => _KeyboardUIState();
}

class _KeyboardUIState extends State<KeyboardUI> {
  StatusPhase _statusPhase = StatusPhase.idle;
  MicPhase _micPhase = MicPhase.idle;
  String? _errorMessage;
  String? _detectedMode;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status bar
            KeyboardStatusBar(
              phase: _statusPhase,
              errorMessage: _errorMessage,
              detectedMode: _detectedMode,
            ),

            // Error widget (shown when error occurs)
            if (_showError)
              KeyboardErrorWidget(
                message: _errorMessage ?? 'An error occurred',
                onRetry: _onRetry,
                onDismiss: _dismissError,
              ),

            // Keyboard layout with integrated bottom row
            Expanded(child: _buildKeyboardWithMic()),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardWithMic() {
    return Stack(
      children: [
        // Main keyboard layout
        KeyboardLayout(
          onMicPressed: _onMicTap,
          onMicLongPressed: _onMicLongPress,
        ),

        // Mic button overlay positioned in the bottom row
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: MicButton(
              phase: _micPhase,
              onTap: _onMicTap,
              onLongPress: _onMicLongPress,
            ),
          ),
        ),
      ],
    );
  }

  void _onMicTap() {
    setState(() {
      switch (_micPhase) {
        case MicPhase.idle:
          _micPhase = MicPhase.recording;
          _statusPhase = StatusPhase.listening;
          _showError = false;
          break;
        case MicPhase.recording:
          _micPhase = MicPhase.processing;
          _statusPhase = StatusPhase.thinking;
          break;
        case MicPhase.processing:
          // Cannot interrupt processing
          break;
        case MicPhase.done:
          _micPhase = MicPhase.idle;
          _statusPhase = StatusPhase.idle;
          break;
      }
    });
  }

  void _onMicLongPress() {
    // Navigate to settings screen (not yet implemented)
  }

  void _onRetry() {
    setState(() {
      _showError = false;
      _errorMessage = null;
      _statusPhase = StatusPhase.idle;
      _micPhase = MicPhase.idle;
    });
  }

  void _dismissError() {
    setState(() {
      _showError = false;
      _errorMessage = null;
      _statusPhase = StatusPhase.idle;
      _micPhase = MicPhase.idle;
    });
  }

  /// Called externally to update the keyboard state.
  void updatePhase(MicPhase micPhase, StatusPhase statusPhase, {String? mode}) {
    setState(() {
      _micPhase = micPhase;
      _statusPhase = statusPhase;
      _detectedMode = mode;
    });
  }

  /// Called externally when an error occurs.
  void showError(String message) {
    setState(() {
      _showError = true;
      _errorMessage = message;
      _statusPhase = StatusPhase.error;
      _micPhase = MicPhase.idle;
    });
  }
}
