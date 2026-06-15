import 'package:flutter/material.dart';

import '../app_icon.dart';
import '../process_completed.dart';
import '../qr_process/qr_process_menu.dart';
import '../qr_process/secondary_tab_content_unselected.dart';
import '../secondary_tab_content_core.dart';
import 'related_process_common.dart';

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
          ), // MaterialPageRoute
    ); // Navigator
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
          ), // Flexible
          Flexible(child: Center(child: _ExecuteBtn())),
        ],
      ), // Column
    ); // PaddingForContent
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
        CardInfoBlock(
          title: '総取扱計',
          content: _ContentTable(
            titleText: '現金',
            subTitleText: '枚数',
            // fontColor: fontColor,
          ), // _ContentTable
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
          // icon: Icons.money,
          icon: DualIconOverlay(
            baseIcon: Icons.receipt_long_outlined,
            topIcon: Icons.info_outline_rounded,
            baseColor: fontColor,
            topColor: fontColor,
            topBackgroundColor: cardBackgroundColor,
          ), // DualIconOverlay
        ), // CardInfoBlock
        // TitleInContent(titleText: '総取扱計'),
        // _ContentRow(
        //   children: [_ContentTable(titleText: '現金', subTitleText: '枚数')],
        // ),
        CardInfoBlock(
          title: '件数',
          content: Column(
            // content: _ContentRow(
            children: [
              _ContentTable(titleText: '入場', subTitleText: '件数'),
              _ContentTable(titleText: '出場', subTitleText: '件数'),
              _ContentTable(titleText: '精算合計', subTitleText: '件数'),
              _ContentTable(
                titleText: '自動精算',
                subTitleText: '件数',
                titleLeftPadding: initialPadding,
              ), // _ContentTable
              _ContentTable(
                titleText: '手動精算',
                subTitleText: '件数',
                titleLeftPadding: initialPadding,
              ), // _ContentTable
            ],
          ), // Column
          fontColor: fontColor,
          cardBackgroundColor: cardBackgroundColor,
          cardOutlineColor: cardOutlineColor,
          icon: Icon(
            Icons.format_list_numbered_outlined,
            size: 40.0,
            color: fontColor,
          ), // Icon
        ), // CardInfoBlock
        // TitleInContent(titleText: '件数'),
        // _ContentRow(
        //   children: [
        //     _ContentTable(titleText: '入場', subTitleText: '件数'),
        //     _ContentTable(titleText: '出場', subTitleText: '件数'),
        //     _ContentTable(titleText: '精算合計', subTitleText: '件数'),
        //     _ContentTable(
        //       titleText: '自動精算',
        //       subTitleText: '件数',
        //       ...
        //     ),
        //   ...
        // _ContentRow(
        //   children: [_ContentTable(titleText: '払戻', subTitleText: '...
        //   ),
        //  ),
      ],
    ); // Column
  }
}

/// タイトル下の内容
class _ContentRow extends StatelessWidget {
  final List<Widget> children;

  const _ContentRow() : children = const <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(children: children),
    ); // Container
  }
}

/// 件数、金額のテーブル
class _ContentTable extends StatelessWidget {
  final String titleText;
  final String subTitleText;
  final double? titleLeftPadding;
  final Color fontColor;

  const _ContentTable({
    required this.titleText,
    required this.subTitleText,
    this.titleLeftPadding,
  }) : fontColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: screenWidth * 0.2,
          // padding: EdgeInsets.fromLTRB(initialPadding * 3, 4, 4, 4),
          child: Container(
            padding: EdgeInsets.only(left: titleLeftPadding ?? 0),
            child: Text(
              titleText,
              style: TextStyle(fontSize: fontSize, color: fontColor),
            ), // Text
          ), // Container
        ), // SizedBox
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
                      style: TextStyle(fontSize: fontSize, color: fontColor),
                    ), // Text
                  ), // Container
                  Container(
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: FittedBox(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: '1,020',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: fontColor,
                              ), // TextStyle
                            ), // TextSpan
                            TextSpan(
                              text: '件',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: fontColor,
                              ), // TextStyle
                            ), // TextSpan
                          ], // <TextSpan>[]
                        ), // TextSpan
                      ), // RichText
                    ), // FittedBox
                    // child: Text(
                    //   '102',
                    //   style: TextStyle(fontSize: fontSize, color: fontColor),
                    // ),
                  ), // Container
                  Container(
                    color: Colors.lightBlue[50],
                    alignment: Alignment.center,
                    child: Text(
                      '金額',
                      style: TextStyle(fontSize: fontSize, color: fontColor),
                    ), // Text
                  ), // Container
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
                              text: '1,020,000',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: fontColor,
                              ), // TextStyle
                            ), // TextSpan
                            TextSpan(
                              text: '円',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: fontColor,
                              ), // TextStyle
                            ), // TextSpan
                          ], // <TextSpan>[]
                        ), // TextSpan
                      ), // RichText
                    ), // FittedBox
                  ), // Container
                ],
              ), // TableRow
            ],
          ), // Table
        ), // SizedBox
      ],
    ); // Row
  }
}

/// 実行ボタン
class _ExecuteBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ActiveLargeButton(
      text: "実行　　",
      onPressed: () {
        // 完了画面に遷移する
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => ProcessCompleted(
                  onCompleteButtonPressed: () {
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
                ), // ProcessCompleted
            transitionDuration: Duration.zero,
          ), // PageRouteBuilder
        );
      },
    ); // ActiveLargeButton
  }
}
