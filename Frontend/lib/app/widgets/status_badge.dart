import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Badge status dengan teks dan warna.
///
/// Status tidak boleh disampaikan hanya lewat warna, sehingga label teks
/// selalu ditampilkan.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData? icon;
  final bool dense;

  const StatusBadge({
    super.key,
    required this.label,
    this.color = AppColors.info,
    this.backgroundColor = AppColors.infoSoft,
    this.icon,
    this.dense = false,
  });

  const StatusBadge.success({
    super.key,
    required this.label,
    this.icon = Icons.check_circle_outline_rounded,
    this.dense = false,
  })  : color = AppColors.success,
        backgroundColor = AppColors.successSoft;

  const StatusBadge.warning({
    super.key,
    required this.label,
    this.icon = Icons.schedule_rounded,
    this.dense = false,
  })  : color = AppColors.warning,
        backgroundColor = AppColors.warningSoft;

  const StatusBadge.danger({
    super.key,
    required this.label,
    this.icon = Icons.cancel_outlined,
    this.dense = false,
  })  : color = AppColors.danger,
        backgroundColor = AppColors.dangerSoft;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
          vertical: dense ? AppSpacing.xxs : 6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: dense ? 14 : 16, color: color),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
