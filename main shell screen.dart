import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/app_footer.dart';
import '../widgets/nav_panel.dart';
import '../widgets/numpad_overlay.dart';
import 'welcome_screen.dart';
import 'menu_detail_screen.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openMenu   = ref.watch(openMenuProvider);
    final numpadOpen = ref.watch(numpadProvider).isOpen;

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF4),
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, constraints) {
          // Nav panel width — hidden when numpad is open to avoid overflow
          final showNav  = !numpadOpen;
          final navWidth = constraints.maxWidth < 600 ? constraints.maxWidth * 0.30 : 200.0;

          return Column(children: [
            const AppHeader(),
            AppTabBar(totalWidth: constraints.maxWidth),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left nav — hidden when numpad open
                  if (showNav)
                    SizedBox(width: navWidth, child: const NavPanel()),

                  // Content area — takes full width when numpad open
                  Expanded(
                    child: Stack(
                      children: [
                        openMenu == null
                            ? const WelcomeScreen()
                            : const MenuDetailScreen(),
                        // Numpad slides in from right, content stays visible
                        if (numpadOpen) const NumpadOverlay(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const AppFooter(),
          ]);
        }),
      ),
    );
  }
}
