import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_color.dart';
import 'app_config.dart';
import 'cancel_btn_visible.dart';
import 'framed_icon.dart';
import 'service/app_logger.dart';
import 'service/tcp_service.dart';
import 'utility/confirm_dialog.dart';
import 'pop_out_button.dart';
import 'qr_process/qr_process_menu.dart';
import 'related_process/related_process_menu.dart';
import 'rout_config.dart';
import 'time_station.dart';
import 'utility/confirm_dialog.dart';
import 'provider/provider.dart';
import 'gen/assets.gen.dart';

/// タブの種類
const Map<String, IconData> _tabs = {
  'ＱＲ読取': Icons.qr_code,
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
    );
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
  void _goFirstTab() async {
    // 取消確認ダイアログ
    final isCancel = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(porpose: '取消'),
    );

    if (!(isCancel ?? false)) return;

    // 0xB101 送信
    try {
      if (mounted) showCustomAlertDialog(context: context, text: '処理中');
      await TcpService().sendCancel();
      AppLogger().info('MyHomePage', '取消送信完了');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      AppLogger().error('MyHomePage', '取消エラー', e);
    }

    // QR読取ページへ戻る
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
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              controller: _tabController,
              // スワイプでタブ切替無効化
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                QrProcessMenu(key: qrProcessMenu),
                RelatedProcessMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainTabMenu extends ConsumerWidget implements PreferredSizeWidget {
  final TabController controller;
  final VoidCallback onCancelPressed;

  const _MainTabMenu({required this.controller, required this.onCancelPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: IgnorePointer(
              ignoring: ref.watch(qrReadPageTabCoverProvider), //ボタン押下不可判定
              child: TabBar(
                controller: controller,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 0.1,
                indicatorColor: Colors.transparent,
                dividerHeight: 0.0,
                labelPadding: EdgeInsets.symmetric(horizontal: 12),
                splashBorderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                unselectedLabelColor: Colors.white,
                labelColor: AppColor.indigo.no700,
                tabs: [
                  for (var (index, item) in _tabs.entries.indexed)
                    Container(
                      padding: EdgeInsets.all(0),
                      height: kToolbarHeight,
                      decoration: BoxDecoration(
                        color:
                            index == controller.index
                                ? Colors.white
                                : ref.watch(qrReadPageTabCoverProvider)
                                ? AppColor.grey.no700
                                : AppColor.indigo.no700,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        border: BoxBorder.fromLTRB(
                          left: tabBorderSide,
                          top: tabBorderSide,
                          right: tabBorderSide,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(item.value, size: 32),
                                  Text(
                                    item.key,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // タブ選択中を示すインディケータをタブの内側に表示する
                          if (index == controller.index)
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 4,
                              child: Divider(
                                color: Colors.orange,
                                thickness: 3,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          _CancelBtn(onCancelPressed: onCancelPressed),
          _LogOffBtn(),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              dynamicStationName,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          ConnectionIcons(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(8);
}

class ConnectionIcons extends ConsumerWidget {
  /// 画面右上の機器接続アイコン達
  const ConnectionIcons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);

    // 1=緑(正常) -1=赤(異常)
    Color iconColor(String unit) =>
        status[unit] == 1 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            // データ集計機接続状態 (TOTALSERVER)
            FramedIcon(
              borderColor: iconColor('TOTALSERVER'),
              icon: Image.asset(
                Assets.icon.dbWord.keyName,
                width: 24,
                height: 24,
              ),
            ),
            // QRサーバ接続状態 (QRMODULE)
            FramedIcon(
              borderColor: iconColor('QRMODULE'),
              icon: Image.asset(
                Assets.icon.qRWord.keyName,
                width: 24,
                height: 24,
              ),
            ),
            // プリンタ状態 (PRINTER)
            FramedIcon(
              borderColor: iconColor('PRINTER'),
              icon: Icon(Icons.print),
            ),
          ],
        ),
      ),
    );
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
        ),
      ),
    );
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
        //ログオフ処理を削除※位置ずれが起こらないよう空間は確保
        //child: PopOutButton(
        //backgroundColors: [AppColor.blue.no50, AppColor.blue.no100],
        //foregroundColor: AppColor.indigo.no700,
        //circularValue: 20,
        //onPressed: () async {
        //// 実行確認
        //if (await showDialog<bool?>(
        //context: context,
        //builder: (context) => ConfirmDialog(porpose: _porpose),
        //)
        //case final isExecute? when isExecute && context.mounted) {
        //// ログイン画面に遷移する
        //context.goNamed(Pages.login.name);
        //}
        //},
        //child: Icon(Icons.logout, size: _btnTextStyle.fontSize! * 1.5),
        //),
      ),
    );
  }
}
