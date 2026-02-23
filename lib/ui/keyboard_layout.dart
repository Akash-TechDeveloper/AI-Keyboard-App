import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../keyboard/keyboard_input_connection.dart';

class KeyboardLayout extends StatefulWidget {
  final VoidCallback? onMicPressed;
  final VoidCallback? onMicLongPressed;
  final VoidCallback? onSettingsPressed;

  const KeyboardLayout({
    super.key,
    this.onMicPressed,
    this.onMicLongPressed,
    this.onSettingsPressed,
  });

  @override
  State<KeyboardLayout> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<KeyboardLayout> {
  final KeyboardInputConnection _inputConnection = KeyboardInputConnection();

  bool _isShifted = false;
  bool _isNumeric = false;

  static const _row1 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  static const _row2 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
  static const _row3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];

  static const _numRow1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _numRow2 = ['@', '#', '\$', '_', '&', '-', '+', '(', ')', '/'];
  static const _numRow3 = ['*', '"', "'", ':', ';', '!', '?'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rowHeight = constraints.maxHeight / 4;

          return Column(
            children: [
              Expanded(
                child: _buildKeyRow(_isNumeric ? _numRow1 : _row1, rowHeight),
              ),
              Expanded(
                child: _buildKeyRow(_isNumeric ? _numRow2 : _row2, rowHeight),
              ),
              Expanded(child: _buildRow3(rowHeight)),
              Expanded(child: _buildBottomRow(rowHeight)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: keys
            .map(
              (key) => Expanded(
                child: _KeyButton(
                  label: _isShifted && !_isNumeric ? key.toUpperCase() : key,
                  height: height - 6,
                  onTap: () => _onKeyTap(key),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRow3(double height) {
    final keys = _isNumeric ? _numRow3 : _row3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          _SpecialKeyButton(
            icon: _isNumeric
                ? Icons.abc
                : (_isShifted
                      ? Icons.keyboard_capslock
                      : Icons.keyboard_arrow_up),
            width: 48,
            height: height - 6,
            onTap: () {
              setState(() {
                if (!_isNumeric) {
                  _isShifted = !_isShifted;
                }
              });
            },
          ),
          const SizedBox(width: 2),
          ...keys.map(
            (key) => Expanded(
              child: _KeyButton(
                label: _isShifted && !_isNumeric ? key.toUpperCase() : key,
                height: height - 6,
                onTap: () => _onKeyTap(key),
              ),
            ),
          ),
          const SizedBox(width: 2),
          _SpecialKeyButton(
            icon: Icons.backspace_outlined,
            width: 48,
            height: height - 6,
            onTap: _onBackspace,
            onLongPress: _onBackspace,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          _SpecialKeyButton(
            label: _isNumeric ? 'ABC' : '123',
            width: 52,
            height: height - 6,
            onTap: () {
              setState(() => _isNumeric = !_isNumeric);
            },
          ),
          const SizedBox(width: 4),
          _SpecialKeyButton(
            label: ',',
            width: 36,
            height: height - 6,
            onTap: () => _inputConnection.typeCharacter(','),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _KeyButton(
              label: 'space',
              height: height - 6,
              onTap: () => _inputConnection.typeCharacter(' '),
            ),
          ),
          const SizedBox(width: 4),
          _SpecialKeyButton(
            label: '.',
            width: 36,
            height: height - 6,
            onTap: () => _inputConnection.typeCharacter('.'),
          ),
          const SizedBox(width: 4),
          _SpecialKeyButton(
            icon: Icons.keyboard_return,
            width: 52,
            height: height - 6,
            color: AppColors.accent,
            onTap: () => _inputConnection.sendEnter(),
          ),
        ],
      ),
    );
  }

  void _onKeyTap(String key) {
    final char = _isShifted && !_isNumeric ? key.toUpperCase() : key;
    _inputConnection.typeCharacter(char);

    if (_isShifted) {
      setState(() => _isShifted = false);
    }
  }

  void _onBackspace() {
    _inputConnection.backspace();
  }
}

class _KeyButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.height,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AppDurations.keyPress,
        child: Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.keyPressed : AppColors.keyFill,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.keyBorder, width: 0.5),
          ),
          alignment: Alignment.center,
          child: widget.label == 'space'
              ? const SizedBox()
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SpecialKeyButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final double width;
  final double height;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;

  const _SpecialKeyButton({
    this.label,
    this.icon,
    required this.width,
    required this.height,
    required this.onTap,
    this.onLongPress,
    this.color,
  });

  @override
  State<_SpecialKeyButton> createState() => _SpecialKeyButtonState();
}

class _SpecialKeyButtonState extends State<_SpecialKeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AppDurations.keyPress,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.color ?? AppColors.keyFill).withValues(alpha: 0.7)
                : (widget.color ?? AppColors.keyFill),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.keyBorder, width: 0.5),
          ),
          alignment: Alignment.center,
          child: widget.icon != null
              ? Icon(widget.icon, color: AppColors.textPrimary, size: 20)
              : Text(
                  widget.label ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
