import 'package:flutter/material.dart';
import 'package:qr_multidemo/secondary_tab_content_core.dart';
import 'secondary_tab_menu_common.dart';

/// タブバーの代わりにボタンを使用
class SecondayTabMenuBtn extends StatelessWidget {
  const SecondayTabMenuBtn({
    super.key,
    required this.tabController,
    this.onTap,
    required this.tabNames,
    required this.tabViews,
  });

  /// タブコントローラ
  final TabController tabController;

  /// タブ変更時の追加処理
  final ValueChanged<int>? onTap;

  /// タブ名称
  final List<String> tabNames;

  /// タブ内容
  final List<Widget> tabViews;

  @override
  Widget build(BuildContext context) {
    return DecoratedContainer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            // タブ切り替え通知をAnimationで受け取る
            child: AnimatedBuilder(
              animation: tabController.animation!,
              builder: (context, child) {
                return Row(
                  spacing: 8,
                  children: [
                    for (final MapEntry(key: index, value: tabName)
                        in tabNames.asMap().entries)
                      TransitionButton(
                        // isSelected: tabController.index == index,
                        isPushed: tabController.index == index,
                        text: tabName,
                        onPressed: () {
                          tabController.animateTo(index);
                          onTap?.call(index);
                        },
                        width: 170.0,
                      ), // TransitionButton
                    // 直接QR読取の業務ボタンを使用した場合
                    // TransitionButton(
                    //   text: tabName,
                    //   isPushed: tabController.index == index,
                    //   onPressed: () {
                    //     tabController.animateTo(index);
                    //     onTap?.call(index);
                    //   },
                    //   backgroundColors:
                    //       tabController.index == index
                    //           ? AppColor.green.gradientColors
                    //           : AppColor.orange.gradientColors,
                    //   foregroundColor: Colors.black,
                    // ),
                  ],
                ); // Row
              },
            ), // AnimatedBuilder
          ), // Padding
          Expanded(
            child: TabBarView(
              controller: tabController,
              // スワイプでタブ切替無効化
              physics: NeverScrollableScrollPhysics(),
              children: tabViews,
            ), // TabBarView
          ), // Expanded
        ],
      ),
    );
  }
}

// class _TabButton extends StatelessWidget {
//   const _TabButton({
//     required this.isSelected,
//     required this.text,
//     required this.onTap,
//   });
//
//   /// 担当タブを表示中か
//   final bool isSelected;
//
//   /// ボタンに表示する文字列
//   final String text;
//
//   /// タブ移動処理
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final btnText = Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Text(text, style: TextStyle(fontSize: 24)),
//     );
//
//     return SizedBox(
//       height: 68,
//       width: 200,
//       child: isSelected
//           ? /* selected widget */
//           : /* unselected widget */,
//     );
//   }
// }
