import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_multidemo/qr_process/windows_print.dart';
import 'package:qr_multidemo/utility/confirm_dialog.dart';
import 'package:qr_multidemo/utility/constant.dart';

import 'app_color.dart';
import 'pop_out_button.dart';
import 'provider/provider.dart';
import 'qr_process/qr_process_menu.dart';

const Color backGroundColor = Color(0xFFF4F4F4);
const Color titleColor = Color(0xFF233B77);
const double fontSize = 28;
const TextStyle titleTextStyle = TextStyle(
  fontSize: fontSize,
  color: titleColor,
  fontWeight: FontWeight.w600,
);

// class CardInfo {
//   static String baitaiSyubetu = '普通券（QR）';
//   static String yukoSyuryoubi = '06/30';
//   static String hatueki = '朝霞';
//   static String hatuekiKusu = '16';
//   static String renrakueki = '和光市';
//   static String renrakuekiKusu = '18';
//   static String zyosyaeki = '朝霞';
//   static String nyusyutuzyoBit = '1';
//   static String zyosyaTukihi = '06/30';
//   static String zyosyaZikoku = '10:00';
// }

enum CardInfoEnum {
  qrYukoMukoStatus('QR有効/無効ステータス', '有効(自動処理不可)'),
  qrHakkouStatus('QR発行ステータス', 'QRチケット破棄済'),
  siyouStatus('使用ステータス', '未使用'),
  nyuusyutuzyouStatus('入出場ステータス', '未使用'),
  baitaiSyubetu('媒体種別', '普通券（QR）'),
  yukoSyuryoubi('有効終了日', '06/30'),
  hatueki('発駅', '朝霞'),
  hatuekiKusu('発駅区数', '16'),
  renrakueki('連絡駅', '和光市'),
  renrakuekiKusu('連絡駅区数', '18'),
  zyosyaeki('乗車駅', '朝霞', anotherName: '乗降駅'),
  nyusyutuzyoBit('入出場状態', '入場', anotherName: '入出場状態'),
  // nyusyutuzyoBit('入出場ビット', '1', anotherName: '入出場状態'),
  zyosyaTukihi('乗車月日', '06/30'),
  zyosyaZikoku('乗車時刻', '10:00'),
  keiyu1('経由１', ''),
  keiyu2('経由２', ''),
  keiyu3('経由３', ''),
  keiyu4('経由４', ''),
  kensyu('券種', '0'),
  kensyu2('券種２', '2C'),
  kensyu2Detail1('券種２の詳細１', '併割あり'),
  kensyu2Detail2('券種２の詳細２', '高保磁あり、連絡あり'),
  empty('', '');

  final String name;
  final String value;
  final String anotherName;

  const CardInfoEnum(this.name, this.value, {this.anotherName = ''});

  String getAnotherName() => anotherName.isEmpty ? name : anotherName;

  (String, String) getTuple() {
    return (name, value);
  }
}

class SecondaryTabContentBase extends ConsumerWidget {
  const SecondaryTabContentBase({
    super.key,
    required this.contentTop,
    // required this.cardInformation,
  });

  final Widget contentTop;

  // final List<CardInformation> cardInformation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    double horizontalPadding = screenWidth * 0.02;
    double topPadding = 30;
    // final TextStyle _btnTextStyle = TextStyle(fontSize: fontSize);

    return Padding(
      padding: EdgeInsets.only(
        right: horizontalPadding,
        left: horizontalPadding,
        top: topPadding,
      ), // EdgeInsets.only
      child: contentTop,
    ); // Padding
  }
}

class CardInformation {
  final String title;
  final List<Widget> content;

  CardInformation({required this.title, required this.content});
}

class CardInformationMethod {
  Widget getBodyTextGroup(List<Widget> textList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textList,
    );
  }

  Widget getBodyText(String key, String value) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.black,
            ), // TextStyle
          ), // TextSpan
          TextSpan(
            text: ' ：',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.black,
            ), // TextStyle
          ), // TextSpan
          TextSpan(
            text: value,
            style: TextStyle(fontSize: fontSize, color: Colors.black),
          ), // TextSpan
        ], // <TextSpan>[]
      ), // TextSpan
    ); // RichText
  }
}

// 情報表示ページのフッター部分
class ZyouhoHyouziFooter extends ConsumerWidget {
  const ZyouhoHyouziFooter({super.key});

  // タイトル文字列の表示幅
  static double titleStrWidth = 230;
  static double titleStrHeight = 32;

  // 各項目名の幅
  static double itemStrWidth = 160;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // QRチケット番号
    final qrTicketNo = ref.watch(qrTicketNoProvider);

    final TextStyle btnTextStyle = TextStyle(fontSize: fontSize);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Stack(
        children: [
          Align(alignment: Alignment.center, child: _DetailInfoButton()),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              child: PopOutButton.icon(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.check_circle),
                ), // Padding
                iconSize: fontSize,
                backgroundColors: completedGradient,
                onPressed: () async {
                  if (Platform.isWindows) {
                    // 印刷中ダイアログを表示する
                    showCustomAlertDialog(context: context, text: '印刷中');
                    try {
                      // 印刷する内容を取得する
                      final contents = getTicketContents(
                        qrTicketNo: qrTicketNo,
                      );
                      // 印刷する
                      await CardInfoPrint().printDocument(
                        title: '詳細情報',
                        contents: contents,
                      );
                    } finally {
                      // ダイアログを非表示にする
                      Future.delayed(Duration(seconds: 2), () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }); // Future.delayed
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 8,
                  ), // EdgeInsets.symmetric
                  child: Text('印刷　', style: btnTextStyle),
                ), // Padding
              ), // PopOutButton.icon
            ), // SizedBox
          ), // Align
        ],
      ), // Stack
    ); // Padding
  }

  // 券情報タイトル
  // Widget title({required String title}) {
  //   return Row(
  //     children: [
  //       Container(
  //         color: titleColor,
  //         width: titleStrHeight,
  //         height: titleStrHeight,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(left: 8.0),
  //         child: SizedBox(
  //           width: titleStrWidth,
  //           child: Text(title, style: titleTextStyle),
  //         ),
  //       ),
  //       Expanded(
  //         // flex: 1,
  //         child: Container(color: titleColor, height: titleStrHeight),
  //       ),
  //     ],
  //   );
  // }

  // 印刷する内容のリストを取得する
  List<PrintTicketContent> getTicketContents({required String qrTicketNo}) {
    const hasBreakContents = <CardInfoEnum>[
      CardInfoEnum.qrYukoMukoStatus,
      CardInfoEnum.kensyu2Detail2,
    ];
    List<PrintTicketContent> getCardInfoEnumList(List<CardInfoEnum> list) =>
        list
            .map(
              (c) => PrintTicketContent(
                key: c.name,
                value: c.value,
                hasBreak: hasBreakContents.contains(c),
              ),
            )
            .toList();

    final result = <PrintTicketContent>[];
    result.addAll([
      PrintTicketContent(key: 'QRチケット番号', value: qrTicketNo, hasBreak: true),
      ...getCardInfoEnumList([
        CardInfoEnum.qrYukoMukoStatus,
        CardInfoEnum.qrHakkouStatus,
        CardInfoEnum.siyouStatus,
        CardInfoEnum.nyuusyutuzyouStatus,
        CardInfoEnum.baitaiSyubetu,
        CardInfoEnum.yukoSyuryoubi,
        CardInfoEnum.hatueki,
        CardInfoEnum.hatuekiKusu,
        CardInfoEnum.renrakueki,
        CardInfoEnum.renrakuekiKusu,
        CardInfoEnum.zyosyaeki,
        CardInfoEnum.nyusyutuzyoBit,
        CardInfoEnum.zyosyaTukihi,
        CardInfoEnum.zyosyaZikoku,
        CardInfoEnum.keiyu1,
        CardInfoEnum.keiyu2,
        CardInfoEnum.keiyu3,
        CardInfoEnum.keiyu4,
        CardInfoEnum.kensyu2,
        CardInfoEnum.kensyu,
        CardInfoEnum.kensyu2Detail1,
        CardInfoEnum.kensyu2Detail2,
      ]),
    ]);
    return result;
  }
}

// 詳細情報ボタン
class _DetailInfoButton extends StatelessWidget {
  const _DetailInfoButton();

  // static Color btnColor = Color(0xff7F7F7F);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // final TextStyle _btnTextStyle = TextStyle(fontSize: fontSize);
    return ActiveLargeButton(
      text: '詳細情報　',
      onPressed: () async {
        await showDialog(
          // anchorPoint: Offset(30, 40),
          context: context,
          builder: (context) {
            return AlertDialog(
              // alignment: Alignment.bottomCenter,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Layouts.dialogRadius),
                side: BorderSide(
                  color: Colors.white, // ← 枠線の色
                  width: 2.0, // ← 枠線の太さ
                ), // BorderSide
              ), // RoundedRectangleBorder
              backgroundColor: Layouts.dialogBackgroundColor,
              // backgroundColor: Color(0xFFc6d5da),
              content: SizedBox(
                height: screenHeight * 0.8,
                width: screenWidth * 0.95,
                // child: CardInfoContents(cardInformation: cardDialogInformation),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 5,
                  ), // EdgeInsets.symmetric
                  child: _DetailInfoDialogContent(),
                ), // Padding
              ), // SizedBox
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Container(
                  height: 55.0,
                  width: 225.0,
                  padding: const EdgeInsets.only(right: 18),
                  child: PopOutButton(
                    backgroundColors: [Color(0xff566779), Color(0xff485462)],
                    onPressed: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: FaIcon(
                              FontAwesomeIcons.xmark,
                              color: Color(0xff566779),
                              size: 20,
                            ), // Icon
                          ), // CircleAvatar
                        ), // Padding
                        Expanded(
                          child: Center(
                            child: Text(
                              '閉じる',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ), // TextStyle
                            ), // Text
                          ), // Center
                        ), // Expanded
                      ],
                    ), // Row
                  ), // PopOutButton
                ), // Container
                // ProcessCompletedButton(
                //   icon: FontAwesomeIcons.xmark,
                //   backgroundColors: [Color(0xff566779), Color(0xff485462)],
                //   text: '閉じる　',
                //   onPressed: () => Navigator.of(context).pop(),
                // ),
                // SizedBox(
                //   width: 200,
                //   child: PopOutButton(
                //     backgroundColors: [btnColor, btnColor],
                //     foregroundColor: btnColor,
                //     circularValue: 10,
                //     onPressed: () => Navigator.of(context).pop(false),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Text(
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ); // AlertDialog
          },
        );
      },
    ); // ActiveLargeButton
  }
}

class _DetailInfoDialogContent extends ConsumerWidget {
  const _DetailInfoDialogContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextStyle textStyle = TextStyle(
      fontSize: 27,
      color: Layouts.dialogFontColor,
      // color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    // QRチケット番号
    final qrTicketNo = ref.watch(qrTicketNoProvider);

    List<(String, String)> getTupleList(List<CardInfoEnum> cardInfoList) =>
        cardInfoList.map((c) => c.getTuple()).toList();

    // 表示内容
    // 表示内容
    // final info = <(String, String)>[
    //   ('QRチケット番号', qrTicketNo),
    //   getTupleList([

    // ]);

    final info1 = <(String, String)>[
      ('QRチケット番号', qrTicketNo),
      (
        CardInfoEnum.qrYukoMukoStatus.name,
        (CardInfoEnum.qrYukoMukoStatus.value),
      ),
      ...getTupleList([
        CardInfoEnum.qrHakkouStatus,
        CardInfoEnum.siyouStatus,
        CardInfoEnum.baitaiSyubetu,
        CardInfoEnum.yukoSyuryoubi,
        CardInfoEnum.hatueki,
        CardInfoEnum.hatuekiKusu,
        CardInfoEnum.renrakueki,
        CardInfoEnum.renrakuekiKusu,
        CardInfoEnum.keiyu1,
        CardInfoEnum.keiyu2,
        CardInfoEnum.kensyu2,
        CardInfoEnum.kensyu2Detail1,
        CardInfoEnum.kensyu2Detail2,
      ]),
    ];

    final info2 = <(String, String)>[
      ...getTupleList([
        CardInfoEnum.empty,
        CardInfoEnum.empty,
        CardInfoEnum.empty,
        CardInfoEnum.nyuusyutuzyouStatus,
      ]),
      (CardInfoEnum.zyosyaeki.getAnotherName(), CardInfoEnum.zyosyaeki.value),
      (
        CardInfoEnum.nyusyutuzyoBit.getAnotherName(),
        CardInfoEnum.nyusyutuzyoBit.value,
      ),
      ...getTupleList([
        CardInfoEnum.zyosyaTukihi,
        CardInfoEnum.zyosyaZikoku,
        CardInfoEnum.empty,
        CardInfoEnum.empty,
        CardInfoEnum.keiyu3,
        CardInfoEnum.keiyu4,
        CardInfoEnum.kensyu,
        CardInfoEnum.empty,
        CardInfoEnum.empty,
      ]),
    ];

    // final info2 = <(String, String)>[
    //   ('', ''),
    //   ('', ''),
    //   ('入出場ステータス', StatusInfo.nyuusyutuzyouStatus),
    //   ('乗降駅', CardInfo.zyosyaeki),
    //   ('入出場状態', CardInfo.nyusyutuzyoBit),
    //   ('乗車月日', CardInfo.zyosyaTukihi),
    //   ('乗車時刻', CardInfo.zyosyaZikoku),
    //   ('', ''),
    //   ('', ''),
    //   ('経由３', CardInfo.keiyu3),
    //   ('経由４', CardInfo.keiyu4),
    // ];

    // );

    return DefaultTextStyle(
      style: textStyle,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('■詳細情報'),
            Padding(
              padding: EdgeInsets.only(left: 25),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _detailColumn(
                    children: info1.map((item) => Text(item.$1)).toList(),
                  ),
                  _detailColumn(
                    children:
                        info1
                            .map(
                              (item) => Text(
                                item.$2,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ), // Text
                            )
                            .toList(),
                  ),
                  _detailColumn(
                    children: info2.map((item) => Text(item.$1)).toList(),
                  ),
                  _detailColumn(
                    children:
                        info2
                            .map(
                              (item) => Text(
                                item.$2,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ), // Text
                            )
                            .toList(),
                  ),
                ],
              ), // Row
            ), // Padding
          ],
        ), // Column
      ), // SingleChildScrollView
    ); // DefaultTextStyle
  }

  Widget _detailColumn({required List<Widget> children}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ), // Column
      ), // Padding
    ); // Expanded
  }
}

class TextFieldShadow extends StatelessWidget {
  const TextFieldShadow({
    super.key,
    required this.child,
    required this.topStops,
    required this.leftStops,
  });

  final Widget child;
  final List<double>? topStops;
  final List<double>? leftStops;

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black26, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: topStops,
          // stops: [0.0, 0.15],
        ), // LinearGradient
        borderRadius: BorderRadius.circular(4.0),
      ), // BoxDecoration
      child: Container(
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black26, Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: leftStops,
            // stops: [0.0, 0.013],
          ), // LinearGradient
          borderRadius: BorderRadius.circular(4.0),
        ), // BoxDecoration
        child: child,
      ), // Container
    ); // Container
  }
}

// 画面を表示遷移するボタン
// 券情報ページで使用
class TransitionButton extends StatelessWidget {
  const TransitionButton({
    super.key,
    required this.onPressed,
    // required this.backgroundColors,
    // required this.foregroundColor,
    required this.text,
    // this.inActive = true,
    this.isPushed = false,
    this.width = 170.0,
    this.height = 60.0,
    this.fontSize = 24.0,
  });

  final VoidCallback? onPressed;

  // final List<Color> backgroundColors;
  // final Color foregroundColor;
  final String text;

  // final bool inActive;
  final bool isPushed;
  final double width;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final backgroundColors = isPushed ? greenGradient : orengeGradient;
    final foregroundColor = Colors.black;

    final content = Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize),
    ); // Text

    final icon = FaIcon(
      FontAwesomeIcons.chevronRight,
      color: Colors.black,
      size: 22.0,
    );

    return SizedBox(
      width: width,
      height: height,
      child:
          isPushed
              ? SetBackButton.icon(
                backgroundColors: backgroundColors,
                foregroundColor: foregroundColor,
                circularValue: 28,
                onPressed: onPressed,
                icon: icon,
                iconAlignment: IconAlignment.end,
                child: content,
              ) // SetBackButton.icon
              : PopOutButton.icon(
                backgroundColors: backgroundColors,
                foregroundColor: foregroundColor,
                circularValue: 28,
                onPressed: onPressed,
                icon: icon,
                iconAlignment: IconAlignment.end,
                child: content,
              ), // PopOutButton.icon
    ); // SizedBox
  }
}

class TransitionButtonInactive extends StatelessWidget {
  const TransitionButtonInactive({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Color(0xffC8c8c8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ), // RoundedRectangleBorder
          overlayColor: Colors.transparent,
          // overlayColor: Color(0xffC8c8c8),
          animationDuration: Duration.zero,
        ),
        child: Padding(
          // padding: EdgeInsets.zero,
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Color(0xff969696),
                ), // TextStyle
              ), // Text
              FaIcon(FontAwesomeIcons.chevronRight, color: Color(0xff969696)),
            ],
          ), // Row
        ), // Padding
      ), // ElevatedButton
    ); // SizedBox
  }
}

class QrTicketNoWidget extends ConsumerWidget {
  const QrTicketNoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrTicketNo = ref.watch(qrTicketNoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QRチケット番号',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ), // Text
        Text(
          qrTicketNo,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ), // Text
        // Container(color: Colors.black12, child: Text('dddddddddddd')),
      ],
    ); // Column
  }
}
