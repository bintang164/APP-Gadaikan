import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../history/screens/history_screen.dart';
import '../../pawn/screens/application_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  static const String routeName = '/main';

  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final pages = [
      HomeScreen(
        onNavigateTab: _switchTab,
      ),
      const ApplicationListScreen(),
      HistoryScreen(
        onStartNewApplication: () => _switchTab(1),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _switchTab,
        pendingCount: appState.pendingApplicationCount,
      ),
    );
  }
}
