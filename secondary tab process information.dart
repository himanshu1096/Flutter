import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_multidemo/app_color.dart';
import 'package:qr_multidemo/provider/provider.dart';
import 'package:qr_multidemo/qr_process/qr_process_menu.dart';
import 'package:qr_multidemo/secondary_tab_content_core.dart';
import 'package:intl/intl.dart';

import '../app_icon.dart';
import '../model/display_data_mapper.dart';
import '../provider/display_data_provider.dart';
import '../utility/confirm_dialog.dart';
import '../utility/constant.dart';
import 'secondary_tab_content_unselected.dart';

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
    // ステータス情報
    final statusInfo = <CardInfoEnum>[
      CardInfoEnum.qrYukoMukoStatus,
      CardInfoEnum.siyouStatus,
      CardInfoEnum.qrHakkouStatus,
      CardInfoEnum.nyuusyutuzyouStatus,
    ];

    // 履歴情報
    final historyInfo = <CardInfoEnum>[
      CardInfoEnum.zyosyaeki,
      CardInfoEnum.zyosyaTukihi,
      CardInfoEnum.nyusyutuzyoBit,
      CardInfoEnum.zyosyaZikoku,
    ];

    // 表示データ取得 → マッパー生成
    final displayData = ref.watch(displayDataNotifierProvider);
    final mapper = displayData != null ? DisplayDataMapper(displayData) : null;
    String getValue(CardInfoEnum field) => mapper?.getValue(field) ?? '';

    // MediatTypeに応じてカード乗車券情報を切り替え
    final mediaType = displayData?.mediaType ?? 0;
    final List<CardInfoEnum> cardTicketInfo;

    if (mediaType == 11 || mediaType == 12) {
      // 普通券
      cardTicketInfo = [
        CardInfoEnum.baitaiSyubetu,
        CardInfoEnum.yukoSyuryoubi,
        CardInfoEnum.hatueki,
        CardInfoEnum.hatuekiKusu,
        CardInfoEnum.renrakueki,
        CardInfoEnum.renrakuekiKusu,
      ];
    } else if (mediaType == 21 || mediaType == 22) {
      // 回数券
      cardTicketInfo = [
        CardInfoEnum.baitaiSyubetu,
        CardInfoEnum.yukoSyuryoubi,
        CardInfoEnum.hatueki,
        CardInfoEnum.hatuekiKusu,
        CardInfoEnum.tyakueki,
        CardInfoEnum.kensyu2,
      ];
    } else if (mediaType == 31 || mediaType == 32) {
      // 企画券
      cardTicketInfo = [
        CardInfoEnum.baitaiSyubetu,
        CardInfoEnum.yukoKaisibi,
        CardInfoEnum.yukoSyuryoubi,
        CardInfoEnum.hatueki,
        CardInfoEnum.keiyu1,
        CardInfoEnum.tyakueki,
        CardInfoEnum.huricode,
      ];
    } else {
      cardTicketInfo = [];
    }

    // 選択中のページ
    final pageKind = ref.watch(qrReadPageSelectedBtnProvider);

    final fontColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final cardBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final cardOutlineColor = Theme.of(context).colorScheme.surfaceContainer;

    return ListView(
      shrinkWrap: true,
      children: [
        //if (pageKind == QrReadPageBtnKind.zyouhoHyouzi)
          CardInfoBlock(
            title: 'カード乗車券情報',
            content: _cardInfoContent(
              context,
              cardInfo: cardTicketInfo,
              fontColor: fontColor,
              getValue: getValue,
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
            ),
            fontColor: fontColor,
            cardBackgroundColor: cardBackgroundColor,
            cardOutlineColor: cardOutlineColor,
          ),
        if (pageKind != QrReadPageBtnKind.seisanSyori)
          CardInfoBlock(
            title: '入出場情報',
            // title: '履歴情報',
            content: _cardInfoContent(
              context,
              cardInfo: historyInfo,
              fontColor: fontColor,
              getValue: getValue,
            ),
            // icon: Icons.history_edu_outlined,
            icon: Icon(
              Icons.history_edu_outlined,
              size: 40.0,
              color: fontColor,
            ),
            fontColor: fontColor,
            cardBackgroundColor: cardBackgroundColor,
            cardOutlineColor: cardOutlineColor,
          ),
        if (pageKind == QrReadPageBtnKind.zyouhoHyouzi)
        CardInfoBlock(
          title: 'ステータス',
          content: _cardInfoContent(
            context,
            cardInfo: statusInfo,
            fontColor: fontColor,
            getValue: getValue,
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
          ),
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
        ),
      ],
    );
  }

  Widget _cardInfoContent(
    BuildContext context, {
    required List<CardInfoEnum> cardInfo,
    required Color fontColor,
    required String Function(CardInfoEnum) getValue,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bool singleColumn = w < 600.0;
        final double maxWidth = singleColumn ? w : w / 2;
        final maxWidth2 = maxWidth * 0.5;

        return Wrap(
          runSpacing: 6.0,
          children: cardInfo.map((item) {
            final value = getValue(item);

            // 媒体種別 → 全幅表示（右列なし）
            if (item == CardInfoEnum.baitaiSyubetu) {
              return SizedBox(
                width: w,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: fontColor,
                  ),
                ),
              );
            }

            // フリーコード → 赤色表示
            final valueColor = item == CardInfoEnum.huricode
                ? Colors.red
                : null;

            return SizedBox(
              width: maxWidth,
              child: value.isNotEmpty
                  ? Row(
                      children: [
                        SizedBox(
                          width: maxWidth2,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: fontColor,
                            ),
                          ),
                        ),
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
                                ),
                                TextSpan(
                                  text: value,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w500,
                                    color: valueColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        SizedBox(
                          width: maxWidth2 * 2,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: fontColor,
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          }).toList(),
        );
      },
    );
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
    final textStyleL = titleTextStyle.copyWith(color: Colors.red, height: 1.0,fontSize: 25,);
    return SizedBox(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(0.1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Layouts.dialogRadius),
          color: cardBackgroundColor,
        ),
        child: Card.outlined(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Layouts.dialogRadius),
            side: BorderSide(color: cardOutlineColor, width: 2.0),
          ),
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
                  child: SizedBox(width: 300, child: Text(title, style: textStyle)),
                ),
              ],
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 12, thickness: 1.5, color: fontColor),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 10.0, bottom: 15.0),
                  child: content,
                ),
                title =='カード乗車券情報'?
                  Align(
                    alignment: Alignment.centerLeft,
                    child:Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: SizedBox(height:30,child:Text("(※)フリーコードは改札機での判定に必要な情報のため、実際のフリー区間は企画券の券面を確認すること",style: textStyleL)),
                    ),
                  ):SizedBox(height: 0,)
              ],
            ),
          ),
        ),
      ),
    );
  }

}
