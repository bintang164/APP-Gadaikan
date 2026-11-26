import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

/// Kartu kategori layanan gadai.
class ServiceCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool compact;

  const ServiceCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.accentColor = AppColors.primary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Layanan $title. $description',
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 38 : 44,
              height: compact ? 38 : 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: compact ? 20 : 24,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: (compact
                      ? AppTextStyles.titleSmall
                      : AppTextStyles.titleMedium)
                  .copyWith(color: AppColors.textPrimary),
            ),
            if (!compact) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
