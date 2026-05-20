import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// NUMPAD OVERLAY
/// - Fixed width 240px, no overflow
/// - 設定値 range card truncates safely
/// - Physical keyboard supported
/// - NavPanel hidden when open (handled in main_shell_screen)
/// ─────────────────────────────────────────
class NumpadOverlay extends ConsumerStatefulWidget {
  const NumpadOverlay({super.key});
  @override ConsumerState<NumpadOverlay> createState() => _NumpadOverlayState();
}

class _NumpadOverlayState extends ConsumerState<NumpadOverlay> {
  final FocusNode _kbFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _kbFocus.requestFocus());
  }

  @override
  void dispose() {
    _kbFocus.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final notifier = ref.read(numpadProvider.notifier);
    final state    = ref.read(numpadProvider);
    final key      = event.logicalKey;

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      notifier.confirm(); return;
    }
    if (key == LogicalKeyboardKey.escape) {
      notifier.close(); return;
    }
    if (key == LogicalKeyboardKey.backspace) {
      notifier.pressKey('⌫'); return;
    }
    if (key == LogicalKeyboardKey.delete) {
      notifier.pressKey('CLR'); return;
    }

    final digits = {
      LogicalKeyboardKey.digit0: '0', LogicalKeyboardKey.digit1: '1',
      LogicalKeyboardKey.digit2: '2', LogicalKeyboardKey.digit3: '3',
      LogicalKeyboardKey.digit4: '4', LogicalKeyboardKey.digit5: '5',
      LogicalKeyboardKey.digit6: '6', LogicalKeyboardKey.digit7: '7',
      LogicalKeyboardKey.digit8: '8', LogicalKeyboardKey.digit9: '9',
      LogicalKeyboardKey.numpad0: '0', LogicalKeyboardKey.numpad1: '1',
      LogicalKeyboardKey.numpad2: '2', LogicalKeyboardKey.numpad3: '3',
      LogicalKeyboardKey.numpad4: '4', LogicalKeyboardKey.numpad5: '5',
      LogicalKeyboardKey.numpad6: '6', LogicalKeyboardKey.numpad7: '7',
      LogicalKeyboardKey.numpad8: '8', LogicalKeyboardKey.numpad9: '9',
      LogicalKeyboardKey.numpadDecimal: '.',
      LogicalKeyboardKey.period: '.',
    };
    if (digits.containsKey(key)) { notifier.pressKey(digits[key]!); return; }

    if (state.isHex) {
      final hexKeys = {
        LogicalKeyboardKey.keyA: 'A', LogicalKeyboardKey.keyB: 'B',
        LogicalKeyboardKey.keyC: 'C', LogicalKeyboardKey.keyD: 'D',
        LogicalKeyboardKey.keyE: 'E', LogicalKeyboardKey.keyF: 'F',
      };
      if (hexKeys.containsKey(key)) { notifier.pressKey(hexKeys[key]!); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final np = ref.watch(numpadProvider);
    return KeyboardListener(
      focusNode: _kbFocus,
      onKeyEvent: _handleKey,
      // Fills the content area (NavPanel already hidden by main_shell_screen)
      // Numpad is anchored to the RIGHT edge, content stays on LEFT
      child: Positioned.fill(
        child: Row(
          children: [
            // Left spacer — field list remains visible
            const Spacer(),
            // Numpad panel — fixed 240px wide, full height
            _NumpadPanel(
              state: np,
              onKey:   (k) => ref.read(numpadProvider.notifier).pressKey(k),
              onOk:    ()  => ref.read(numpadProvider.notifier).confirm(),
              onClose: ()  => ref.read(numpadProvider.notifier).close(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// NUMPAD PANEL — 240px wide, self-contained
// ─────────────────────────────────────────
class _NumpadPanel extends StatelessWidget {
  final NumpadState state;
  final void Function(String) onKey;
  final VoidCallback onOk;
  final VoidCallback onClose;
  const _NumpadPanel({required this.state, required this.onKey,
      required this.onOk, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,  // expanded from 200 → 240 to avoid range text overflow
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.numpadBg,
        border: Border(left: BorderSide(color: Color(0xFF0D1520), width: 1.5)),
        boxShadow: [BoxShadow(
          color: Color(0x55000000), blurRadius: 16, offset: Offset(-3, 0))],
      ),
      child: Column(children: [
        // ── Field label bar ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: const Color(0xFF141E30),
          child: Row(children: [
            Expanded(
              child: Text(state.fieldLabel,
                style: const TextStyle(fontFamily: AppText.mono, fontSize: 9,
                    color: Color(0xFF7AB8E0), letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            ),
            if (state.isHex)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)),
                child: const Text('HEX', style: TextStyle(
                  fontFamily: AppText.mono, fontSize: 7,
                  color: AppColors.accent, fontWeight: FontWeight.w700)),
              ),
          ]),
        ),

        // ── Value display ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: const Color(0xFF0F1826),
          child: Row(children: [
            Expanded(
              child: Text(
                state.buffer.isEmpty ? '　' : state.buffer,
                style: const TextStyle(fontFamily: AppText.mono, fontSize: 15,
                    fontWeight: FontWeight.w600, color: Colors.white,
                    letterSpacing: 1.5),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            ),
            // Cursor
            Container(
              width: 2, height: 16,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1))),
          ]),
        ),

        // ── 設定値 range card ──
        // Constrained width — text always wraps, never overflows
        if (state.rangeDesc != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3050),
              border: Border.all(color: const Color(0xFF2A5080)),
              borderRadius: BorderRadius.circular(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('設定値',
                  style: TextStyle(fontFamily: AppText.mono, fontSize: 8,
                      color: Color(0xFF4A90C0), fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
                const SizedBox(height: 3),
                // Description — wraps inside 240px panel, no overflow
                Text(state.rangeDesc!,
                  style: const TextStyle(fontFamily: AppText.mono, fontSize: 8,
                      color: Color(0xFFAAC8E0)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
                if (state.rangeMin != null && state.rangeMin!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  // MIN/MAX on separate lines to avoid overflow on long IP strings
                  Row(children: [
                    const Text('MIN: ', style: TextStyle(
                      fontFamily: AppText.mono, fontSize: 7,
                      color: Color(0xFF5A88A8))),
                    Expanded(
                      child: Text(state.rangeMin!,
                        style: const TextStyle(fontFamily: AppText.mono,
                            fontSize: 8, color: Color(0xFF80D0FF),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Text('MAX: ', style: TextStyle(
                      fontFamily: AppText.mono, fontSize: 7,
                      color: Color(0xFF5A88A8))),
                    Expanded(
                      child: Text(state.rangeMax!,
                        style: const TextStyle(fontFamily: AppText.mono,
                            fontSize: 8, color: Color(0xFF80D0FF),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1)),
                  ]),
                ],
              ],
            ),
          ),

        const SizedBox(height: 6),

        // ── Keys ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Column(children: [
              _row(['7', '8', '9', '⌫']),
              const SizedBox(height: 5),
              _row(['4', '5', '6', state.isHex ? 'A' : '.']),
              const SizedBox(height: 5),
              _row(['1', '2', '3', state.isHex ? 'B' : '0']),
              const SizedBox(height: 5),
              if (state.isHex) ...[
                _row(['C', 'D', 'E', 'F']),
                const SizedBox(height: 5),
                _rowPartial(['0', '.', 'CLR']),
              ] else
                _rowPartial(['0', '.', 'CLR']),
              const SizedBox(height: 5),
              // Cancel + OK
              Row(children: [
                Expanded(child: _key('取消', isCancel: true)),
                const SizedBox(width: 5),
                Expanded(flex: 2, child: _key('OK', isOk: true)),
              ]),
              const SizedBox(height: 4),
              const Text('⌨ キーボード入力対応',
                style: TextStyle(fontFamily: AppText.mono, fontSize: 7,
                    color: Color(0xFF3A5070))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _row(List<String> keys) {
    return Row(children: keys.asMap().entries.map((e) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: e.key == 0 ? 0 : 5),
        child: _key(e.value)))).toList());
  }

  // 3-key row + empty slot (replaces 4th column with spacer)
  Widget _rowPartial(List<String> keys) {
    return Row(children: [
      ...keys.asMap().entries.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: e.key == 0 ? 0 : 5),
          child: _key(e.value)))),
      const SizedBox(width: 5),
      const Expanded(child: SizedBox()),
    ]);
  }

  Widget _key(String label, {bool isCancel = false, bool isOk = false}) {
    Color bg, fg, bd;
    if (label == '⌫') {
      bg = AppColors.numpadDel;   fg = const Color(0xFFFF9090); bd = const Color(0xFF7A3030);
    } else if (label == 'CLR') {
      bg = AppColors.numpadClear; fg = const Color(0xFFFFD080); bd = const Color(0xFF7A6020);
    } else if (isOk) {
      bg = AppColors.numpadOk;    fg = const Color(0xFF80FF90); bd = const Color(0xFF2A8040);
    } else if (isCancel) {
      bg = const Color(0xFF1A2030); fg = const Color(0xFF5A6878); bd = const Color(0xFF2A3040);
    } else if (RegExp(r'^[A-F]$').hasMatch(label)) {
      bg = AppColors.numpadHexKey; fg = const Color(0xFF80C8FF); bd = const Color(0xFF2A5080);
    } else {
      bg = AppColors.numpadKey;   fg = Colors.white; bd = const Color(0xFF304060);
    }

    return GestureDetector(
      onTap: () {
        if (isOk)     { onOk();    return; }
        if (isCancel) { onClose(); return; }
        onKey(label);
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: bd),
          borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: Text(label,
          style: TextStyle(
            fontFamily: (isOk || isCancel) ? null : AppText.mono,
            fontSize:   (isOk || isCancel) ? 11   : 14,
            fontWeight: FontWeight.w600,
            color: fg)),
      ),
    );
  }
}
