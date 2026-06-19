import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_multidemo/provider/provider.dart';
import 'package:qr_multidemo/software_keyboard.dart';

import '../app_color.dart';
import '../pop_out_button.dart';
import '../process_completed.dart';
import '../scanner.dart';
import '../secondary_tab_content_core.dart';
import '../service/app_logger.dart';
import '../service/tcp_service.dart';
import '../to_print.dart';
import '../utility/confirm_dialog.dart';
import 'secondary_tab_content_unselected.dart';
import 'secondary_tab_menu.dart';

class QrProcessMenu extends ConsumerStatefulWidget {
  const QrProcessMenu({super.key});

  @override
  ConsumerState<QrProcessMenu> createState() => QrProcessMenuState();
}

class QrProcessMenuState extends ConsumerState<QrProcessMenu> {
  static const tabKey = GlobalObjectKey<SecondaryTabMenuForQrProcessState>(
    'qr_process_tab',
  );

  @override
  Widget build(BuildContext context) {
    // 終了タブに渡す前に値が消えないようにこのWidgetでも監視
    final _ = ref.watch(toPrintProvider);

    /// 移動時に何を印刷するか渡す
    // void gotoCompletedPrintTab(PrintSample printSample) {
    //   ref.read(toPrintProvider.notifier).changeSample(printSample);
    //   tabKey.currentState?.gotoCompletePrintTab();
    // }

    // 現在のQR読取ページの種類
    // final currentPageKind = ref.watch(qrReadPageSelectedBtnProvider);
    return SecondaryTabMenuForQrProcess(
      key: tabKey,
      tabs: [],
      // tabs: [Tab(text: 'ステータス変更'), Tab(text: '自動精算出場')],
      tabViews: [
        // Center(child: SecondaryTabContent1(onPressedButton: gotoCompleteTab)),
        // Center(
        //   child: SecondaryTabContent2(
        //     onPressedButton: () {
        //       gotoCompletedPrintTab(PrintSample.receipt);
        //     },
        //   ),
        // ),
      ],
      defaultQr: _QrReading(
        gotoQrState: (bool allEnabled) {
          tabKey.currentState?.gotoStateQrTab(allEnabled: allEnabled);
        },
      ), // _QrReading
      stateQR: SecondaryTabContentUnselected(
        onComplete: (QrReadPageBtnKind currentPageKind) {
          if (currentPageKind == QrReadPageBtnKind.seisanSyori) {
            tabKey.currentState?.gotoCompletePrintTab();
          } else {
            tabKey.currentState?.gotoCompleteTab();
          }
        },
      ), // SecondaryTabContentUnselected
      complete: ProcessCompleted(),
      completePrint: ProcessCompletedPrint(),
    ); // SecondaryTabMenuForQrProcess
  }

  void executeCancel() {
    tabKey.currentState?.gotoDefaultTab();
  }

  void gotoCompleteTab() {
    tabKey.currentState?.gotoCompleteTab();
  }
}

class _QrReading extends HookConsumerWidget {
  /// ステータス画面に移動
  ///
  /// [allEnabled]がtrueなら全てのメニューが活性
  final void Function(bool allEnabled) gotoQrState;

  const _QrReading({required this.gotoQrState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableQrReferenceButton = useState(false);
    final qrNoTextFieldController = useTextEditingController();

    final contents = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ActiveLargeButton(
            text: 'QR読取　',
            onPressed: () async {
              // 別タブに遷移した時、キーボードをしまう
              FocusManager.instance.primaryFocus?.unfocus();
              final qrData = await Navigator.of(context).push<Uint8List>(
                MaterialPageRoute(builder: (context) => const ScannerWidget()),
              );

              final qrData = await Navigator.of(context).push<Uint8List>(
                MaterialPageRoute(builder: (context) => const ScannerWidget()),
              );

              if (qrData != null && context.mounted) {
                // 照会中ダイアログ表示
                showCustomAlertDialog(context: context, text: '照会中');
                try {
                  AppLogger().info('QrReading', 'QRデータ送信: ${qrData.length}bytes');
                  // 0x1101 送信 — バイナリデータとして送信
                  final response = await TcpService().sendQrServerRequest(
                    designation: 1,
                    rawData: qrData,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                  if (response.result) {
                    AppLogger().info('QrReading', 'QR照会成功');
                    ref.read(qrTicketNoProvider.notifier).reset();
                    gotoQrState.call(true);
                  } else {
                    AppLogger().warn(
                      'QrReading',
                      'QR照会失敗: ERRCODE=${response.errCode}',
                    );
                    if (context.mounted) {
                      showCustomAlertDialog(
                        context: context,
                        text: 'QR照会失敗\nエラーコード: ${response.errCode}',
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) Navigator.of(context).pop();
                  AppLogger().error('QrReading', 'QR照会エラー', e);
                  if (context.mounted) {
                    showCustomAlertDialog(
                      context: context,
                      text: '通信エラー: $e',
                    );
                  }
                }
              }
            },
          ), // ActiveLargeButton
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'QRが読み取れない場合はQRチケット番号を入力してください',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34.0),
            ), // Text
          ), // Padding
          Container(
            width: MediaQuery.of(context).size.width,
            height: 270,
            color: Color(0xffffecce),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QRチケット番号',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28.0,
                        ), // TextStyle
                      ), // Text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      SizedBox(
                        width: 550,
                        child: TextFieldShadow(
                          topStops: [0.0, 0.15],
                          leftStops: [0.0, 0.013],
                          child: TextField(
                            controller: qrNoTextFieldController,
                            keyboardType: TextInputType.text,
                            // autocorrect: false,
                            enableSuggestions: false,
                            showCursor: false,
                            mouseCursor: SystemMouseCursors.click,
                            autofocus: false,
                            readOnly: true,
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Z0-9]'),
                              ), // FilteringTextInputFormatter.allow
                              LengthLimitingTextInputFormatter(22),
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15.0,
                                // vertical: 5.0,
                              ), // EdgeInsets.symmetric
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ), // OutlineInputBorder
                            ), // InputDecoration
                            cursorHeight: 32.0,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ), // TextStyle
                            onTap: () async {
                              final result = await showDialog<String?>(
                                context: context,
                                builder:
                                    (context) => SoftwareKeyboard(
                                      keyboardUsage: KeyboardUsage.qrTicketNo,
                                      initialText: qrNoTextFieldController.text,
                                    ), // SoftwareKeyboard
                              );
                              if (result != null) {
                                qrNoTextFieldController.text = result;
                                if (result.length >= 12) {
                                  // QRチケット番号を保存する
                                  ref
                                      .read(qrTicketNoProvider.notifier)
                                      .changeNo(result);
                                  disableQrReferenceButton.value = true;
                                } else {
                                  disableQrReferenceButton.value = false;
                                }
                              }
                            },
                            // onChange: (text) {
                            //   if (text.length >= 12) {
                            //     disableQrReferenceButton.value = true;
                            //   } else {
                            //     disableQrReferenceButton.value = false;
                            //   }
                            // },
                          ), // TextField
                        ), // TextFieldShadow
                      ), // SizedBox
                      SizedBox(width: 12),
                      SizedBox(
                        height: 65,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: orengeGradient,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.dialpad_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                            label: Text(
                              '番号入力',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: Size(160, 65),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final result = await showDialog<String?>(
                                context: context,
                                builder:
                                    (context) => SoftwareKeyboard(
                                      keyboardUsage: KeyboardUsage.qrTicketNo,
                                      initialText:
                                          qrNoTextFieldController.text,
                                    ),
                              );
                              if (result != null) {
                                qrNoTextFieldController.text = result;
                                if (result.length >= 12) {
                                  ref
                                      .read(qrTicketNoProvider.notifier)
                                      .changeNo(result);
                                  disableQrReferenceButton.value = true;
                                } else {
                                  disableQrReferenceButton.value = false;
                                }
                              }
                            },
                          ),
                        ),
                      ), // SizedBox button
                        ], // Row children
                      ), // Row
                      SizedBox(height: 25),
                    ],
                  ), // Column
                  // Column
                  // Center
                  // Container
                  // ActiveLargeButton(
                  //   text: 'QR照会　',
                  //   onPressed: () async {
                  //     // 別タブに遷移した時、キーボードをしまう
                  //     FocusManager.instance.primaryFocus?.unfocus();
                  //     // これ以外のQRコードなら全て操作可能
                  //     gotoQrState.call(true);
                  //   },
                  // ),
                  disableQrReferenceButton.value
                      ? ActiveLargeButton(
                        text: 'QR照会　',
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          showCustomAlertDialog(context: context, text: '照会中');
                          try {
                            final ticketNo = ref.read(qrTicketNoProvider);
                            AppLogger().info('QrReading', 'QR番号照会送信: $ticketNo');
                            // 0x1101 送信 — チケット番号として送信
                            final response = await TcpService().sendQrServerRequest(
                              designation: 2,
                              qrNumber: ticketNo,
                            );
                            if (context.mounted) Navigator.of(context).pop();
                            if (response.result) {
                              AppLogger().info('QrReading', 'QR照会成功');
                              gotoQrState.call(true);
                            } else {
                              AppLogger().warn(
                                'QrReading',
                                'QR照会失敗: ERRCODE=${response.errCode}',
                              );
                              if (context.mounted) {
                                showCustomAlertDialog(
                                  context: context,
                                  text: 'QR照会失敗\nエラーコード: ${response.errCode}',
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) Navigator.of(context).pop();
                            AppLogger().error('QrReading', 'QR照会エラー', e);
                            if (context.mounted) {
                              showCustomAlertDialog(
                                context: context,
                                text: '通信エラー: $e',
                              );
                            }
                          }
                        },
                      )
                              '000000 0000 0000 0000 0000') {
                            // 照会失敗ダイアログ
                            if (context.mounted) {
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return CustomConfirmDialog(
                                    text: '照会に失敗しました',
                                    trueBtnText: '確認',
                                    hasFalseBtn: false,
                                  ); // CustomConfirmDialog
                                },
                              );
                            }
                          } else {
                            // これ以外のQRコードなら全て操作可能
                            gotoQrState.call(true);
                          }
                        },
                      ) // ActiveLargeButton
                      : InactiveLargeButton(text: 'QR照会'),
                ], // <Widget>[]
              ), // Column
            ),
          ),
        ],
      ), // Center
    ); // Center

    // 上下中央ぞろえにする
    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            reverse: true,
            // controller: scrollController,
            // physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: contents,
            ), // ConstrainedBox
          ), // SingleChildScrollView
    ); // LayoutBuilder
  }
}

// ボタンのサイズを変更する
class SizedButton extends StatelessWidget {
  const SizedButton({required this.child, super.key});

  final Widget child;

  // final bool isLargeSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 65.0, width: 220.0, child: child);

    // return switch (isLargeSize) {
    //   true => SizedBox(height: 65.0, width: 220.0, child: child),
    //   _ => SizedBox(height: 65.0, width: 220.0, child: child),
    // };
  }
}

// 活性化した大きいボタン
class ActiveLargeButton extends StatelessWidget {
  const ActiveLargeButton({
    required this.text,
    required this.onPressed,
    this.btnBaseColor = orengeGradient,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final List<Color> btnBaseColor;

  @override
  Widget build(BuildContext context) {
    return SizedButton(
      child: PopOutButton(
        backgroundColors: btnBaseColor,
        foregroundColor: Colors.black,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30.0),
              ), // Text
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: Colors.black,
                size: 24,
              ), // Icon
            ],
          ), // Row
        ), // Padding
      ), // PopOutButton
    ); // SizedButton
  }
}

// 非活性の大きいボタン
class InactiveLargeButton extends StatelessWidget {
  const InactiveLargeButton({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedButton(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xfffc8c8c),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ), // RoundedRectangleBorder
          overlayColor: Color(0xfffc8c8c),
        ),
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                  color: Color(0xff969696),
                ), // TextStyle
              ), // Text
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: Color(0xff969696),
                size: 20,
              ), // Icon
            ],
          ), // Row
        ), // Padding
      ), // ElevatedButton
    ); // SizedButton
  }
}
