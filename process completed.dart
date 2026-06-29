import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'app_color.dart';
import 'service/sound_service.dart';
import 'gen/assets.gen.dart';
import 'my_home_page.dart';
import 'pop_out_button.dart';
import 'qr_process/windows_print.dart';
import 'sii_url_print.dart';
import 'to_print.dart';
import 'utility/confirm_dialog.dart';
import 'provider/provider.dart';

class ProcessCompleted extends StatefulWidget {
  const ProcessCompleted({super.key, this.onCompleteButtonPressed});

  /// 完了ボタン押下時に実行する処理
  final VoidCallback? onCompleteButtonPressed;

  @override
  State<ProcessCompleted> createState() => _ProcessCompletedState();
}

class _ProcessCompletedState extends State<ProcessCompleted> {
  @override
  void initState() {
    super.initState();
    // 処理完了音を再生
    SoundService().playComplete();
  }

  @override
  Widget build(BuildContext context) {
    return _ProcessCompleteBase(
      onCompleteButtonPressed: widget.onCompleteButtonPressed,
    );
  }
}

class ProcessCompletedPrint extends StatelessWidget {
  const ProcessCompletedPrint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final printSample = ref.watch(toPrintProvider);

        return _ProcessCompleteBase(
          completeButtonLabel: '領収書発行 ',
          onCompleteButtonPressed: () async {
            if (Platform.isWindows) {
              // 印刷中ダイアログを表示する
              showCustomAlertDialog(context: context, text: '印刷中', closeSec: 3);
              // 印刷データを取得
              final pdfData = await loadPdfFromAssets(type: printSample);
              // 印刷する
              await CardInfoPrint().printPdfDocument(pdfData: pdfData);
            } else if (Platform.isAndroid) {
              await printJournal(printSample);
            }
          },
          displayFinishButton: true,
          move: false,
        );
      },
    );
  }

  Future<Uint8List> loadPdfFromAssets({required PrintSample type}) async {
    final printUrl = switch (type) {
      PrintSample.receipt => Assets.printSample.receipt,
      PrintSample.reimburse => Assets.printSample.reimburse,
    };
    return await rootBundle
        .load(printUrl)
        .then((data) => data.buffer.asUint8List());
  }
}

class ProcessFailed extends StatelessWidget {
  const ProcessFailed({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProcessCompleteBase(
      message: "処理に失敗しました。",
      completeButtonLabel: "",
      displayFinishButton: true,
    );
  }
}

class _ProcessCompleteBase extends StatelessWidget {
  const _ProcessCompleteBase({
    this.message = '処理が完了しました。',
    this.completeButtonLabel = '確認   ',
    this.onCompleteButtonPressed,
    this.displayFinishButton = false,
    this.move = true,
  });

  final String message;

  final String completeButtonLabel;

  final VoidCallback? onCompleteButtonPressed;

  final bool displayFinishButton;

  final bool move;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Consumer(
      builder: (context, ref, child) {
        ref.watch(printerCreatedProvider);

        return Stack(
          children: [
            if (displayFinishButton)
              Positioned(
                top: 20,
                left: 12,
                height: 160,
                width: 1100,

                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '領 収 書 情 報 ',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 80,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '　領 収 金 額 : ',
                              style: TextStyle(
                                fontSize: 45.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.red, // 下線の色
                                width: 4.0, // 下線の太さ
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatter.format(230),
                                style: TextStyle(
                                  fontSize: 45.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('円', style: TextStyle(fontSize: 34.0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                color: Color(0xffffecce),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (completeButtonLabel.isNotEmpty) ...[
                      SizedBox(height: 50),
                      ProcessCompletedButton(
                        icon: FontAwesomeIcons.check,
                        backgroundColors:
                            ref.read(printerCreatedProvider)
                                ? completedGradient
                                : grayGradient,
                        onPressed:
                            ref.read(printerCreatedProvider)
                                ? onCompleteButtonPressed
                                : null,
                        text: completeButtonLabel,
                        move: move,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (displayFinishButton)
              Positioned(
                bottom: 20,
                right: 12,
                child: ProcessCompletedButton(
                  icon: FontAwesomeIcons.xmark,
                  backgroundColors: [Color(0xff566779), Color(0xff485462)],
                  text: '終了   ',
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProcessCompletedButton extends StatelessWidget {
  const ProcessCompletedButton({
    super.key,
    this.onPressed,
    required this.backgroundColors,
    required this.text,
    required this.icon,
    this.move = true,
  });

  final List<Color> backgroundColors;

  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final bool move;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          height: 55.0,
          width: 225.0,
          padding: const EdgeInsets.only(right: 18),
          child: PopOutButton(
            backgroundColors: backgroundColors,
            onPressed: () {
              // 処理の指定があれば実行
              onPressed?.call();
              // 最初のタブを表示する
              move ? HomeTabData.of(context).goFirstTab() : null;
              ref.read(printerCreatedProvider.notifier).set(false);
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: Icon(icon, color: backgroundColors[0], size: 20),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
