import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

class AppTabBar extends ConsumerStatefulWidget {
  final double totalWidth;
  const AppTabBar({super.key, required this.totalWidth});
  @override ConsumerState<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends ConsumerState<AppTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: 10, vsync: this);
    _ctrl.addListener(() {
      if (!_ctrl.indexIsChanging) {
        ref.read(currentPageIndexProvider.notifier).state = _ctrl.index;
        ref.read(openMenuProvider.notifier).state = null;
        ref.read(numpadProvider.notifier).close();
      }
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pageIdx = ref.watch(currentPageIndexProvider);
    if (_ctrl.index != pageIdx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _ctrl.index != pageIdx) _ctrl.animateTo(pageIdx);
      });
    }
    final pages     = ref.watch(allPagesProvider);
    final scrollable = widget.totalWidth < 700;

    return Container(
      height: 30,
      color: AppColors.surface2,
      child: TabBar(
        controller: _ctrl,
        isScrollable: scrollable,
        tabAlignment: scrollable ? TabAlignment.start : TabAlignment.fill,
        indicatorColor: AppColors.accent,
        indicatorWeight: 2.5,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textDim,
        dividerColor: AppColors.border,
        labelStyle: AppText.tabLabel,
        unselectedLabelStyle: AppText.tabLabel.copyWith(fontWeight: FontWeight.normal),
        tabs: pages.map((p) => Tab(height: 30,
          child: Text(p.label))).toList(),
      ),
    );
  }
}
