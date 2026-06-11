import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../app_icon.dart';
import '../../../provider/provider.dart';
import 'package:qr_multidemo/qr_process/qr_process_menu.dart';
import '../utility/confirm_dialog.dart';
import '../utility/constant.dart';
import 'package:qr_multidemo/secondary_tab_content_core.dart';

enum QrReadPageBtnKind {
  nyuuzyou('入場処理'),
  syutuzyou('出場処理'),
  hatuekiCancel('発駅キャンセル処理'),
  seisanSyori('精算処理'),
  haikenSyori('廃券処理'),
  zyouhoHyouzi('情報表示');

  final String name;

  const QrReadPageBtnKind(this.name);
}

class SecondaryTabContentUnselected extends StatelessWidget {
  const SecondaryTabContentUnselected({required this.onComplete, super.key});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context) {
    return SecondaryTabContentBase(
      contentTop: _SecondaryTabContentTop(onComplete: onComplete),
    ); // SecondaryTabContentBase
  }
}

class _SecondaryTabContentTop extends ConsumerWidget {
  const _SecondaryTabContentTop({required this.onComplete});

  final void Function(QrReadPageBtnKind pageKind) onComplete;
  static const buttonDist = SizedBox(width: 25);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBtn = ref.watch(qrReadPageSelectedBtnProvider);
    final btnNotifier = ref.watch(qrReadPageSelectedBtnProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TransitionButton(
                    onPressed: () {
                      btnNotifier.changePage(QrReadPageBtnKind.nyuuzyou);
                    },
                    text: '□入場□',
                    isPushed: QrReadPageBtnKind.nyuuzyou == selectedBtn,
                  ), // TransitionButton
                  buttonDist,
                  TransitionButton(
                    onPressed: () {
                      btnNotifier.changePage(QrReadPageBtnKind.syutuzyou);
                    },
                    text: '□出場□',
                    isPushed: QrReadPageBtnKind.syutuzyou == selectedBtn,
                  ), // TransitionButton
                  buttonDist,
                  TransitionButton(
                    onPressed: () {
                      btnNotifier.changePage(QrReadPageBtnKind.seisanSyori);
                    },
                    text: '精算処理',
                    isPushed: QrReadPageBtnKind.seisanSyori == selectedBtn,
                  ), // TransitionButton
                  buttonDist,
                  TransitionButton(
                    onPressed: () {
                      btnNotifier.changePage(QrReadPageBtnKind.haikenSyori);
                    },
                    text: '廃券処理',
                    isPushed: QrReadPageBtnKind.haikenSyori == selectedBtn,
                  ), // TransitionButton
                  buttonDist,
                  TransitionButton(
                    onPressed: () {
                      btnNotifier.changePage(QrReadPageBtnKind.hatuekiCancel);
                    },
                    text: '発駅キャンセル',
                    isPushed: QrReadPageBtnKind.hatuekiCancel == selectedBtn,
                    // width: 190,
                    fontSize: 22.0,
                  ), // TransitionButton
                  buttonDist,
                  TransitionButton(
                    onPressed: () {
                      btnNotifier.changePage(QrReadPageBtnKind.zyouhoHyouzi);
                    },
                    text: '情報表示',
                    isPushed: QrReadPageBtnKind.zyouhoHyouzi == selectedBtn,
                  ), // TransitionButton
                ],
              ),
              // QrTicketNoWidget(),
            ],
          ), // Row
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: CardInfoContents(),
            ), // Padding
          ), // Flexible
          Padding(
            padding: EdgeInsets.only(bottom: 20.0, top: 0.0),
            child: SecondaryTabContent(onComplete: onComplete),
          ), // Padding
        ],
      ), // Column
    ); // Padding
  }

  // Widget stateButton({
  //   required String text,
  //   required VoidCallback onPressed,
  //   required bool isPushed,
  // }) {
  //   return TransitionButton(
  //     // backgroundColors: isPushed ? greenGradient : orangeGradient,
  //     // foregroundColor: Colors.black,
  //     onPressed: onPressed,
  //     text: text,
  //     isPushed: isPushed,
  //   );
  // }
}

// 券情報部分
class CardInfoContents extends ConsumerWidget {
  const CardInfoContents({super.key});

  // タイトル文字列の表示幅
  static double titleStrWidth = 260;
  static double titleStrHeight = 32;

  // 各項目名の幅
  final double itemStrWidth = 270;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 表示内容
    // カード・乗車券情報
    final statusInfo = <CardInfoEnum>[
      CardInfoEnum.qrYukoMukoStatus,
      CardInfoEnum.siyouStatus,
      CardInfoEnum.qrHakkouStatus,
      CardInfoEnum.nyuusyutuzyouStatus,
    ];
    // カード・乗車券情報
    final cardTicketInfo = <CardInfoEnum>[
      CardInfoEnum.baitaiSyubetu,
      CardInfoEnum.yukoSyuryoubi,
      CardInfoEnum.hatueki,
      CardInfoEnum.hatuekiKusu,
      CardInfoEnum.renrakueki,
      CardInfoEnum.renrakuekiKusu,
    ];
    // 履歴情報
    final historyInfo = <CardInfoEnum>[
      CardInfoEnum.zyosyaeki,
      CardInfoEnum.zyosyaTukihi,
      CardInfoEnum.nyusyutuzyoBit,
      CardInfoEnum.zyosyaZikoku,
    ];

    // 選択中のページ
    final pageKind = ref.watch(qrReadPageSelectedBtnProvider);

    final fontColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final cardBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final cardOutlineColor = Theme.of(context).colorScheme.surfaceContainer;

    return ListView(
      shrinkWrap: true,
      children: [
        if (pageKind == QrReadPageBtnKind.zyouhoHyouzi)
          CardInfoBlock(
            title: '入出場情報',
            // title: '履歴情報',
            content: _cardInfoContent(
              context,
              cardInfo: historyInfo,
              fontColor: fontColor,
            ),
            // icon: Icons.history_edu_outlined,
            icon: Icon(
              Icons.history_edu_outlined,
              size: 40.0,
              color: fontColor,
            ), // Icon
            fontColor: fontColor,
            cardBackgroundColor: cardBackgroundColor,
            cardOutlineColor: cardOutlineColor,
          ), // CardInfoBlock
        CardInfoBlock(
          title: 'ステータス',
          content: _cardInfoContent(
            context,
            cardInfo: statusInfo,
            fontColor: fontColor,
          ),
          // icon: Icons.info_outline,
          // icon: Icon(Icons.qr_code_outlined, size: 40.0, color: fontColor),
          icon: DualIconOverlay(
            baseIcon: Icons.info_outline_rounded,
            topIcon: Icons.qr_code_rounded,
            baseColor: fontColor,
            topColor: fontColor,
            topBackgroundColor: cardBackgroundColor,
            topOffset: Offset(5, 0),
          ), // DualIconOverlay
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
        ), // CardInfoBlock
        if (pageKind == QrReadPageBtnKind.zyouhoHyouzi)
          CardInfoBlock(
            title: 'カード乗車券情報',
            content: _cardInfoContent(
              context,
              cardInfo: cardTicketInfo,
              fontColor: fontColor,
            ),
            // icon: Icons.directions_train_outlined,
            // icon: Icon(
            //   Icons.directions_train_outlined,
            //   size: 40.0,
            //   color: fontColor,
            // ),
            icon: DualIconOverlay(
              baseIcon: Icons.confirmation_num_outlined,
              topIcon: Icons.info_outline_rounded,
              baseColor: fontColor,
              topColor: fontColor,
              topBackgroundColor: cardBackgroundColor,
              topOffset: Offset(5, 0),
            ), // DualIconOverlay
            fontColor: fontColor,
            cardBackgroundColor: cardBackgroundColor,
            cardOutlineColor: cardOutlineColor,
          ), // CardInfoBlock
      ],
    ); // ListView
  }

  Widget _cardInfoContent(
    BuildContext context, {
    required List<CardInfoEnum> cardInfo,
    required Color fontColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final bool singleColumn = w < 600.0;
        final double maxWidth = singleColumn ? w : w / 2;

        final maxWidth2 = maxWidth * 0.5;
        return Wrap(
          runSpacing: 6.0,
          children:
              cardInfo
                  .map(
                    (item) => SizedBox(
                      width: maxWidth,
                      child: Row(
                        children: [
                          SizedBox(
                            width: maxWidth2,
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: fontColor,
                              ), // TextStyle
                            ), // Text
                          ), // SizedBox
                          SizedBox(
                            width: maxWidth2,
                            child: RichText(
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  const TextSpan(
                                    text: ' : ',
                                    style: TextStyle(fontSize: fontSize),
                                  ), // TextSpan
                                  TextSpan(
                                    text: item.value,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w500,
                                    ), // TextStyle
                                  ), // TextSpan
                                ],
                              ), // TextSpan
                            ), // RichText
                          ), // SizedBox
                        ],
                      ), // Row
                    ), // SizedBox
                  )
                  .toList(),
        ); // Wrap
      },
    ); // LayoutBuilder
  }
}

// カード情報の一ブロック
class CardInfoBlock extends StatelessWidget {
  const CardInfoBlock( // this.cardInfo, {
  {
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.fontColor,
    required this.cardBackgroundColor,
    required this.cardOutlineColor,
  });

  // final List<CardInfoEnum> cardInfo;
  final String title;
  final Widget content;
  final Widget icon;

  // final IconData icon;
  final Color fontColor;
  final Color cardBackgroundColor;
  final Color cardOutlineColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = titleTextStyle.copyWith(color: fontColor, height: 1.0);
    return SizedBox(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(0.1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Layouts.dialogRadius),
          color: cardBackgroundColor,
        ), // BoxDecoration
        child: Card.outlined(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Layouts.dialogRadius),
            side: BorderSide(color: cardOutlineColor, width: 2.0),
          ), // RoundedRectangleBorder
          color: cardBackgroundColor,
          elevation: 5.0,
          child: ListTile(
            dense: true,
            isThreeLine: true,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                // Icon(icon, size: 40.0, color: fontColor),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(child: Text(title, style: textStyle)),
                ), // Padding
              ],
            ), // Row
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 12, thickness: 1.5, color: fontColor),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 10.0, bottom: 15.0),
                  child: content,
                  // child: LayoutBuilder(
                  //   builder: (context, constraints) {
                  //     final w = constraints.maxWidth;
                  //
                  //     final bool singleColumn = w < 600.0;
                  //     final double maxWidth = singleColumn ? w : w / 2;
                  //
                  //     final maxWidth2 = maxWidth * 0.5;
                  //     return Wrap(
                  //       runSpacing: 6.0,
                  //       children:
                  //         cardInfo
                  //           .map(
                  //             (item) => SizedBox(
                  //               width: maxWidth,
                  //               child: Row(
                  //                 children: [
                  //                   SizedBox(
                  //                     width: maxWidth2,
                  //                     child: Text(
                  //                       item.name,
                  //                       style: TextStyle(
                  //                         fontSize: fontSize,
                  //                         color: fontColor,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: maxWidth2,
                  //                     child: RichText(
                  //                       softWrap: false,
                  //                       overflow: TextOverflow.ellipsis,
                  //                       maxLines: 1,
                  //                       text: TextSpan(
                  //                         style:
                  //                           DefaultTextStyle.of(
                  //                             context,
                  //                           ).style,
                  //                         children: [
                  //                           const TextSpan(
                  //                             text: ' : ',
                  //                             style: TextStyle(
                  //                               fontSize: fontSize
                  //                             ),
                  //                           ),
                  //                           TextSpan(
                  //                             text: item.value,
                  //                             style: TextStyle(
                  //                               fontSize: fontSize,
                  //                               fontWeight: FontWeight.w500,
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           )
                  //           .toList(),
                  //     );
                  //   },
                  // ),
                ), // Padding
              ],
            ), // Column
          ), // ListTile
        ), // Card.outlined
      ), // Container
    ); // SizedBox
  }

  // 列ごとの表示
  // Widget itemColumn(List<CardInfoEnum> columnItems, BuildContext context) {
  // // Widget itemColumn(List<(String, String)> columnItems) {
  //   return Expanded(
  //     child: Column(
  //       spacing: 5.0,
  //       children:
  //         columnItems
  //           .map(
  //             (item) => Row(
  //               children: [
  //                 Flexible(
  //                   fit: FlexFit.loose,
  //                   child: itemText(item.name, context),
  //                 ),
  //                 ...
  //               ],
  //             ),
  //           )
  //           ...
  //     ),
  //   );
  // }
}

class SecondaryTabContent extends ConsumerWidget {
  const SecondaryTabContent({required this.onComplete, super.key});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageKind = ref.watch(qrReadPageSelectedBtnProvider);
    return switch (pageKind) {
      QrReadPageBtnKind.zyouhoHyouzi => ZyouhoHyouziFooter(),
      QrReadPageBtnKind.seisanSyori => SeisanSyori(onComplete: onComplete),
      _ => SeisanSonotaSyori(onComplete: onComplete),
    };
  }
}

// 精算処理の固有部分
class SeisanSyori extends StatelessWidget {
  const SeisanSyori({required this.onComplete, super.key});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                '精　算　金　額',
                style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.w500),
              ), // Text
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.red, // 下線の色
                      width: 4.0, // 下線の太さ
                    ), // BorderSide
                  ), // Border
                ), // BoxDecoration
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '230',
                      style: TextStyle(
                        fontSize: 66.0,
                        fontWeight: FontWeight.w500,
                      ), // TextStyle
                    ), // Text
                    SizedBox(width: 10.0),
                    Text('円', style: TextStyle(fontSize: 34.0)),
                  ],
                ), // Row
              ), // Container
            ],
          ), // Column
          Padding(
            padding: EdgeInsets.only(top: 64.0),
            child: _ExecuteButton(onComplete: onComplete),
          ), // Padding
        ],
      ), // Column
    ); // Padding
  }
}

// 精算処理以外の部分
class SeisanSonotaSyori extends ConsumerWidget {
  const SeisanSonotaSyori({required this.onComplete, super.key});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(qrReadPageSelectedBtnProvider);
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Column(
        children: [
          Text(
            '${currentPage.name}を実行します',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
          ), // Text
          SizedBox(height: 125.0),
          _ExecuteButton(onComplete: onComplete),
        ],
      ), // Column
    ); // Padding
  }
}

// 実行ボタン
class _ExecuteButton extends ConsumerWidget {
  const _ExecuteButton({required this.onComplete});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(qrReadPageSelectedBtnProvider);
    final dialogText =
        currentPage == QrReadPageBtnKind.hatuekiCancel
            ? '発駅キャンセルを実行します。\n処理を実行すると係員窓口のみ\n利用が可能となります。よろしいですか？'
            : null;
    final dialogTextColor =
        currentPage == QrReadPageBtnKind.hatuekiCancel
            ? Theme.of(context).colorScheme.error
            : null;
    return ActiveLargeButton(
      text: '実行　　',
      onPressed: () async {
        // 実行確認
        final isExecute = await showDialog<bool?>(
          // barrierColor: Colors.transparent,
          barrierColor: Colors.black26,
          context: context,
          builder:
              (context) => ConfirmDialog(
                porpose: currentPage.name,
                customText: dialogText,
                customFontColor: dialogTextColor,
              ), // ConfirmDialog
        );

        // 実行が「はい」かつ、contextがあれば
        if ((isExecute ?? false) && context.mounted) {
          // 処理完了画面へ移動
          onComplete.call(currentPage);
        }
      },
    ); // ActiveLargeButton
  }
}
