import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

class NavPanel extends ConsumerWidget {
  const NavPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page     = ref.watch(currentPageProvider);
    final openMenu = ref.watch(openMenuProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        border: Border(right: BorderSide(color: Color(0xFF0F1826), width: 1))),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFF1A2540),
          width: double.infinity,
          child: Text('< 保守メニュー ${page.label}',
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 8,
              color: Color(0xFF4A6A90), letterSpacing: 1),
            overflow: TextOverflow.ellipsis),
        ),
        // Menu list
        Expanded(child: ListView.builder(
          itemCount: page.menus.length,
          itemBuilder: (ctx, i) {
            final menu   = page.menus[i];
            final active = openMenu?.code == menu.code;
            return GestureDetector(
              onTap: () {
                ref.read(openMenuProvider.notifier).state = active ? null : menu;
                ref.read(numpadProvider.notifier).close();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppColors.navActive.withOpacity(0.2) : Colors.transparent,
                  border: Border(
                    left: BorderSide(color: active ? AppColors.accentLight : Colors.transparent, width: 3),
                    bottom: const BorderSide(color: Color(0xFF1A2540), width: 0.5))),
                child: Row(children: [
                  Text(menu.code,
                    style: TextStyle(fontFamily: AppText.mono, fontSize: 9,
                      color: active ? const Color(0xFF7AB8E0) : const Color(0xFF4A6A90),
                      fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(menu.label,
                    style: TextStyle(fontSize: 10,
                      color: active ? const Color(0xFFD0E8F8) : AppColors.textOnNav),
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
}
