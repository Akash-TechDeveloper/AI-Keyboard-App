import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard/keyboard_ui.dart';
import 'core/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AiKeyboardApp());
}

/// Main app entry point.
/// When launched as an app (via launcher icon), shows the setup/settings screen.
/// When loaded as an IME service, the KeyboardUI is rendered by the FlutterEngine
/// created in AiKeyboardService.kt.
class AiKeyboardApp extends StatelessWidget {
  const AiKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Keyboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          surface: AppColors.keyFill,
          error: AppColors.error,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SetupScreen(),
    );
  }
}

/// Setup screen shown when the user launches the app.
/// Guides them to enable the AI Keyboard in system settings.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // App title
              const Text(
                'AI Keyboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your intelligent voice-powered keyboard',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // Setup steps
              _buildSetupStep(
                number: 1,
                title: 'Enable the Keyboard',
                description:
                    'Go to Settings → System → Languages & Input → '
                    'On-screen keyboard → Manage → Enable "AI Keyboard"',
                icon: Icons.keyboard,
                actionLabel: 'Open Settings',
                onAction: _openInputMethodSettings,
              ),
              const SizedBox(height: 16),
              _buildSetupStep(
                number: 2,
                title: 'Switch to AI Keyboard',
                description:
                    'Open any app with a text field, tap the keyboard icon '
                    'in the navigation bar, and select "AI Keyboard"',
                icon: Icons.swap_horiz,
              ),
              const SizedBox(height: 16),
              _buildSetupStep(
                number: 3,
                title: 'Configure API Key',
                description:
                    'Tap the settings icon or long-press the mic button '
                    'to enter your Gemini API key',
                icon: Icons.key,
                actionLabel: 'Settings',
                onAction: _openSettings,
              ),
              const SizedBox(height: 16),
              _buildSetupStep(
                number: 4,
                title: 'Grant Permissions',
                description:
                    'Allow microphone access for voice input '
                    'and usage stats for app-aware formatting',
                icon: Icons.security,
              ),

              const Spacer(),

              // Keyboard preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.keyFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.keyBorder, width: 1),
                ),
                clipBehavior: Clip.hardEdge,
                child: const KeyboardUI(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.keyFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.keyBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openInputMethodSettings() {
    // Open Android input method settings
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    // Use an intent to open input method settings
    const MethodChannel('ai_keyboard/commit').invokeMethod('openInputSettings');
  }

  void _openSettings() {
    // Navigate to settings screen (not yet implemented)
  }
}
