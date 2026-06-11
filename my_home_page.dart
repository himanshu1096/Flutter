import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_color.dart';
import 'app_config.dart';
import 'cancel_btn_visible.dart';
import 'framed_icon.dart';
import 'pop_out_button.dart';
import 'qr_process/qr_process_menu.dart';
import 'related_process/related_process_menu.dart';
import 'rout_config.dart';
import 'time_station.dart';
import 'utility/confirm_dialog.dart';

/// タブの種類
const Map<String, IconData> _tabs = {
  'QR読取': Icons.qr_code,
  '関連業務': Icons.library_books,
};

/// ボタンのテキスト・スタイル
const TextStyle _btnTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w900,
);

/// 第一タブのデータを子Widgetから参照できるようにする
class HomeTabData extends InheritedWidget {
  const HomeTabData({
    super.key,
    required this.goFirstTab,
    required super.child,
  });

  /// 最初のタブを表示する
  final VoidCallback goFirstTab;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  /// ツリー上から第一タブのデータを取得する
  static HomeTabData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeTabData>()!;
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with TickerProviderStateMixin {
  static const qrProcessMenu = GlobalObjectKey<QrProcessMenuState>(
    'QrProcessMenuState',
  );

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      animationDuration: Duration(seconds: 0),
    ); // TabController
    _tabController.addListener(() {
      // 関連業務のときは、「取消」ボタンを表示する
      if (_tabController.index == 1) {
        ref.read(cancelBtnVisibleProvider.notifier).change(true);
      }
      // 上記以外のときは、「取消」ボタンを表示しない
      else {
        ref.read(cancelBtnVisibleProvider.notifier).change(false);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 最初のタブを表示する
  void _goFirstTab() {
    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
    qrProcessMenu.currentState?.executeCancel();
  }

  @override
  Widget build(BuildContext context) {
    return HomeTabData(
      goFirstTab: _goFirstTab,
      child: GestureDetector(
        // テキストフィールド以外をタップしたらキーボードを閉じる
        onTap: () {
          primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            bottom: _MainTabMenu(
              controller: _tabController,
              onCancelPressed: _goFirstTab,
            ), // _MainTabMenu
          ), // AppBar
          body: SafeArea(
            child: TabBarView(
              controller: _tabController,
              // スワイプでタブ切替無効化
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                QrProcessMenu(key: qrProcessMenu),
                RelatedProcessMenu(),
              ], // <Widget>[]
            ), // TabBarView
          ), // SafeArea
        ), // Scaffold
      ), // GestureDetector
    ); // HomeTabData
  }
}

class _MainTabMenu extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final VoidCallback onCancelPressed;

  const _MainTabMenu({required this.controller, required this.onCancelPressed});

  @override
  Widget build(BuildContext context) {
    final tabBorderSide = BorderSide(
      color: AppColor.indigo.no700,
      width: 2,
      strokeAlign: BorderSide.strokeAlignOutside,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // TimeStation(),
          TimeView(),
          Expanded(
            flex: 3,
            child: TabBar(
              controller: controller,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 0.1,
              indicatorColor: Colors.transparent,
              dividerHeight: 0.0,
              labelPadding: EdgeInsets.symmetric(horizontal: 12),
              splashBorderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ), // BorderRadius.vertical
              unselectedLabelColor: Colors.white,
              labelColor: AppColor.indigo.no700,
              tabs: [
                for (var (index, item) in _tabs.entries.indexed)
                  Container(
                    padding: EdgeInsets.all(0),
                    height: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: index == controller.index
                          ? Colors.white
                          : AppColor.indigo.no700,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ), // BorderRadius.vertical
                      border: BoxBorder.fromLTRB(
                        left: tabBorderSide,
                        top: tabBorderSide,
                        right: tabBorderSide,
                      ), // BoxBorder.fromLTRB
                    ), // BoxDecoration
                    child: Stack(
                      children: [
                        Center(
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(item.value, size: 32),
                                Text(item.key, style: TextStyle(fontSize: 24)),
                              ],
                            ), // Row
                          ), // FittedBox
                        ), // Center
                        // タブ選択中を示すインディケータをタブの内側に表示する
                        if (index == controller.index)
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 4,
                            child: Divider(color: Colors.orange, thickness: 3),
                          ), // Positioned
                      ],
                    ), // Stack
                  ), // Container
              ],
            ), // TabBar
          ), // Expanded
          _CancelBtn(onCancelPressed: onCancelPressed),
          _LogOffBtn(),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(stationName, style: const TextStyle(fontSize: 20)),
          ), // Padding
          ConnectionIcons(),
        ],
      ), // Row
    ); // Padding
  }

  @override
  Size get preferredSize => Size.fromHeight(8);
}

class ConnectionIcons extends StatelessWidget {
  /// 画面右上の機器接続アイコン達
  const ConnectionIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            FramedIcon(icon: Icon(Icons.storage)),
            FramedIcon(icon: Icon(Icons.qr_code)),
            FramedIcon(icon: Icon(Icons.print)),
          ],
        ), // Row
      ), // SizedBox
    ); // Padding
  }
}

class _CancelBtn extends ConsumerWidget {
  final VoidCallback onCancelPressed;

  /// 取り消しボタン
  const _CancelBtn({required this.onCancelPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(cancelBtnVisibleProvider),
      child: Container(
        height: kToolbarHeight,
        width: 180,
        padding: const EdgeInsets.only(bottom: 8, left: 16),
        child: PopOutButton(
          backgroundColors: [AppColor.blue.no50, AppColor.blue.no100],
          foregroundColor: AppColor.indigo.no700,
          onPressed: onCancelPressed,
          child: Text('取消 >', style: _btnTextStyle),
        ), // PopOutButton
      ), // Container
    ); // Visibility
  }
}

class _LogOffBtn extends ConsumerWidget {
  /// ログオフボタン
  const _LogOffBtn();

  /// 何を実行するか
  static const String _porpose = "ログオフ";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: !ref.watch(cancelBtnVisibleProvider),
      child: Container(
        height: kToolbarHeight,
        width: 180,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(bottom: 8, left: 16),
        child: PopOutButton(
          backgroundColors: [AppColor.blue.no50, AppColor.blue.no100],
          foregroundColor: AppColor.indigo.no700,
          circularValue: 20,
          onPressed: () async {
            // 実行確認
            if (await showDialog<bool?>(
                  context: context,
                  builder: (context) => ConfirmDialog(porpose: _porpose),
                )
                case final isExecute? when isExecute && context.mounted) {
              // ログイン画面に遷移する
              context.goNamed(Pages.login.name);
            }
          },
          child: Icon(Icons.logout, size: _btnTextStyle.fontSize! * 1.5),
        ), // PopOutButton
      ), // Container
    ); // Visibility
  }
}
