import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// The phase of the mic button, driving its visual state.
enum MicPhase {
  idle, // Static cyan mic icon
  recording, // Pulsing red glow
  processing, // Rotating cyan arc
  done, // Green checkmark flash
}

/// Animated mic button with 4 visual states.
class MicButton extends StatefulWidget {
  final MicPhase phase;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MicButton({
    super.key,
    this.phase = MicPhase.idle,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _doneController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.micPulse,
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: AppDurations.processingRotation,
    );

    _doneController = AnimationController(
      vsync: this,
      duration: AppDurations.doneFlash,
    );

    _updateAnimations();
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    // Stop all
    _pulseController.stop();
    _rotationController.stop();
    _doneController.stop();

    switch (widget.phase) {
      case MicPhase.idle:
        _pulseController.reset();
        _rotationController.reset();
        _doneController.reset();
        break;
      case MicPhase.recording:
        _pulseController.repeat(reverse: true);
        break;
      case MicPhase.processing:
        _rotationController.repeat();
        break;
      case MicPhase.done:
        _doneController.forward();
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _doneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _rotationController,
          _doneController,
        ]),
        builder: (context, child) {
          return _buildMicVisual();
        },
      ),
    );
  }

  Widget _buildMicVisual() {
    switch (widget.phase) {
      case MicPhase.idle:
        return _buildIdleMic();
      case MicPhase.recording:
        return _buildRecordingMic();
      case MicPhase.processing:
        return _buildProcessingMic();
      case MicPhase.done:
        return _buildDoneMic();
    }
  }

  Widget _buildIdleMic() {
    return Container(
      width: 52,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: const Icon(Icons.mic, color: AppColors.accent, size: 24),
    );
  }

  Widget _buildRecordingMic() {
    final pulseValue = _pulseController.value;
    final glowRadius = 4.0 + (pulseValue * 12.0);
    final opacity = 0.3 + (pulseValue * 0.4);

    return Container(
      width: 52,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.recordingRed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.recordingRed, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.recordingRed.withValues(alpha: opacity),
            blurRadius: glowRadius,
            spreadRadius: pulseValue * 3,
          ),
        ],
      ),
      child: const Icon(Icons.mic, color: AppColors.recordingRed, size: 24),
    );
  }

  Widget _buildProcessingMic() {
    return Container(
      width: 52,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.keyFill,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.keyBorder, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating arc
          Transform.rotate(
            angle: _rotationController.value * 2 * pi,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Center icon
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 16),
        ],
      ),
    );
  }

  Widget _buildDoneMic() {
    final scale = _doneController.value < 0.5
        ? 1.0 + (_doneController.value * 0.4)
        : 1.2 - ((_doneController.value - 0.5) * 0.4);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 52,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: AppColors.success, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(
                alpha: 0.3 * (1 - _doneController.value),
              ),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.check, color: AppColors.success, size: 24),
      ),
    );
  }
}

/// AnimatedBuilder is a convenience widget that wraps AnimatedWidget.
class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      listenable: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder2({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
