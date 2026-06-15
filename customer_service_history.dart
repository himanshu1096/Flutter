import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:qr_multidemo/secondary_tab_content_core.dart';
import '../app_color.dart';
import '../app_icon.dart';
import '../pop_out_button.dart';
import '../qr_process/secondary_tab_content_unselected.dart';
import '../utility/date_time_converter.dart';
import 'related_process_common.dart';

/// ページ送りの方向
enum _PagerDirection { previous, next }

final TextStyle _btnTextStyle = TextStyle(fontSize: fontSize);

class CustomerServiceHistory extends StatelessWidget {
  const CustomerServiceHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return PaddingForContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(flex: 3, child: _HistoryView()),
          Flexible(flex: 1, child: _FooterControllers()),
        ],
      ), // Column
    ); // PaddingForContent
  }
}

class _HistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final cardBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final cardOutlineColor = Theme.of(context).colorScheme.surfaceContainer;

    return CardInfoBlock(
      title: '接客履歴データ',
      fontColor: fontColor,
      cardBackgroundColor: cardBackgroundColor,
      cardOutlineColor: cardOutlineColor,
      icon: DualIconOverlay(
        baseIcon: Icons.person_2_outlined,
        topIcon: Icons.history_edu_outlined,
        baseColor: fontColor,
        topColor: fontColor,
        topBackgroundColor: cardBackgroundColor,
      ), // DualIconOverlay
      // icon: Icon(Icons.support_agent_outlined, size: 40.0, color: fontColor),
      // width: 100.0,
      content: DefaultTextStyle(
        style: TextStyle(fontSize: fontSize, color: Colors.black),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 10.0,
          children: [
            SizedBox(
              height: 250,
              child: GridView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ), // EdgeInsets.symmetric
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 30,
                  mainAxisExtent: 120,
                ), // SliverGridDelegateWithFixedCrossAxisCount
                shrinkWrap: true,
                children: _makeHistoryItemList(),
              ), // GridView
            ), // SizedBox
            _PagerBottons(),
          ],
        ), // Column
      ), // DefaultTextStyle
    ); // CardInfoBlock
  }

  List<_HistoryItem> _makeHistoryItemList() {
    final todayStr = DateTime.now().toStringWithFormat('M/d');
    return [
      _HistoryItem(
        date: todayStr,
        time: '6:37',
        number: '00007403',
        ticketName: '普通券',
        processName: '精算処理',
        tableRows: [
          TableRow(
            children: [
              TableTitleCell(title: '金額'),
              TableContentCell(text: '1,020', unit: '円'),
              TableTitleCell(title: '現金'),
              TableContentCell(text: '1,020', unit: '円'),
              TableTitleCell(title: '磁気ＳＦ'),
              TableContentCell(text: '1,020', unit: '円'),
            ],
          ), // TableRow
        ],
      ), // _HistoryItem
      _HistoryItem(
        date: todayStr,
        time: '7:31',
        number: '00007403',
        ticketName: 'ＩＣＳＦ',
        processName: '紛失再発',
        tableRows: [
          TableRow(
            children: [
              TableTitleCell(title: '金額'),
              TableContentCell(text: '1,020', unit: '円'),
              TableTitleCell(title: '手数料'),
              TableContentCell(text: '1,020', unit: '円'),
              TableTitleCell(title: 'デポ額'),
              TableContentCell(text: '1,020', unit: '円'),
            ],
          ), // TableRow
          TableRow(
            children: [
              TableTitleCell(title: 'PB80B025020300400'),
              TableContentCell(text: '000-05818-1701-00888'),
            ],
          ), // TableRow
        ],
      ), // _HistoryItem
      _HistoryItem(
        date: todayStr,
        time: '7:42',
        number: '00007403',
        ticketName: '企画券',
        processName: '発売処理',
        tableRows: [
          TableRow(
            children: [
              TableTitleCell(title: '枚数'),
              TableContentCell(text: '102', unit: '枚'),
            ],
          ), // TableRow
        ],
      ), // _HistoryItem
      _HistoryItem(
        date: todayStr,
        time: '7:59',
        number: '00007403',
        ticketName: '企画券',
        processName: '発売処理',
        tableRows: [
          TableRow(
            children: [
              TableTitleCell(title: '枚数'),
              TableContentCell(text: '102', unit: '枚'),
            ],
          ), // TableRow
        ],
      ), // _HistoryItem
      _HistoryItem(
        date: todayStr,
        time: '8:18',
        number: '00007403',
        ticketName: 'ＩＣ定期',
        processName: '強制出場',
        tableRows: [
          TableRow(
            children: [
              TableTitleCell(title: 'PB80B025020300400'),
              TableContentCell(text: '000-05818-1701-00888'),
            ],
          ), // TableRow
        ],
      ), // _HistoryItem
      _HistoryItem(
        date: todayStr,
        time: '8:37',
        number: '00007403',
        ticketName: '普通券',
        processName: '精算処理',
        tableRows: [
          TableRow(
            children: [
              TableTitleCell(title: '金額'),
              TableContentCell(text: '1,020', unit: '円'),
              TableTitleCell(title: '現金'),
              TableContentCell(text: '1,020', unit: '円'),
              TableTitleCell(title: '磁気ＳＦ'),
              TableContentCell(text: '1,020', unit: '円'),
            ],
          ), // TableRow
        ],
      ), // _HistoryItem
    ];
  }
}

class _HistoryItem extends StatelessWidget {
  final String date;
  final String time;
  final String number;
  final String ticketName;
  final String processName;
  final List<TableRow> tableRows;

  const _HistoryItem({
    required this.date,
    required this.time,
    required this.number,
    required this.ticketName,
    required this.processName,
    required this.tableRows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: FittedBox(child: Text(date))),
            Flexible(child: FittedBox(child: Text(time))),
            Flexible(child: FittedBox(child: Text(number))),
            Flexible(child: FittedBox(child: Text(ticketName))),
            Flexible(child: FittedBox(child: Text(processName))),
          ],
        ), // Row
        for (var row in tableRows) TableInContent(children: [row]),
      ],
    ); // Column
  }
}

class _PagerBottons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          _PagerBotton(direction: _PagerDirection.previous, onPressed: null),
          Text('1/2'),
          _PagerBotton(direction: _PagerDirection.next, onPressed: () {}),
        ],
      ), // Row
    ); // Padding
  }
}

class _PagerBotton extends StatelessWidget {
  final _PagerDirection direction;
  final VoidCallback? onPressed;

  /// ページ送りボタン
  const _PagerBotton({required this.direction, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const btnRadius = Radius.circular(20);
    Color foregroundCallBack(Set<WidgetState> states) =>
        states.contains(WidgetState.disabled)
            ? AppColor.grey.no300
            : AppColor.grey.no700;

    return GradientElevatedButton(
      style: GradientButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        backgroundGradient: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled)
                  ? LinearGradient(
                    colors: [AppColor.grey.no400, AppColor.grey.no400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ) // LinearGradient
                  : LinearGradient(
                    colors: AppColor.grey.gradientLightColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ), // LinearGradient
        ),
        foregroundColor: WidgetStateProperty.resolveWith(foregroundCallBack),
        iconColor: WidgetStateProperty.resolveWith(foregroundCallBack),
        shape: WidgetStateProperty.all(
          BeveledRectangleBorder(
            borderRadius: switch (direction) {
              _PagerDirection.previous => BorderRadiusGeometry.only(
                topLeft: btnRadius,
                bottomLeft: btnRadius,
              ), // BorderRadiusGeometry.only
              _PagerDirection.next => BorderRadiusGeometry.only(
                topRight: btnRadius,
                bottomRight: btnRadius,
              ), // BorderRadiusGeometry.only
            },
          ), // BeveledRectangleBorder
        ),
        side: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled)
                  ? null
                  : BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        shadowColor: WidgetStateProperty.all(Colors.black),
        elevation: WidgetStateProperty.resolveWith<double>(
          (states) => states.contains(WidgetState.disabled) ? 0 : 4,
        ),
      ), // GradientButtonStyle
      onPressed: onPressed,
      child: Padding(
        // アイコンを中央寄せ
        padding: switch (direction) {
          _PagerDirection.previous => EdgeInsets.only(left: 16.0),
          _PagerDirection.next => EdgeInsets.only(right: 16.0),
        },
        child: Icon(switch (direction) {
          _PagerDirection.previous => Icons.arrow_back_ios,
          _PagerDirection.next => Icons.arrow_forward_ios,
        }, size: fontSize * 1.3), // Icon
      ), // Padding
    ); // GradientElevatedButton
  }
}

class _FooterControllers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Flexible(fit: FlexFit.tight, flex: 4, child: _SelectDateBottons()),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: _AnotherDateInputAndPrintBotton(),
        ), // Flexible
      ],
    ); // Row
  }
}

class _SelectDateBottons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: EdgeInsets.only(top: 8, bottom: 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 4 / 1,
      ), // SliverGridDelegateWithFixedCrossAxisCount
      children: [
        SetBackButton(
          backgroundColors: AppColor.orange.gradientColors,
          onPressed: () {},
          child: Text(
            '当日',
            style: _btnTextStyle.merge(TextStyle(color: Colors.black)),
          ), // Text
        ), // SetBackButton
        // 過去日一週間分のボタン
        for (var i = 1; i < 8; i++)
          PopOutButton(
            backgroundColors: AppColor.blueGrey.gradientColors,
            onPressed: () {},
            child: Text(
              DateTime.now().add(Duration(days: -i)).toDateOnlyString(),
              style: _btnTextStyle,
            ), // Text
          ), // PopOutButton
      ],
    ); // GridView
  }
}

class _AnotherDateInputAndPrintBotton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('その他の日付', style: TextStyle(fontWeight: FontWeight.w700)),
            TextFieldShadow(
              topStops: [0.0, 0.15],
              leftStops: [0.0, 0.04],
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(0),
                  ), // OutlineInputBorder
                ), // InputDecoration
              ), // TextField
            ), // TextFieldShadow
          ],
        ), // Column
        PopOutButton.icon(
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.check_circle),
          ), // Padding
          iconSize: fontSize,
          backgroundColors: completedGradient,
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Text('印刷', style: _btnTextStyle),
          ), // Padding
        ), // PopOutButton.icon
      ],
    ); // Column
  }
}
