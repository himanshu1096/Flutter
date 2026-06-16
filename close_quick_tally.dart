import 'close_tally.dart';
import 'related_process_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 締め切速報
class CloseQuickTally extends StatelessWidget {
  const CloseQuickTally({super.key});

  @override
  Widget build(BuildContext context) {
    return PaddingForContent(
      child: SingleChildScrollView(child: CloseTallyMainContent()),
    );
  }
}

/// 画面下部のボタン
class _FooterButtons extends HookWidget {
  const _FooterButtons();

  /// ログインボタンのラベル
  static const _sinceLoginText = TextInCloseTallyBtn(text: 'ログイン');

  /// 前回締切ボタンのラベル
  static const _sincePreviousText = TextInCloseTallyBtn(text: '前回締切');

  @override
  Widget build(BuildContext context) {
    // ログインボタンと前回締切ボタンの活性状態をToggle管理
    final isSinceLogin = useState(false);

    /// ボタンの選択状態を変更する
    void changeToggle() {
      isSinceLogin.value = !isSinceLogin.value;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CloseTallyToggleBtn(
          isSelected: !isSinceLogin.value,
          onPressed: changeToggle,
          child: _sinceLoginText,
        ),
        // CloseTallyToggleBtn
        CloseTallyToggleBtn(
          isSelected: !isSinceLogin.value,
          onPressed: changeToggle,
          child: _sincePreviousText,
        ),
        // CloseTallyToggleBtn
        CloseTallyPrintBtn(onPressed: () {}),
        // CloseTallyPrintBtn
      ],
    );
    // Row
  }
}
