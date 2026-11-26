import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Bottom navigation bar: Beranda, Pengajuan, Riwayat, Profil.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.pendingCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: AppColors.accentGold,
              textColor: AppColors.primaryDark,
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: AppColors.accentGold,
              textColor: AppColors.primaryDark,
              child: const Icon(
                Icons.assignment_rounded,
                color: AppColors.primary,
              ),
            ),
            label: 'Pengajuan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary),
            label: 'Riwayat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
