Widget _kikakukenContent(
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 6.0,
            children: cardInfo
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
                                  text: item.value,
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
                )
                .toList(),
          ),
          // ※ disclaimer - small font, single line
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              '（※）フリーコードは改札機での判定に必要な情報のため、実際のフリー区間は企画券の券面を確認すること',
              style: TextStyle(
                fontSize: 16.0,   // smaller than normal fontSize (28)
                color: fontColor,
                height: 1.0,      // tight line height
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
