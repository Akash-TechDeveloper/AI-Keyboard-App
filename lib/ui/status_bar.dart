import 'package:flutter/material.dart';
import '../core/constants.dart';

/// The current status phase for the status bar.
enum StatusPhase { idle, listening, thinking, done, error }

/// Thin status bar at the top of the keyboard showing current phase.
class KeyboardStatusBar extends StatelessWidget {
  final StatusPhase phase;
  final String? errorMessage;
  final String? detectedMode;

  const KeyboardStatusBar({
    super.key,
    this.phase = StatusPhase.idle,
    this.errorMessage,
    this.detectedMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.keyBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: AppDurations.statusTransition,
              child: _buildStatusContent(),
            ),
          ),
          if (detectedMode != null && phase == StatusPhase.listening)
            _buildModeBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusContent() {
    switch (phase) {
      case StatusPhase.idle:
        return const _StatusText(
          key: ValueKey('idle'),
          text: 'AI Keyboard',
          color: AppColors.textSecondary,
        );
      case StatusPhase.listening:
        return const _StatusText(
          key: ValueKey('listening'),
          icon: Icons.mic,
          text: 'Listening...',
          color: AppColors.recordingRed,
        );
      case StatusPhase.thinking:
        return const _StatusText(
          key: ValueKey('thinking'),
          icon: Icons.auto_awesome,
          text: 'Thinking...',
          color: AppColors.accent,
        );
      case StatusPhase.done:
        return const _StatusText(
          key: ValueKey('done'),
          icon: Icons.check_circle,
          text: 'Done',
          color: AppColors.success,
        );
      case StatusPhase.error:
        return _StatusText(
          key: const ValueKey('error'),
          icon: Icons.error_outline,
          text: errorMessage ?? 'Error',
          color: AppColors.error,
        );
    }
  }

  Widget _buildModeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        detectedMode!,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;

  const _StatusText({
    super.key,
    this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
