import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_multidemo/config/tcp_config.dart';
import '../rout_config.dart';
import '../service/app_logger.dart';
import '../service/tcp_service.dart';
import '../software_keyboard.dart';
import '../utility/confirm_dialog.dart';

/// フォントサイズ
const double _fontSize = 36.0;

/// フォントサイズだけのTextStyle
const TextStyle _styleOnlySize = TextStyle(fontSize: _fontSize);

// ─────────────────────────────────────────────────────────
// LoginPage
// ─────────────────────────────────────────────────────────
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
    // ログインページ表示後に初期化完了通知送信 (0x0A01)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitComplete();
    });
  }

  /// 初期化完了通知送信 (0x0A01)
  Future<void> _sendInitComplete() async {
    try {
      // await Future.delayed(
      //   Duration(milliseconds: TcpConfig().initCompleteDelayMs),
      // );
      await TcpService().sendInitComplete(result: true);
      AppLogger().info('LoginPage', '初期化完了通知送信完了 (0x0A01)');
    } catch (e) {
      AppLogger().error('LoginPage', '初期化完了通知送信エラー', e);
    }
  }

  /// 業務終了処理
  /// 1. 内部クリーンアップ
  /// 2. 0x0F01送信 (クリーンアップ失敗でも必ず送信)
  Future<void> _sendAppExit() async {
    try {
      await TcpService().cleanup();
    } catch (e) {
      AppLogger().error('LoginPage', 'クリーンアップエラー', e);
    } finally {
      try {
        await TcpService().sendAppExit();
        AppLogger().info('LoginPage', '0x0F01送信完了');
      } catch (e) {
        AppLogger().error('LoginPage', '0x0F01送信エラー', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Align(alignment: AlignmentGeometry.topLeft, child: _Logo()),
          Align(alignment: AlignmentGeometry.center, child: _LogInBox()),
          // Align(
          //   alignment: AlignmentGeometry.bottomCenter,
          //   // child: _ThemeChangeButtons(),
          // ), // Align
        ],
      ), // Stack
    ); // Scaffold
  }
}

// ─────────────────────────────────────────────────────────
// _Logo
// ─────────────────────────────────────────────────────────
// class _Logo extends StatelessWidget {
//   const _Logo();

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Image.asset(Assets.icon.logoTobu.keyName, scale: 0.5),
//     ); // ClipRRect
//   }
// }

// ─────────────────────────────────────────────────────────
// _LogInBox
// ─────────────────────────────────────────────────────────
class _LogInBox extends ConsumerStatefulWidget {
  const _LogInBox();

  @override
  ConsumerState<_LogInBox> createState() => _LogInBoxState();
}

class _LogInBoxState extends ConsumerState<_LogInBox> {
  final ValueNotifier<bool> _inputtedId = ValueNotifier(false);
  final ValueNotifier<bool> _inputtedPw = ValueNotifier(false);
  String _id = '';
  String _password = '';
  bool _isLoading = false;

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

  void _rebuild() => setState(() {});

  /// ログインボタン押下処理
  Future<void> _onLoginPressed() async {
    setState(() => _isLoading = true);
    try {
      final response = await TcpService().sendLoginRequest(
        id: _id,
        password: _password,
      );
      if (!mounted) return;
      if (response.isNormalUser) {
        // AUTHORITY = 1 → QR読取ページへ
        AppLogger().info('LoginPage', 'AUTHORITY=1 ログイン成功 → QR読取ページへ');
        context.pushNamed(Pages.stationSplash.name);
      } else if (response.isMaintenanceUser) {
        // AUTHORITY = 99 → ログインページに留まる
        AppLogger().info('LoginPage', 'AUTHORITY=99 保守員権限 → ログインページに留まる');
      } else {
        // AUTHORITY = 0 → 認証失敗ダイアログ
        AppLogger().warn(
          'LoginPage',
          'AUTHORITY=0 認証失敗: ERRCODE=${response.errCode}',
        );
        await _showAuthErrorDialog(response.errCode);
      }
    } catch (e) {
      if (!mounted) return;
      AppLogger().error('LoginPage', 'ログインエラー', e);
      await _showErrorDialog('通信エラー: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 認証失敗ダイアログ

  Future<void> _showAuthErrorDialog(int errCode) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomConfirmDialog(
            text: 'パスワードが違います',
            trueBtnText: '確認',
            hasFalseBtn: false,
          ),
    );
  }

  /// エラーダイアログ
  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomConfirmDialog(
            text: message,
            trueBtnText: '確認',
            hasFalseBtn: false,
          ),
    );
  }

  /// 業務終了処理
  /// 1. 内部クリーンアップ
  /// 2. 0x0F01送信 (クリーンアップ失敗でも必ず送信)
  Future<void> _sendAppExit() async {
    try {
      await TcpService().cleanup();
    } catch (e) {
      AppLogger().error('LoginPage', 'クリーンアップエラー', e);
    } finally {
      try {
        await TcpService().sendAppExit();
        AppLogger().info('LoginPage', '0x0F01送信完了');
      } catch (e) {
        AppLogger().error('LoginPage', '0x0F01送信エラー', e);
      }
    }
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
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
              _id = input ?? '';
              _inputtedId.value = !(input?.isEmpty ?? true);
            },
          ), // _TextBoxView
          _TextBoxView(
            iconData: Icons.lock,
            viewText: 'Password',
            keyboardUsage: KeyboardUsage.password,
            onChanged: (input) {
              _password = input ?? '';
              _inputtedPw.value = !(input?.isEmpty ?? true);
            },
          ), // _TextBoxView
          Row(
            spacing: spacing,
            children: [
              Expanded(
                child: FilledButton(
                  onPressed:
                      _inputtedId.value && _inputtedPw.value && !_isLoading
                          ? _onLoginPressed
                          : null,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text('ログイン', style: _styleOnlySize),
                ), // FilledButton
              ), // Expanded
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () async {
                    final confirm = await showDialog<bool?>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => CustomConfirmDialog(
                        text: '業務を終了します',
                        trueBtnText: '実行',
                      ),
                    );
                    if (confirm == true) {
                      await _sendAppExit();
                    }
                  },
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

// ─────────────────────────────────────────────────────────
// _TextBoxView
// ─────────────────────────────────────────────────────────
class _TextBoxView extends StatefulWidget {
  const _TextBoxView({
    required this.iconData,
    required this.viewText,
    required this.keyboardUsage,
    required this.onChanged,
  });

  final String viewText;
  final IconData iconData;
  final KeyboardUsage keyboardUsage;
  final void Function(String? input) onChanged;

  @override
  State<_TextBoxView> createState() => _TextBoxViewState();
}

class _TextBoxViewState extends State<_TextBoxView> {
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

  void _rebuild() => setState(() {});

  /// 業務終了処理
  /// 1. 内部クリーンアップ
  /// 2. 0x0F01送信 (クリーンアップ失敗でも必ず送信)
  Future<void> _sendAppExit() async {
    try {
      await TcpService().cleanup();
    } catch (e) {
      AppLogger().error('LoginPage', 'クリーンアップエラー', e);
    } finally {
      try {
        await TcpService().sendAppExit();
        AppLogger().info('LoginPage', '0x0F01送信完了');
      } catch (e) {
        AppLogger().error('LoginPage', '0x0F01送信エラー', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).hintColor;
    return InkWell(
      onTap: () async {
        final input = await showDialog<String?>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => SoftwareKeyboard(
                keyboardUsage: widget.keyboardUsage,
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
              offset: const Offset(4, 4),
              blurStyle: BlurStyle.inner,
            ), // BoxShadow
          ],
        ), // BoxDecoration
        child:
            (_input.value == null || _input.value!.isEmpty)
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
                      ? '*' * _input.value!.length
                      : _input.value!,
                  style: _styleOnlySize,
                ), // Text
      ), // Container
    ); // InkWell
  }
}

// ─────────────────────────────────────────────────────────
// _ThemeChangeButtons
// ─────────────────────────────────────────────────────────
