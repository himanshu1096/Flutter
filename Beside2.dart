Padding(
  padding: const EdgeInsets.only(bottom: 4.0),
  child: RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '企画券  ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: fontColor,
          ),
        ),
        TextSpan(
          text: '（※）フリーコードは改札機での判定に必要な情報のため、実際のフリー区間は企画券の券面を確認すること',
          style: TextStyle(
            fontSize: 14.0,
            color: fontColor,
            height: 1.4,
          ),
        ),
      ],
    ),
  ),
),
