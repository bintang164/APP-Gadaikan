import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class TimelineStepItem {
  const TimelineStepItem({
    required this.title,
    required this.subtitle,
    this.timestampLabel,
    this.isCompleted = false,
    this.isActive = false,
    this.isError = false,
  });

  final String title;
  final String subtitle;
  final String? timestampLabel;
  final bool isCompleted;
  final bool isActive;
  final bool isError;
}

/// Vertical status timeline for pawn application tracking.
class ApplicationTimeline extends StatelessWidget {
  const ApplicationTimeline({
    super.key,
    required this.steps,
  });

  final List<TimelineStepItem> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineRow(
            item: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.isLast,
  });

  final TimelineStepItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final IconData? dotIcon;

    if (item.isError) {
      dotColor = AppColors.danger;
      dotIcon = Icons.close_rounded;
    } else if (item.isCompleted) {
      dotColor = AppColors.success;
      dotIcon = Icons.check_rounded;
    } else if (item.isActive) {
      dotColor = AppColors.primary;
      dotIcon = Icons.schedule_rounded;
    } else {
      dotColor = AppColors.border;
      dotIcon = null;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: dotIcon != null ? dotColor : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: 2,
                    ),
                  ),
                  child: dotIcon != null
                      ? Icon(dotIcon, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: item.isCompleted
                          ? AppColors.success.withValues(alpha: 0.45)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md - 4),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: (item.isCompleted ||
                                    item.isActive ||
                                    item.isError)
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (item.timestampLabel != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.timestampLabel!,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
