import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// NUMPAD OVERLAY
/// - Hides left NavPanel when open (so it fits 10.1")
/// - Content area shifts left, numpad on right
/// - Also responds to physical keyboard input
/// - Shows 設定値 (value range) card below display
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

    // Digits 0–9
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

    // Hex A–F (only when in hex mode)
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
      child: Positioned.fill(
        child: Row(
          children: [
            // ── Left: field list still visible (no nav panel) ──
            // The parent MainShellScreen hides NavPanel when numpad is open.
            // This space is used by MenuDetailScreen already.
            const Spacer(),

            // ── Right: numpad panel ──
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
// NUMPAD PANEL WIDGET
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
      width: 200,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.numpadBg,
        border: Border(left: BorderSide(color: Color(0xFF0D1520), width: 1.5)),
        boxShadow: [BoxShadow(color: Color(0x44000000), blurRadius: 20, offset: Offset(-4, 0))],
      ),
      child: Column(children: [
        // ── Field label header ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFF141E30),
          width: double.infinity,
          child: Row(children: [
            Expanded(
              child: Text(state.fieldLabel,
                style: const TextStyle(fontFamily: AppText.mono, fontSize: 9,
                  color: Color(0xFF7AB8E0), letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis),
            ),
            if (state.isHex)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)),
                child: const Text('HEX', style: TextStyle(fontFamily: AppText.mono,
                  fontSize: 7, color: AppColors.accent, fontWeight: FontWeight.w700)),
              ),
          ]),
        ),

        // ── Value display ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: const Color(0xFF0F1826),
          width: double.infinity,
          child: Row(children: [
            Expanded(
              child: Text(state.buffer.isEmpty ? '　' : state.buffer,
                style: const TextStyle(fontFamily: AppText.mono, fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 2),
                overflow: TextOverflow.ellipsis),
            ),
            // Blinking cursor
            Container(width: 2, height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1),
              )),
          ]),
        ),

        // ── 設定値 range card ──
        if (state.rangeDesc != null)
          Container(
            margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3050),
              border: Border.all(color: const Color(0xFF2A5080)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('設定値', style: TextStyle(fontFamily: AppText.mono,
                fontSize: 8, color: Color(0xFF4A90C0), fontWeight: FontWeight.w700,
                letterSpacing: 1)),
              const SizedBox(height: 3),
              Text(state.rangeDesc!, style: const TextStyle(fontFamily: AppText.mono,
                fontSize: 8, color: Color(0xFFAAC8E0)), maxLines: 2),
              if (state.rangeMin != null && state.rangeMin!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Text('MIN: ', style: TextStyle(fontFamily: AppText.mono, fontSize: 7, color: Color(0xFF5A88A8))),
                  Text(state.rangeMin!, style: const TextStyle(fontFamily: AppText.mono, fontSize: 8, color: Color(0xFF80D0FF), fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  const Text('MAX: ', style: TextStyle(fontFamily: AppText.mono, fontSize: 7, color: Color(0xFF5A88A8))),
                  Text(state.rangeMax!, style: const TextStyle(fontFamily: AppText.mono, fontSize: 8, color: Color(0xFF80D0FF), fontWeight: FontWeight.w600)),
                ]),
              ],
            ]),
          ),

        const SizedBox(height: 6),

        // ── Keys ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(children: [
              _row(['7', '8', '9', '⌫'], onKey),
              const SizedBox(height: 5),
              _row(['4', '5', '6', state.isHex ? 'A' : '.'], onKey),
              const SizedBox(height: 5),
              _row(['1', '2', '3', state.isHex ? 'B' : '0'], onKey),
              const SizedBox(height: 5),
              if (state.isHex) ...[
                _row(['C', 'D', 'E', 'F'], onKey),
                const SizedBox(height: 5),
                _row(['0', '.', 'CLR', ''], onKey, skip3: true),
              ] else
                _row(['0', '.', 'CLR', ''], onKey, skip3: true),
              const SizedBox(height: 5),
              // Cancel + OK
              Row(children: [
                Expanded(child: _key('取消', onKey, isCancel: true, onClose: onClose)),
                const SizedBox(width: 5),
                Expanded(flex: 2, child: _key('OK', onKey, isOk: true, onOk: onOk)),
              ]),
              // Keyboard hint
              const SizedBox(height: 4),
              const Text('⌨ キーボード入力対応', style: TextStyle(fontFamily: AppText.mono,
                fontSize: 7, color: Color(0xFF3A5070))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _row(List<String> keys, void Function(String) onKey, {bool skip3 = false}) {
    return Row(children: keys.asMap().entries.map((e) {
      if (skip3 && e.key == 3) return const Expanded(child: SizedBox());
      return Expanded(child: Padding(
        padding: EdgeInsets.only(left: e.key == 0 ? 0 : 5),
        child: _key(e.value, onKey),
      ));
    }).toList());
  }

  Widget _key(String label, void Function(String) onKey,
      {bool isCancel = false, bool isOk = false,
       VoidCallback? onClose, VoidCallback? onOk}) {
    Color bg, fg, bd;
    if (label == '⌫')    { bg = AppColors.numpadDel;   fg = const Color(0xFFFF9090); bd = const Color(0xFF7A3030); }
    else if (label == 'CLR') { bg = AppColors.numpadClear; fg = const Color(0xFFFFD080); bd = const Color(0xFF7A6020); }
    else if (isOk)        { bg = AppColors.numpadOk;    fg = const Color(0xFF80FF90); bd = const Color(0xFF2A8040); }
    else if (isCancel)    { bg = const Color(0xFF1A2030);fg = const Color(0xFF5A6878); bd = const Color(0xFF2A3040); }
    else if (RegExp(r'^[A-F]$').hasMatch(label)) { bg = AppColors.numpadHexKey; fg = const Color(0xFF80C8FF); bd = const Color(0xFF2A5080); }
    else                  { bg = AppColors.numpadKey;   fg = Colors.white;          bd = const Color(0xFF304060); }

    return GestureDetector(
      onTap: () {
        if (isOk) { onOk?.call(); return; }
        if (isCancel) { onClose?.call(); return; }
        onKey(label);
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(color: bg, border: Border.all(color: bd),
          borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          fontFamily: (isOk || isCancel) ? null : AppText.mono,
          fontSize: (isOk || isCancel) ? 11 : 14,
          fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }
}
