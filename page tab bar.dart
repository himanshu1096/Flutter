import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// Bottom tab bar — 保守メニュー1ページ ... 保守メニュー10ページ
/// matching original system bottom tabs
class PageTabBar extends ConsumerStatefulWidget {
  const PageTabBar({super.key});
  @override ConsumerState<PageTabBar> createState() => _PageTabBarState();
}

class _PageTabBarState extends ConsumerState<PageTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: 10, vsync: this);
    _ctrl.addListener(() {
      if (!_ctrl.indexIsChanging) {
        ref.read(pageIndexProvider.notifier).state = _ctrl.index;
        ref.read(openMenuProvider.notifier).state = null;
        ref.read(selectedFieldIndexProvider.notifier).state = 0;
        ref.read(fieldPageOffsetProvider.notifier).state = 0;
        ref.read(numpadStateProvider.notifier).cancel();
      }
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final idx = ref.watch(pageIndexProvider);
    if (_ctrl.index != idx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _ctrl.index != idx) _ctrl.animateTo(idx);
      });
    }

    return Container(
      height: 28,
      color: const Color(0xFFCDD5DF),
      child: TabBar(
        controller: _ctrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.accent,
        indicatorWeight: 2,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSec,
        dividerColor: AppColors.tableBorder,
        labelStyle: const TextStyle(fontFamily: AppText.mono, fontSize: 9, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: AppText.mono, fontSize: 9),
        tabs: List.generate(10, (i) => Tab(height: 28,
          child: Text('保守メニュー${i+1}ページ'))),
      ),
    );
  }
}
