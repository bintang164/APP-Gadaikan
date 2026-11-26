import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'secondary_button.dart';

/// Error state dengan aksi coba lagi.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final bool compact;
  final EdgeInsetsGeometry padding;

  const ErrorState({
    super.key,
    this.title = 'Terjadi kesalahan',
    required this.message,
    this.retryLabel = 'Coba lagi',
    this.onRetry,
    this.compact = false,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    final double iconBox = compact ? 56 : 72;
    final double iconSize = compact ? 26 : 34;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: const BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: iconSize,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
