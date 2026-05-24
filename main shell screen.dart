import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/page_tab_bar.dart';
import 'landing_screen.dart';
import 'menu_detail_screen.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openMenu = ref.watch(openMenuProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          const AppHeader(),
          Expanded(
            child: openMenu == null
                ? const LandingScreen()
                : const MenuDetailScreen(),
          ),
          // ── Page tabs ONLY on landing screen ──
          if (openMenu == null) const PageTabBar(),
        ]),
      ),
    );
  }
}
