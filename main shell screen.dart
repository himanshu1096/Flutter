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
          final w = constraints.maxWidth;

          // Nav panel width — hidden completely when numpad opens
          // so the field list gets the full width and values stay visible
          final showNav  = !numpadOpen;
          final navWidth = w < 600 ? w * 0.30 : 200.0;

          // When numpad is open, MenuDetailScreen gets full width minus
          // the 240px numpad. Fields shift left automatically via Expanded.
          return Column(children: [
            const AppHeader(),
            AppTabBar(totalWidth: w),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left nav — hidden when numpad open
                  if (showNav)
                    SizedBox(width: navWidth, child: const NavPanel()),

                  // Content area — fills all remaining space
                  // When numpad opens: full width available, numpad overlaps right 240px
                  // Field rows use Expanded so label+value compress left, staying visible
                  Expanded(
                    child: Stack(
                      children: [
                        openMenu == null
                            ? const WelcomeScreen()
                            : const MenuDetailScreen(),

                        // Numpad anchored to right edge of content area
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
