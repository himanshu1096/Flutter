import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_theme.dart';
import '../gen/assets.gen.dart';
import '../provider/provider.dart';
import '../rout_config.dart';
import '../software_keyboard.dart';

/// フォントサイズ
const double _fontSize = 36.0;

/// フォントサイズだけのTextStyle
const TextStyle _styleOnlySize = TextStyle(fontSize: _fontSize);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(alignment: AlignmentGeometry.topLeft, child: _Logo()),
          Align(alignment: AlignmentGeometry.center, child: _LogInBox()),
          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: _ThemeChangeButtons(),
          ), // Align
        ],
      ), // Stack
    ); // Scaffold
  }
}

class _Logo extends StatelessWidget {
  /// 東武ロゴ
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(Assets.icon.logoTobu.keyName, scale: 0.5),
    ); // ClipRRect
  }
}

class _LogInBox extends StatefulWidget {
  /// ログイン用のBox
  const _LogInBox();

  @override
  State<_LogInBox> createState() => _LogInBoxState();
}

class _LogInBoxState extends State<_LogInBox> {
  /// IDの入力状態
  final ValueNotifier<bool> _inputtedId = ValueNotifier(false);

  /// パスワードの入力状態
  final ValueNotifier<bool> _inputtedPw = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _inputtedId.addListener(_rebuild);
    _inputtedPw.addListener(_rebuild);
  }

  @override
  void dispose() {
    _inputtedId.removeListener(_rebuild);
    _inputtedPw.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 48.0;
    return Container(
      width: 600,
      height: 424.26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withValues(alpha: 0.9),
      ), // BoxDecoration
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: spacing,
        children: [
          Text(
            'ログイン',
            style: _styleOnlySize.copyWith(fontWeight: FontWeight.bold),
          ), // Text
          _TextBoxView(
            iconData: Icons.person,
            viewText: 'UserID',
            keyboardUsage: KeyboardUsage.loginId,
            onChanged: (input) {
              _inputtedId.value = !input.isNullOrEmpty;
            },
          ), // _TextBoxView
          _TextBoxView(
            iconData: Icons.lock,
            viewText: 'Password',
            keyboardUsage: KeyboardUsage.password,
            onChanged: (input) {
              _inputtedPw.value = !input.isNullOrEmpty;
            },
          ), // _TextBoxView
          Row(
            spacing: spacing,
            children: [
              // ID・Pwが入力済みなら活性
              Expanded(
                child: FilledButton(
                  onPressed:
                      _inputtedId.value && _inputtedPw.value
                          ? () {
                            context.pushNamed(Pages.stationSplash.name);
                          }
                          : null,
                  child: Text('ログイン', style: _styleOnlySize),
                ), // FilledButton
              ), // Expanded
              // 業務終了は常に活性
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: Text('業務終了', style: _styleOnlySize),
                ), // FilledButton.tonal
              ), // Expanded
            ],
          ), // Row
        ],
      ), // Column
    ); // Container
  }
}

class _TextBoxView extends StatefulWidget {
  /// テキストボックスっぽい表示欄
  const _TextBoxView({
    required this.iconData,
    required this.viewText,
    required this.keyboardUsage,
    required this.onChanged,
  });

  /// 表示する文字列
  final String viewText;

  /// 表示するアイコン
  final IconData iconData;

  /// キーボード種類
  final KeyboardUsage keyboardUsage;

  /// 入力値が変更されたときの処理
  final void Function(String? input) onChanged;

  @override
  State<_TextBoxView> createState() => _TextBoxViewState();
}

class _TextBoxViewState extends State<_TextBoxView> {
  /// 入力値
  final ValueNotifier<String?> _input = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _input.addListener(_rebuild);
  }

  @override
  void dispose() {
    _input.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).hintColor;
    return InkWell(
      onTap: () async {
        /// ソフトウェアキーボードを表示して入力値を受け取る
        final input = await showDialog<String?>(
          context: context,
          builder:
              (context) => SoftwareKeyboard(
                keyboardUsage: KeyboardUsage.loginId,
                initialText: _input.value ?? '',
              ), // SoftwareKeyboard
        );
        _input.value = input;
        widget.onChanged(input);
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black38, blurStyle: BlurStyle.inner),
            BoxShadow(
              color: Colors.white,
              blurRadius: 6,
              offset: Offset(4, 4),
              blurStyle: BlurStyle.inner,
            ), // BoxShadow
          ],
        ), // BoxDecoration
        child:
            _input.value.isNullOrEmpty
                ? Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.iconData, size: _fontSize, color: hintColor),
                    Text(
                      widget.viewText,
                      style: _styleOnlySize.copyWith(color: hintColor),
                    ), // Text
                  ],
                ) // Row
                : Text(
                  widget.keyboardUsage == KeyboardUsage.password
                      // 文字列を*に変換する
                      ? '*' * _input.value!.length
                      : _input.value!,
                  style: _styleOnlySize,
                ), // Text
      ), // Container
    ); // InkWell
  }
}

extension _StringExtension on String? {
  /// 入力欄がnullまたは空文字か
  bool get isNullOrEmpty {
    // nullならTrue、そうでなければ、空文字か判定
    return this == null ? true : this!.isEmpty;
  }
}

class _ThemeChangeButtons extends ConsumerWidget {
  /// Theme変更ボタン
  const _ThemeChangeButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 48,
        children: [
          for (var color in ThemeColors.values)
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(color.scheme.primary),
                foregroundColor: WidgetStatePropertyAll(color.scheme.onPrimary),
              ), // ButtonStyle
              onPressed: () {
                ref.read(currentThemeProvider.notifier).set(color.theme);
              },
              child: Text(color.name, style: _styleOnlySize),
            ), // ElevatedButton
        ],
      ), // Row
    ); // Padding
  }
}
