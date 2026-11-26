import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum StatusTone { neutral, info, warning, success, danger }

/// Accessible status pill combining text label, icon/dot, and semantic color.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.compact = false,
  });

  final String label;
  final StatusTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      StatusTone.neutral => (AppColors.background, AppColors.textSecondary),
      StatusTone.info => (AppColors.infoSoft, AppColors.info),
      StatusTone.warning => (AppColors.warningSoft, AppColors.warning),
      StatusTone.success => (AppColors.successSoft, AppColors.success),
      StatusTone.danger => (AppColors.dangerSoft, AppColors.danger),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionBold.copyWith(
                color: fg,
                fontSize: compact ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
