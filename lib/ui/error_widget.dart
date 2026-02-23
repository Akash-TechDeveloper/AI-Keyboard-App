import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Error widget shown inside keyboard when errors occur.
/// Provides retry functionality and descriptive error messages.
class KeyboardErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showInsertRaw;
  final String? rawText;
  final VoidCallback? onInsertRaw;

  const KeyboardErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.showInsertRaw = false,
    this.rawText,
    this.onInsertRaw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showInsertRaw && rawText != null)
                _ActionButton(
                  label: 'Insert raw',
                  color: AppColors.textSecondary,
                  onTap: onInsertRaw,
                ),
              if (showInsertRaw && rawText != null)
                const SizedBox(width: 8),
              if (onRetry != null)
                _ActionButton(
                  label: 'Retry',
                  color: AppColors.accent,
                  onTap: onRetry,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
