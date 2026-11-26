import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

enum OnboardingIllustration { categories, upload, tracking }

class OnboardingData {
  final String title;
  final String description;
  final OnboardingIllustration illustration;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal,
            vertical: AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Illustration(type: data.illustration),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  data.title,
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  data.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Illustration extends StatelessWidget {
  final OnboardingIllustration type;

  const _Illustration({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: _Circle(
              size: 120,
              color: AppColors.gold.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _Circle(
              size: 140,
              color: AppColors.primary.withValues(alpha: 0.06),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: switch (type) {
                OnboardingIllustration.categories => const _Categories(),
                OnboardingIllustration.upload => const _Upload(),
                OnboardingIllustration.tracking => const _Tracking(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Expanded(
          child: _CategoryBubble(
            icon: Icons.smartphone_rounded,
            label: 'Elektronik',
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _CategoryBubble(
            icon: Icons.diamond_outlined,
            label: 'Emas',
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _CategoryBubble(
            icon: Icons.directions_car_outlined,
            label: 'BPKB',
          ),
        ),
      ],
    );
  }
}

class _CategoryBubble extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryBubble({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D10212F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Upload extends StatelessWidget {
  const _Upload();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 150,
          height: 170,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 96,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Icon(
                Icons.description_outlined,
                size: 56,
                color: AppColors.primary,
              ),
              const Spacer(),
              Container(
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -18,
          bottom: -12,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 4),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.textOnPrimary,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tracking extends StatelessWidget {
  const _Tracking();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrackingStep(
            icon: Icons.send_rounded,
            label: 'Pengajuan dikirim',
            color: AppColors.success,
          ),
          _TrackingLine(),
          _TrackingStep(
            icon: Icons.fact_check_outlined,
            label: 'Sedang ditinjau',
            color: AppColors.warning,
          ),
          _TrackingLine(),
          _TrackingStep(
            icon: Icons.verified_outlined,
            label: 'Penawaran siap',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrackingStep({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingLine extends StatelessWidget {
  const _TrackingLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 1,
          height: 16,
          color: AppColors.border,
        ),
      ),
    );
  }
}
