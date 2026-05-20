import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({super.key});
  @override ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  String _time = '';
  @override void initState() { super.initState(); _tick(); }
  void _tick() {
    if (!mounted) return;
    final n = DateTime.now();
    setState(() => _time =
      '${n.year}.${_p(n.month)}.${_p(n.day)} ${_p(n.hour)}:${_p(n.minute)}:${_p(n.second)}');
    Future.delayed(const Duration(seconds: 1), _tick);
  }
  String _p(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final page     = ref.watch(currentPageProvider);
    final openMenu = ref.watch(openMenuProvider);
    final conn     = ref.watch(connectionStatusProvider);

    return Container(
      height: 38,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        // Logo
        Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text('保守メニュー', style: AppText.headerTitle),
        const SizedBox(width: 8),
        // Breadcrumb
        const Text('›', style: TextStyle(color: Color(0xFF2A3A50), fontFamily: AppText.mono)),
        const SizedBox(width: 6),
        Text(page.label,
          style: const TextStyle(fontFamily: AppText.mono, fontSize: 10, color: Color(0xFF6A8AAA))),
        if (openMenu != null) ...[
          const Text('  ›  ', style: TextStyle(color: Color(0xFF2A3A50), fontFamily: AppText.mono, fontSize: 10)),
          Flexible(child: Text(openMenu.label,
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 10, color: AppColors.accentLight),
            overflow: TextOverflow.ellipsis)),
        ],
        const Spacer(),
        // Connection
        conn.when(
          data: (ok) => _Pill(ok ? 'ONLINE' : 'OFFLINE', ok ? AppColors.success : AppColors.danger),
          loading:   () => const _Pill('...', AppColors.warn),
          error: (_, __) => const _Pill('ERR', AppColors.danger),
        ),
        const SizedBox(width: 8),
        Text(_time, style: const TextStyle(fontFamily: AppText.mono, fontSize: 9, color: Color(0xFF4A6A8A))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              border: Border.all(color: AppColors.danger.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(3)),
            child: const Text('ログオフ',
              style: TextStyle(fontFamily: AppText.mono, fontSize: 9,
                color: Color(0xFFE07070), fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      border: Border.all(color: color.withOpacity(0.35)),
      borderRadius: BorderRadius.circular(100)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 5, height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontFamily: AppText.mono, fontSize: 8, color: color)),
    ]),
  );
}
