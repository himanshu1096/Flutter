import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_color.dart';
import 'gen/assets.gen.dart';
import 'my_home_page.dart';
import 'pop_out_button.dart';
import 'qr_process/windows_print.dart';
import 'sii_url_print.dart';
import 'to_print.dart';
import 'utility/confirm_dialog.dart';

class ProcessCompleted extends StatelessWidget {
  const ProcessCompleted({super.key, this.onCompleteButtonPressed});

  /// 完了ボタン押下時に実行する処理
  final VoidCallback? onCompleteButtonPressed;

  @override
  Widget build(BuildContext context) {
    return _ProcessCompleteBase(
      onCompleteButtonPressed: onCompleteButtonPressed,
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
        ); // _ProcessCompleteBase
      },
    ); // Consumer
  }
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
    this.completeButtonLabel = '確認　',
    this.onCompleteButtonPressed,
    this.displayFinishButton = false,
  });

  final String message;
  final String completeButtonLabel;
  final VoidCallback? onCompleteButtonPressed;
  final bool displayFinishButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 250,
            color: Color(0xfffffece),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  message,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                  textAlign: TextAlign.center,
                ), // Text
                if (completeButtonLabel.isNotEmpty) ...[
                  SizedBox(height: 50),
                  ProcessCompletedButton(
                    icon: FontAwesomeIcons.check,
                    backgroundColors: completedGradient,
                    onPressed: onCompleteButtonPressed,
                    text: completeButtonLabel,
                  ), // ProcessCompletedButton
                ],
              ],
            ), // Column
          ), // Container
        ), // Center
        if (displayFinishButton)
          Positioned(
            bottom: 20,
            right: 12,
            child: ProcessCompletedButton(
              icon: FontAwesomeIcons.xmark,
              backgroundColors: [Color(0xff566779), Color(0xff485462)],
              text: '終了　',
            ),
          ), // Positioned
      ],
    ); // Stack
  }
}

class ProcessCompletedButton extends StatelessWidget {
  const ProcessCompletedButton({
    super.key,
    this.onPressed,
    required this.backgroundColors,
    required this.text,
    required this.icon,
  });

  final List<Color> backgroundColors;
  final VoidCallback? onPressed;
  final String text;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
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
          HomeTabData.of(context).goFirstTab();
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: FaIcon(icon, color: backgroundColors[0], size: 20),
              ), // CircleAvatar
            ), // Padding
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ), // TextStyle
                ), // Text
              ), // Center
            ), // Expanded
          ],
        ), // Row
      ), // PopOutButton
    ); // Container
  }
}
