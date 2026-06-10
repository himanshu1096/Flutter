class CardInfoBlock extends StatelessWidget {
  const CardInfoBlock(
  {
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.fontColor,
    required this.cardBackgroundColor,
    required this.cardOutlineColor,
    this.subtitleNote,   // ← optional note below title
  });

  final String title;
  final Widget content;
  final Widget icon;
  final Color fontColor;
  final Color cardBackgroundColor;
  final Color cardOutlineColor;
  final String? subtitleNote;   // ← add this



  subtitle: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Divider(height: 12, thickness: 1.5, color: fontColor),
    // optional note below title divider
    if (subtitleNote != null)
      Padding(
        padding: const EdgeInsets.only(left: 20.0, bottom: 4.0),
        child: Text(
          subtitleNote!,
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
    Padding(
      padding: EdgeInsets.only(left: 20, top: 4.0, bottom: 15.0),
      child: content,
    ),
  ],
),



  CardInfoBlock(
  title: 'カード乗車券情報',
  content: _kikakukenContent(context, fontColor: fontColor),
  icon: DualIconOverlay(...),
  fontColor: fontColor,
  cardBackgroundColor: cardBackgroundColor,
  cardOutlineColor: cardOutlineColor,
  subtitleNote: '（※）フリーコードは改札機での判定に必要な情報のため、実際のフリー区間は企画券の券面を確認すること',
),


  // DELETE this from _kikakukenContent
Padding(
  padding: const EdgeInsets.only(top: 6.0),
  child: Text(
    '（※）フリーコードは改札機での判定に必要な情報のため...',
    ...
  ),
),



  
