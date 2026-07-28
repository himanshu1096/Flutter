import 'package:flutter/material.dart';

import '../app_icon.dart';
import '../component/process_completed.dart';
import '../qr_process/secondary_tab_process_information.dart';
import '../component/secondary_tab_content_core.dart';
import 'related_process_common.dart';
import 'package:qr_multidemo/utility/common_buttons.dart';
import '../utility/constant.dart';

class CloseTally extends StatelessWidget {
  const CloseTally({super.key});

  @override
  Widget build(BuildContext context) {
    // タブ内遷移する為、ナビゲーターをネストする
    return Navigator(
      onGenerateRoute:
          (settings) => MaterialPageRoute(
            builder: (context) => _CloseTally(),
            settings: settings,
          ),
    );
  }
}

/// タブ内表示全体
class _CloseTally extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaddingForContent(
      child: Column(
        spacing: 8,
        children: [
          Flexible(
            flex: 6,
            child: SingleChildScrollView(child: CloseTallyMainContent()),
          ),
          Flexible(child: Center(child: _ExecuteBtn())),
        ],
      ),
    );
  }
}

/// 締め切りの主な内容（枚数や金額など）
class CloseTallyMainContent extends StatelessWidget {
  /// 締め切りの主な内容（枚数や金額など）
  const CloseTallyMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final fontColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final cardBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final cardOutlineColor = Theme.of(context).colorScheme.surfaceContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 総取扱計（デフォルトで展開）
        _AccordionCard(
          title: '総取扱計',
          initiallyExpanded: true,
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
          icon: DualIconOverlay(
            baseIcon: Icons.receipt_long_outlined,
            topIcon: Icons.info_outline_rounded,
            baseColor: fontColor,
            topColor: fontColor,
            topBackgroundColor: cardBackgroundColor,
          ),
          content: Column(
            children: [
              _ContentTable(
                titleText: '合計',
                subTitleText: '枚数',
                countValue: '5,842',
                amountValue: '3,127,400',
              ),
              _ContentTable(
                titleText: '現金',
                subTitleText: '枚数',
                countValue: '3,214',
                amountValue: '1,842,600',
              ),
            ],
          ),
        ),
        // 磁気乗車券取扱（新規セクション／デフォルトで折りたたみ）
        _AccordionCard(
          title: '磁気乗車券取扱',
          initiallyExpanded: true,
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
          icon: Icon(
            Icons.confirmation_number_outlined,
            size: 40.0,
            color: fontColor,
          ),
          content: Column(
            children: [
              _ContentTable(
                titleText: '合計',
                subTitleText: '枚数',
                countValue: '2,628',
                amountValue: '1,284,800',
              ),
              _ContentTable(
                titleText: '現金収入',
                subTitleText: '枚数',
                countValue: '2,890',
                amountValue: '1,402,300',
              ),
              _ContentTable(
                titleText: '現金支出',
                subTitleText: '枚数',
                countValue: '262',
                amountValue: '117,500',
              ),
            ],
          ),
        ),
        // 件数（デフォルトで展開）
        _AccordionCard(
          title: '件数',
          initiallyExpanded: true,
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
          icon: Icon(
            Icons.format_list_numbered_outlined,
            size: 40.0,
            color: fontColor,
          ),
          content: Column(
            children: [
              _ContentTable(
                titleText: '入場',
                subTitleText: '件数',
                countValue: '1,847',
                amountValue: '1,847,000',
              ),
              _ContentTable(
                titleText: '出場',
                subTitleText: '件数',
                countValue: '1,803',
                amountValue: '1,803,000',
              ),
              _ContentTable(
                titleText: '廃札',
                subTitleText: '件数',
                countValue: '12',
                amountValue: '3,600',
              ),
              _ContentTable(
                titleText: '発駅キャンセル',
                subTitleText: '件数',
                countValue: '8',
                amountValue: '2,400',
              ),
              _ContentTable(
                titleText: '精算合計',
                subTitleText: '件数',
                countValue: '156',
                amountValue: '89,200',
              ),
              _ContentTable(
                titleText: '現金',
                subTitleText: '件数',
                countValue: '156',
                amountValue: '89,200',
                titleLeftPadding: initialPadding,
              ),
            ],
          ),
        ),
        // 各社別精算内訳（新規セクション／デフォルトで折りたたみ／全体・東武分・メトロ分をまとめて1カード）
        _AccordionCard(
          title: '各社別精算内訳',
          initiallyExpanded: true,
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
          icon: Icon(
            Icons.account_balance_outlined,
            size: 40.0,
            color: fontColor,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompanyBreakdownGroup(
                groupTitle: '全体',
                fontColor: fontColor,
                totalCount: '428',
                totalAmount: '512,300',
                cashCount: '312',
                cashAmount: '358,900',
                companies: const [
                  _CompanyRowData(
                    name: '東京メトロ(632)',
                    upCount: '45',
                    upAmount: '62,000',
                    downCount: '12',
                    downAmount: '8,400',
                    netCount: '33',
                    netAmount: '53,600',
                  ),
                  _CompanyRowData(
                    name: '都営(611)',
                    upCount: '28',
                    upAmount: '34,200',
                    downCount: '6',
                    downAmount: '3,100',
                    netCount: '22',
                    netAmount: '31,100',
                  ),
                  _CompanyRowData(
                    name: '西武(621)',
                    upCount: '15',
                    upAmount: '19,800',
                    downCount: '3',
                    downAmount: '1,600',
                    netCount: '12',
                    netAmount: '18,200',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CompanyBreakdownGroup(
                groupTitle: '東武分',
                fontColor: fontColor,
                totalCount: '210',
                totalAmount: '248,600',
                cashCount: '168',
                cashAmount: '201,400',
                companies: const [
                  _CompanyRowData(
                    name: '東京メトロ(632)',
                    upCount: '22',
                    upAmount: '29,000',
                    downCount: '5',
                    downAmount: '3,200',
                    netCount: '17',
                    netAmount: '25,800',
                  ),
                  _CompanyRowData(
                    name: '都営(611)',
                    upCount: '14',
                    upAmount: '16,500',
                    downCount: '3',
                    downAmount: '1,400',
                    netCount: '11',
                    netAmount: '15,100',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CompanyBreakdownGroup(
                groupTitle: 'メトロ分',
                fontColor: fontColor,
                totalCount: '218',
                totalAmount: '263,700',
                cashCount: '144',
                cashAmount: '157,500',
                companies: const [
                  _CompanyRowData(
                    name: '東京メトロ(632)',
                    upCount: '23',
                    upAmount: '33,000',
                    downCount: '7',
                    downAmount: '5,200',
                    netCount: '16',
                    netAmount: '27,800',
                  ),
                  _CompanyRowData(
                    name: '西武(621)',
                    upCount: '9',
                    upAmount: '11,200',
                    downCount: '2',
                    downAmount: '900',
                    netCount: '7',
                    netAmount: '10,300',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 件数、金額のテーブル
class _ContentTable extends StatelessWidget {
  final String titleText;
  final String subTitleText;
  final String countValue;
  final String amountValue;
  final double? titleLeftPadding;

  const _ContentTable({
    required this.titleText,
    required this.subTitleText,
    this.countValue = '1,020',
    this.amountValue = '1,020,000',
    this.titleLeftPadding,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.2,
          child: Container(
            padding: EdgeInsets.only(left: titleLeftPadding ?? 0),
            child: Text(
              titleText,
              style: TextStyle(fontSize: fontSize, color: Colors.black),
            ),
          ),
        ),
        SizedBox(
          width: screenWidth * 0.6,
          child: Table(
            border: TableBorder.all(color: Colors.lightBlue),
            children: [
              TableRow(
                children: [
                  Container(
                    color: Colors.lightBlue[50],
                    alignment: Alignment.center,
                    child: Text(
                      subTitleText,
                      style: TextStyle(fontSize: fontSize, color: Colors.black),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: FittedBox(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: countValue,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '件',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.lightBlue[50],
                    alignment: Alignment.center,
                    child: Text(
                      '金額',
                      style: TextStyle(fontSize: fontSize, color: Colors.black),
                    ),
                  ),
                  Container(
                    height: 40.0,
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: FittedBox(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: amountValue,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '円',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 開閉可能なカード（CardInfoBlockと同じ見た目で、タイトルタップで詳細の表示/非表示を切り替える）
class _AccordionCard extends StatefulWidget {
  const _AccordionCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.fontColor,
    required this.cardBackgroundColor,
    required this.cardOutlineColor,
    this.initiallyExpanded = true,
  });

  final String title;
  final Widget content;
  final Widget icon;
  final Color fontColor;
  final Color cardBackgroundColor;
  final Color cardOutlineColor;
  final bool initiallyExpanded;

  @override
  State<_AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends State<_AccordionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = titleTextStyle.copyWith(
      color: widget.fontColor,
      height: 1.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(0.1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Layouts.dialogRadius),
        color: widget.cardBackgroundColor,
      ),
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Layouts.dialogRadius),
          side: BorderSide(color: widget.cardOutlineColor, width: 2.0),
        ),
        color: widget.cardBackgroundColor,
        elevation: 5.0,
        child: ListTile(
          dense: true,
          isThreeLine: true,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.icon,
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 300,
                  child: Text(widget.title, style: textStyle),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _toggle,
                icon: AnimatedRotation(
                  turns: _expanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    color: widget.fontColor,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          subtitle: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child:
                _expanded
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 12,
                          thickness: 1.5,
                          color: widget.fontColor,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            top: 10.0,
                            bottom: 15.0,
                          ),
                          child: widget.content,
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// 各社別精算内訳の1グループ分（全体／東武分／メトロ分で共通のレイアウト）
class _CompanyBreakdownGroup extends StatelessWidget {
  const _CompanyBreakdownGroup({
    required this.groupTitle,
    required this.fontColor,
    required this.totalCount,
    required this.totalAmount,
    required this.cashCount,
    required this.cashAmount,
    required this.companies,
  });

  final String groupTitle;
  final Color fontColor;
  final String totalCount;
  final String totalAmount;
  final String cashCount;
  final String cashAmount;
  final List<_CompanyRowData> companies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            groupTitle,
            style: titleTextStyle.copyWith(
              color: fontColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _ContentTable(
          titleText: '合計',
          subTitleText: '枚数',
          countValue: totalCount,
          amountValue: totalAmount,
        ),
        _ContentTable(
          titleText: '現金',
          subTitleText: '枚数',
          countValue: cashCount,
          amountValue: cashAmount,
        ),
        for (final c in companies) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
            child: Text(
              c.name,
              style: titleTextStyle.copyWith(
                color: fontColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ContentTable(
            titleText: '増',
            subTitleText: '件数',
            countValue: c.upCount,
            amountValue: c.upAmount,
            titleLeftPadding: initialPadding,
          ),
          _ContentTable(
            titleText: '減',
            subTitleText: '件数',
            countValue: c.downCount,
            amountValue: c.downAmount,
            titleLeftPadding: initialPadding,
          ),
          _ContentTable(
            titleText: '相殺',
            subTitleText: '件数',
            countValue: c.netCount,
            amountValue: c.netAmount,
            titleLeftPadding: initialPadding,
          ),
        ],
      ],
    );
  }
}

/// 各社別精算内訳の会社1行分のダミーデータ保持用（表示専用・サーバーデータとは未連携）
class _CompanyRowData {
  const _CompanyRowData({
    required this.name,
    required this.upCount,
    required this.upAmount,
    required this.downCount,
    required this.downAmount,
    required this.netCount,
    required this.netAmount,
  });

  final String name;
  final String upCount;
  final String upAmount;
  final String downCount;
  final String downAmount;
  final String netCount;
  final String netAmount;
}

/// 実行ボタン
class _ExecuteBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ActiveLargeButton(
      text: "実行    ",
      onPressed: () {
        // 完了画面に遷移する
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => ProcessCompleted(
                  onCompleteButtonPressed: () async {
                    // ネストしたナビゲーターを取得する
                    final navState = Navigator.of(
                      context,
                      rootNavigator: false,
                    );

                    // ネストしたナビゲーターの画面を元の締め切り画面に戻す
                    if (navState.canPop()) {
                      navState.pop();
                    }
                  },
                ),
            transitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}
