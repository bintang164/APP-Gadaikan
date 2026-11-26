import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../auth/screens/login_screen.dart';
import '../../info/screens/faq_screen.dart';
import '../../info/screens/outlets_screen.dart';
import '../../info/screens/promos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final appState = AppStateScope.of(context);
    final user = appState.user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final emailCtrl = TextEditingController(text: user.email ?? '');
    final addressCtrl = TextEditingController(text: user.address ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ubah Profil', style: AppTextStyles.sectionHeading),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) =>
                      AppValidators.requiredField(v, label: 'Nama lengkap'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Nomor HP'),
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Email (Opsional)'),
                  validator: (v) => AppValidators.email(v, required: false),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Simpan Perubahan',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && context.mounted) {
      try {
        await appState.updateProfile(
          user.copyWith(
            name: nameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
            email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
            address: addressCtrl.text.trim(),
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui.')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan profil: ${error.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    }
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content, style: AppTextStyles.bodySecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Anda perlu masuk kembali untuk mengakses data pengajuan dan transaksi Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AppStateScope.of(context).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    final initial = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : 'N';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Nasabah Demo',
                          style: AppTextStyles.sectionHeading,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.phone ?? '-',
                          style: AppTextStyles.bodySecondary,
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.email!,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditProfileDialog(context),
                    tooltip: 'Edit Profil',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Ubah Data Profil',
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  const Divider(),
                  _ProfileTile(
                    icon: Icons.storefront_outlined,
                    title: 'Daftar Outlet',
                    onTap: () => Navigator.of(context)
                        .pushNamed(OutletsScreen.routeName),
                  ),
                  const Divider(),
                  _ProfileTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Informasi Promo',
                    onTap: () =>
                        Navigator.of(context).pushNamed(PromosScreen.routeName),
                  ),
                  const Divider(),
                  _ProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan & FAQ',
                    onTap: () =>
                        Navigator.of(context).pushNamed(FaqScreen.routeName),
                  ),
                  const Divider(),
                  _ProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    onTap: () => _showPolicyDialog(
                      context,
                      'Kebijakan Privasi',
                      'Gadaikan menjaga kerahasiaan data pribadi dan dokumen sensitif seperti foto BPKB. Dokumen hanya digunakan untuk verifikasi pengajuan dan tidak ditampilkan secara publik. Prototipe ini menggunakan data dummy untuk keperluan demo.',
                    ),
                  ),
                  const Divider(),
                  _ProfileTile(
                    icon: Icons.description_outlined,
                    title: 'Syarat & Ketentuan',
                    onTap: () => _showPolicyDialog(
                      context,
                      'Syarat & Ketentuan',
                      'Seluruh perhitungan simulasi, penaksiran, dan pembayaran dalam prototipe frontend ini bersifat simulasi akademik dan bukan penawaran kredit atau transaksi keuangan resmi.',
                    ),
                  ),
                  const Divider(),
                  _ProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Gadaikan',
                    onTap: () => _showPolicyDialog(
                      context,
                      'Tentang Gadaikan',
                      'Gadaikan adalah prototipe akademik pengajuan gadai digital '
                      'untuk elektronik, emas, dan BPKB. Aplikasi ini tidak '
                      'terhubung ke lembaga gadai atau layanan pembayaran resmi '
                      'tanpa integrasi yang sah.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Center(
              child: Text(
                'Foto profil opsional belum tersedia pada prototipe ini.',
                style: AppTextStyles.caption,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'Keluar',
              icon: Icons.logout_rounded,
              foregroundColor: AppColors.danger,
              borderColor: AppColors.danger,
              onPressed: () => _confirmLogout(context),
            ),
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: Text(
                'Gadaikan v1.0 • Prototipe Frontend Flutter',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
