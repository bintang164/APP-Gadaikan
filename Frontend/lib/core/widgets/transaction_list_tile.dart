import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_cards.dart';
import 'status_badge.dart';

/// Reusable list card for displaying a pawn application or transaction summary.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.code,
    required this.title,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.dateLabel,
    required this.statusLabel,
    required this.statusTone,
    required this.onTap,
    this.amountLabel,
    this.subtitle,
  });

  final String code;
  final String title;
  final String categoryLabel;
  final IconData categoryIcon;
  final String dateLabel;
  final String statusLabel;
  final StatusTone statusTone;
  final VoidCallback onTap;
  final String? amountLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              StatusBadge(
                label: statusLabel,
                tone: statusTone,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md - 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle ?? '$categoryLabel • $dateLabel',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (amountLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountLabel!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
