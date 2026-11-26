import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Komponen upload foto/dokumen yang dipakai ulang untuk semua kategori.
///
/// Menampilkan preview thumbnail, progres, error + retry, serta aksi
/// ganti/hapus. Tidak pernah menampilkan URL publik berkas privat.
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
    this.previewBytes,
    this.uploadProgress,
    this.uploadError,
    this.onRetry,
    this.isSensitive = false,
    this.isDemo = false,
    this.isUploadedToServer = false,
    this.modeLabel,
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

  final Uint8List? previewBytes;
  final double? uploadProgress;
  final String? uploadError;
  final VoidCallback? onRetry;
  final bool isSensitive;
  final bool isDemo;
  final bool isUploadedToServer;
  final String? modeLabel;

  bool get _hasFile => fileName != null && fileName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = uploadError != null || errorText != null
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
        if (errorText != null || uploadError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              uploadError ?? errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
        if (modeLabel != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              modeLabel!,
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
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
                        child: Text(title, style: AppTextStyles.cardTitle),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title, style: AppTextStyles.captionBold),
                        ),
                        if (isSensitive) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileName!,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fileSizeLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(fileSizeLabel!, style: AppTextStyles.caption),
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
          if (isUploading || (uploadProgress != null && uploadProgress! < 1))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: LinearProgressIndicator(
                value: uploadProgress ?? 0,
                minHeight: 6,
                backgroundColor: AppColors.primarySoft,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          if (uploadError != null && onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba lagi'),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _statusText,
            style: AppTextStyles.caption.copyWith(
              color: uploadError != null
                  ? AppColors.danger
                  : isDemo
                      ? AppColors.warning
                      : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: previewBytes != null
          ? Image.memory(
              previewBytes!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.image_outlined,
                color: AppColors.textSecondary,
              ),
            )
          : const Icon(
              Icons.image_outlined,
              color: AppColors.textSecondary,
              size: 26,
            ),
    );
  }

  String get _statusText {
    if (uploadError != null) return 'Gagal mengunggah — coba lagi.';
    if (isUploading || (uploadProgress != null && uploadProgress! < 1)) {
      final int percent = ((uploadProgress ?? 0) * 100).round();
      return 'Mengunggah... $percent%';
    }
    if (isDemo) return 'Mode demo: belum tersimpan di server.';
    if (isUploadedToServer) {
      return isSensitive
          ? 'Tersimpan privat di server (terotorisasi).'
          : 'Tersimpan di server.';
    }
    return 'Siap diunggah.';
  }
}
