import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Original Gadaikan brand emblem and wordmark (Navy Blue + Gold).
class GadaikanLogo extends StatelessWidget {
  const GadaikanLogo({
    super.key,
    this.size = 56,
    this.darkBackground = false,
    this.showWordmark = true,
  });

  final double size;
  final bool darkBackground;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final textColor = darkBackground ? Colors.white : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.85),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shield_rounded,
                color: AppColors.accentGold.withValues(alpha: 0.25),
                size: size * 0.68,
              ),
              Text(
                'G',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GADAIKAN',
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  height: 1.1,
                ),
              ),
              Text(
                'Solusi Gadai Digital',
                style: TextStyle(
                  color: darkBackground
                      ? Colors.white.withValues(alpha: 0.78)
                      : AppColors.textSecondary,
                  fontSize: size * 0.21,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
