import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Upload slot for photos/documents with thumbnail preview, replace, and delete actions.
class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPick,
    this.fileName,
    this.fileSizeLabel,
    this.onReplace,
    this.onRemove,
    this.errorText,
    this.isUploading = false,
    this.isRequired = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPick;
  final String? fileName;
  final String? fileSizeLabel;
  final VoidCallback? onReplace;
  final VoidCallback? onRemove;
  final String? errorText;
  final bool isUploading;
  final bool isRequired;

  bool get _hasFile => fileName != null && fileName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText != null
        ? AppColors.danger
        : (_hasFile ? AppColors.success : AppColors.border);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: _hasFile ? _buildUploadedState() : _buildEmptyState(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: isUploading ? null : onPick,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.cardTitle,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Wajib',
                          style: AppTextStyles.captionBold.copyWith(
                            color: AppColors.danger,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.upload_file_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: AppColors.success,
                  size: 26,
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.captionBold),
                const SizedBox(height: 2),
                Text(
                  fileName!,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSizeLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$fileSizeLabel • Siap diunggah',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onReplace != null)
            IconButton(
              onPressed: onReplace,
              tooltip: 'Ganti berkas',
              icon: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
              ),
            ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              tooltip: 'Hapus berkas',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
            ),
        ],
      ),
    );
  }
}
