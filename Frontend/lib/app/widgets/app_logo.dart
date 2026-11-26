import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Wordmark teks GADAIKAN orisinal.
class AppLogo extends StatelessWidget {
  final double fontSize;
  final bool light;
  final bool showTagline;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  const AppLogo({
    super.key,
    this.fontSize = 34,
    this.light = false,
    this.showTagline = true,
    this.alignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final Color wordColor =
        light ? AppColors.textOnPrimary : AppColors.textPrimary;
    final Color taglineColor = light
        ? AppColors.textOnPrimary.withValues(alpha: 0.78)
        : AppColors.textSecondary;

    return Semantics(
      label: 'Gadaikan. Solusi Gadai dalam Genggaman.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              textAlign: textAlign,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontFamilyFallback: AppTextStyles.fontFallback,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  height: 1.05,
                  color: wordColor,
                ),
                children: const [
                  TextSpan(text: 'GADAI'),
                  TextSpan(
                    text: 'KAN',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: 42,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          if (showTagline) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Solusi Gadai dalam Genggaman',
              textAlign: textAlign,
              style: AppTextStyles.bodySmall.copyWith(
                color: taglineColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
