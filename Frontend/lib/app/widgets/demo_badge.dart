import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Label kecil untuk menandai data/aksi mode demo atau simulasi.
class DemoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const DemoBadge({
    super.key,
    this.label = 'Demo',
    this.color = AppColors.warning,
    this.backgroundColor = AppColors.warningSoft,
    this.icon = Icons.science_outlined,
  });

  const DemoBadge.simulation({super.key})
      : label = 'Simulasi',
        color = AppColors.info,
        backgroundColor = AppColors.infoSoft,
        icon = Icons.info_outline_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
