import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIdx = ref.watch(currentPageIndexProvider);
    final pages   = ref.watch(allPagesProvider);
    final page    = ref.watch(currentPageProvider);

    return Container(
      height: 26,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        Text('PAGE ${pageIdx + 1} / ${pages.length}  —  ${page.menus.length} items',
          style: const TextStyle(fontFamily: AppText.mono, fontSize: 8, color: Color(0xFF3A5A7A))),
        const Spacer(),
        _NavBtn('◀', () {
          if (pageIdx > 0) {
            ref.read(currentPageIndexProvider.notifier).state = pageIdx - 1;
            ref.read(openMenuProvider.notifier).state = null;
          }
        }),
        const SizedBox(width: 4),
        _NavBtn('▶', () {
          if (pageIdx < pages.length - 1) {
            ref.read(currentPageIndexProvider.notifier).state = pageIdx + 1;
            ref.read(openMenuProvider.notifier).state = null;
          }
        }),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 24, height: 20,
      decoration: BoxDecoration(
        color: AppColors.accentLight.withOpacity(0.15),
        border: Border.all(color: AppColors.accentLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(3)),
      alignment: Alignment.center,
      child: Text(label,
        style: const TextStyle(fontFamily: AppText.mono, fontSize: 9, color: AppColors.accentLight)),
    ),
  );
}
