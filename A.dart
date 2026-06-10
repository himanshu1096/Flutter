// 企画券用
kikakukenYukoKaisibi('有効開始日', ''),
kikakukenTyakueki('着駅', '東武北千'),
kikakukenYukoSyuryoubi('有効終了日', '06/04'),
kikakukenKeiyu1('経由１', '下今市'),
kikakukenFreeCode('フリーコード(※)', '日光・鬼怒川 F'),
empty('', '');


// カード・乗車券情報 普通券(QR) - サーバー接続後に切り替え予定
// final cardTicketInfo = <CardInfoEnum>[
//   CardInfoEnum.baitaiSyubetu,
//   CardInfoEnum.yukoSyuryoubi,
//   CardInfoEnum.hatueki,
//   CardInfoEnum.hatuekiKusu,
//   CardInfoEnum.renrakueki,
//   CardInfoEnum.renrakuekiKusu,
// ];
content: _cardInfoContent(
  context,
  cardInfo: cardTicketInfo,
  fontColor: fontColor,
),
content: _kikakukenContent(context, fontColor: fontColor),

Widget _kikakukenContent(
  BuildContext context, {
  required Color fontColor,
}) {
  // 企画券のデータ
  final rows = <(String, String)>[
    (CardInfoEnum.kikakukenYukoKaisibi.name, CardInfoEnum.kikakukenYukoKaisibi.value),
    (CardInfoEnum.hatueki.name,              '06/01'),
    (CardInfoEnum.kikakukenTyakueki.name,    CardInfoEnum.kikakukenTyakueki.value),
    (CardInfoEnum.kikakukenYukoSyuryoubi.name, CardInfoEnum.kikakukenYukoSyuryoubi.value),
    (CardInfoEnum.keiyu1.name,               CardInfoEnum.kikakukenKeiyu1.value),
    (CardInfoEnum.kikakukenFreeCode.name,    CardInfoEnum.kikakukenFreeCode.value),
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      final double maxWidth = w / 2;
      final double keyWidth = maxWidth * 0.5;
      final double valWidth = maxWidth * 0.5;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 企画券 subheading
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '企画券',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: fontColor,
              ),
            ),
          ),
          // key-value rows
          Wrap(
            runSpacing: 2.0,
            children: rows.map((item) =>
              SizedBox(
                width: maxWidth,
                child: Row(
                  children: [
                    SizedBox(
                      width: keyWidth,
                      child: Text(
                        item.$1,
                        style: TextStyle(fontSize: fontSize, color: fontColor),
                      ),
                    ),
                    SizedBox(
                      width: valWidth,
                      child: RichText(
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: ' : ',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            TextSpan(
                              text: item.$2,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
          // disclaimer - 1 line, small font
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              '（※）フリーコードは改札機での判定に必要な情報のため、実際のフリー区間は企画券の券面を確認すること',
              style: TextStyle(
                fontSize: 14.0,
                color: fontColor,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      );
    },
  );
}

