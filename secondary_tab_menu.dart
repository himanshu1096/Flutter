import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cancel_btn_visible.dart';
import '../secondary_tab_menu_common.dart';

/// 画面遷移用追加タブ
enum _AdditionalTab {
  defaultQr(viewName: 'QR読取'),
  stateQr(viewName: '読取後'),
  complete(viewName: '処理完了！'),
  completePrint(viewName: '完了印刷');

  final String viewName;

  const _AdditionalTab({required this.viewName});
}

/// QR処理のタブ
enum _QrProcessTab { status, autoSettle, manualSettle, reimburse }

class SecondaryTabMenuForQrProcess extends ConsumerStatefulWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;

  /// QR読み込みボタン
  final Widget defaultQr;

  final Widget stateQR;

  final Widget complete;
  final Widget completePrint;

  const SecondaryTabMenuForQrProcess({
    super.key,
    required this.tabs,
    required this.tabViews,
    required this.defaultQr,
    required this.stateQR,
    required this.complete,
    required this.completePrint,
  });

  @override
  ConsumerState<SecondaryTabMenuForQrProcess> createState() =>
      SecondaryTabMenuForQrProcessState();
}

class SecondaryTabMenuForQrProcessState
    extends ConsumerState<SecondaryTabMenuForQrProcess>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final List<Widget> _tabViews;

  /// 活性非活性
  late List<bool> _canSelect;

  @override
  void initState() {
    super.initState();
    _tabViews = [
      ...widget.tabViews,
      widget.defaultQr,
      widget.stateQR,
      widget.complete,
      widget.completePrint,
    ];

    // はじめは全て非活性/[]
    _changeAllCanSelect(false);
    _tabController = TabController(
      length: _tabViews.length,
      animationDuration: tabAnimationDuration,
      vsync: this,
      initialIndex: widget.tabs.length,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SecondayTabMenuCommon(
      tabController: _tabController,
      onTap: (tabIndex) {
        // 活性なら移動、非活性なら移動しない
        _tabController.index =
            _canSelect[tabIndex] ? tabIndex : _tabController.previousIndex;
      },
      tabs: [
        for (var entry in widget.tabs.asMap().entries)
          SecondaryTabContainer(
            tab: entry.value,
            isFirst: entry.key == 0,
            // 完了画面表示時もプロセス選択中表示にする為の判定
            isProcessing:
                _tabController.index > widget.tabs.length &&
                _tabController.previousIndex == entry.key,
          ),
      ],
      tabViews: _tabViews,
    );
  }

  /// 全ての選択可能タブに同じ値を設定
  void _changeAllCanSelect(bool canSelect) {
    _canSelect = List.filled(_tabViews.length, canSelect);
  }

  void goto(int index) {
    _tabController.index = index;
  }

  /// QRコード読み込みタブに移動
  void gotoDefaultTab() {
    goto(widget.tabs.length + _AdditionalTab.defaultQr.index);
    // 取り消しボタンを非表示
    ref.read(cancelBtnVisibleProvider.notifier).change(false);
    // 選択可能タブをリセット
    setState(() {
      _changeAllCanSelect(false);
    });
  }

  /// ステータス画面に移動
  ///
  /// [allEnabled]がtrueなら全てのメニューが活性
  void gotoStateQrTab({bool allEnabled = true}) {
    goto(widget.tabs.length + _AdditionalTab.stateQr.index);
    // 取り消しボタンを表示
    ref.read(cancelBtnVisibleProvider.notifier).change(true);
    // 選択可能タブを設定
    setState(() {
      if (allEnabled) {
        _changeAllCanSelect(true);
      } else {
        // 手入力精算出場、払戻を非活性とする
        for (var process in _QrProcessTab.values) {
          switch (process) {
            case _QrProcessTab.status:
            case _QrProcessTab.autoSettle:
              _canSelect[process.index] = true;
              break;
            case _QrProcessTab.manualSettle:
            case _QrProcessTab.reimburse:
              _canSelect[process.index] = false;
              break;
          }
        }
      }
    });
  }

  void gotoCompleteTab() {
    goto(widget.tabs.length + _AdditionalTab.complete.index);
    // 取り消しボタンを非表示
    ref.read(cancelBtnVisibleProvider.notifier).change(false);
    // 選択中タブ色反映の為、リビルドする
    setState(() {
      // タップでのタブ選択不可
      _changeAllCanSelect(false);
    });
  }

  void gotoCompletePrintTab() {
    goto(widget.tabs.length + _AdditionalTab.completePrint.index);
    // 取り消しボタンを非表示
    ref.read(cancelBtnVisibleProvider.notifier).change(false);
    // 選択中タブ色反映の為、リビルドする
    setState(() {
      // タップでのタブ選択不可
      _changeAllCanSelect(false);
    });
  }
}
