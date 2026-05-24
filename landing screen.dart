import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// LANDING SCREEN — shown when no menu is open
/// Two-column grid of all menus on current page.
/// No NavPanel. No numpad. Click row → open menu.
/// Matches Image 1 exactly.
/// ─────────────────────────────────────────
class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(currentPageProvider);
    final menus = page.menus;

    // Split menus into left col (first half) and right col (second half)
    // matching the original two-column layout (001-010 left, 011-020 right)
    final mid   = (menus.length / 2).ceil();
    final left  = menus.sublist(0, mid);
    final right  = menus.length > mid ? menus.sublist(mid) : <dynamic>[];

    return Column(children: [
      // ── Instruction banner (yellow) ──
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        color: AppColors.warnBg,
        child: const Text('保守体目を押下してください', style: AppText.instruction)),

      // ── Two-column menu grid ──
      Expanded(
        child: Container(
          color: AppColors.surface,
          child: LayoutBuilder(builder: (ctx, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(child: _MenuColumn(items: left, ref: ref)),
                // Vertical divider
                Container(width: 1, color: AppColors.tableBorder),
                // Right column
                Expanded(child: _MenuColumn(items: right, ref: ref)),
              ],
            );
          }),
        ),
      ),

      // ── Footer: page counter ──
      Container(
        height: 24,
        color: AppColors.rowAlt,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          const Spacer(),
          Text('${ref.watch(pageIndexProvider) + 1}/10',
            style: const TextStyle(fontFamily: AppText.mono,
              fontSize: 10, color: AppColors.textSec)),
          const SizedBox(width: 8),
        ]),
      ),
    ]);
  }
}

class _MenuColumn extends StatelessWidget {
  final List items;
  final WidgetRef ref;
  const _MenuColumn({required this.items, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final menu = items[i];
        return _MenuRow(
          code: menu.code,
          label: menu.label,
          onTap: () {
            ref.read(openMenuProvider.notifier).state = menu;
            ref.read(selectedFieldIndexProvider.notifier).state = 0;
            ref.read(fieldPageOffsetProvider.notifier).state = 0;
            ref.read(numpadStateProvider.notifier).cancel();
          },
        );
      },
    );
  }
}

class _MenuRow extends StatefulWidget {
  final String code;
  final String label;
  final VoidCallback onTap;
  const _MenuRow({required this.code, required this.label, required this.onTap});

  @override State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit:  (_) => setState(() => _hover = false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _hover ? AppColors.rowSelected : Colors.transparent,
            border: const Border(bottom: BorderSide(color: AppColors.tableBorder))),
          child: Row(children: [
            Text('${widget.code}  ', style: AppText.menuCode),
            Expanded(child: Text(widget.label, style: AppText.menuLabel,
              overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ),
    );
  }
}
