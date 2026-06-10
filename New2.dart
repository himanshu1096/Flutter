// ↓ ADD THIS NEW BLOCK AFTER IT
if (pageKind == QrReadPageBtnKind.zyouhoHyouzi)
  CardInfoBlock(
    title: '企画券情報',
    content: _kikakukenContent(
      context,
      cardInfo: kikakukenInfo,
      fontColor: fontColor,
    ),
    icon: Icon(
      Icons.card_travel_outlined,
      size: 40.0,
      color: fontColor,
    ),
    fontColor: fontColor,
    cardBackgroundColor: cardBackgroundColor,
    cardOutlineColor: cardOutlineColor,
  ), // CardInfoBlock 企画券情報
