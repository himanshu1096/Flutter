import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// PERMANENT RIGHT-SIDE NUMPAD
/// Layout (top to bottom):
///   終了 | 号5
///   前項 | 次項   ← disabled/enabled based on field group
///   D  E  F
///   A  B  C
///   7  8  9
///   4  5  6
///   1  2  3
///      0  ⌫
///   ログオフ
///
/// 前項/次項 paginate through field groups of 10.
/// 前項 disabled on first group, 次項 disabled on last group.
/// Physical keyboard also works.
/// ─────────────────────────────────────────
class SideNumpad extends ConsumerStatefulWidget {
  final String menuCode;
  const SideNumpad({super.key, required this.menuCode});
  @override ConsumerState<SideNumpad> createState() => _SideNumpadState();
}

class _SideNumpadState extends ConsumerState<SideNumpad> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  // ── Physical keyboard handler ──
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final k = event.logicalKey;
    final npState = ref.read(numpadStateProvider);

    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _confirmCurrent(); return;
    }
    if (k == LogicalKeyboardKey.escape) {
      ref.read(numpadStateProvider.notifier).cancel(); return;
    }
    if (k == LogicalKeyboardKey.backspace) {
      ref.read(numpadStateProvider.notifier).pressKey('⌫'); return;
    }
    if (k == LogicalKeyboardKey.delete) {
      ref.read(numpadStateProvider.notifier).pressKey('CLR'); return;
    }
    if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.tab) {
      _goNextField(); return;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      _goPrevField(); return;
    }

    if (!npState.active) return;

    final digits = {
      LogicalKeyboardKey.digit0:'0', LogicalKeyboardKey.digit1:'1',
      LogicalKeyboardKey.digit2:'2', LogicalKeyboardKey.digit3:'3',
      LogicalKeyboardKey.digit4:'4', LogicalKeyboardKey.digit5:'5',
      LogicalKeyboardKey.digit6:'6', LogicalKeyboardKey.digit7:'7',
      LogicalKeyboardKey.digit8:'8', LogicalKeyboardKey.digit9:'9',
      LogicalKeyboardKey.numpad0:'0', LogicalKeyboardKey.numpad1:'1',
      LogicalKeyboardKey.numpad2:'2', LogicalKeyboardKey.numpad3:'3',
      LogicalKeyboardKey.numpad4:'4', LogicalKeyboardKey.numpad5:'5',
      LogicalKeyboardKey.numpad6:'6', LogicalKeyboardKey.numpad7:'7',
      LogicalKeyboardKey.numpad8:'8', LogicalKeyboardKey.numpad9:'9',
      LogicalKeyboardKey.period:'.', LogicalKeyboardKey.numpadDecimal:'.',
    };
    if (digits.containsKey(k)) {
      ref.read(numpadStateProvider.notifier).pressKey(digits[k]!); return;
    }

    final hexKeys = {
      LogicalKeyboardKey.keyA:'A', LogicalKeyboardKey.keyB:'B',
      LogicalKeyboardKey.keyC:'C', LogicalKeyboardKey.keyD:'D',
      LogicalKeyboardKey.keyE:'E', LogicalKeyboardKey.keyF:'F',
    };
    if (hexKeys.containsKey(k)) {
      ref.read(numpadStateProvider.notifier).pressKey(hexKeys[k]!);
    }
  }

  // ── Confirm currently active field input ──
  void _confirmCurrent() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    final selIdx = ref.read(selectedFieldIndexProvider);
    final visible = menu.fields.skip(offset * 10).take(10).toList();
    if (selIdx < visible.length) {
      ref.read(numpadStateProvider.notifier)
          .confirm(widget.menuCode, visible[selIdx].num);
    }
  }

  // ── Move to next field within current group ──
  void _goNextField() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset  = ref.read(fieldGroupOffsetProvider);
    final selIdx  = ref.read(selectedFieldIndexProvider);
    final visible = menu.fields.skip(offset * 10).take(10).toList();

    _confirmCurrent();

    if (selIdx < visible.length - 1) {
      // Move within current group
      final newIdx = selIdx + 1;
      ref.read(selectedFieldIndexProvider.notifier).state = newIdx;
      _activateField(menu, offset, newIdx);
    } else {
      // At end of group — go to next group if available
      if (canGoNext(menu, offset)) {
        final newOffset = offset + 1;
        ref.read(fieldGroupOffsetProvider.notifier).state = newOffset;
        ref.read(selectedFieldIndexProvider.notifier).state = 0;
        _activateField(menu, newOffset, 0);
      }
    }
  }

  // ── Move to previous field within current group ──
  void _goPrevField() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    final selIdx = ref.read(selectedFieldIndexProvider);

    _confirmCurrent();

    if (selIdx > 0) {
      // Move within current group
      final newIdx = selIdx - 1;
      ref.read(selectedFieldIndexProvider.notifier).state = newIdx;
      _activateField(menu, offset, newIdx);
    } else {
      // At start of group — go to previous group if available
      if (canGoPrev(offset)) {
        final newOffset = offset - 1;
        ref.read(fieldGroupOffsetProvider.notifier).state = newOffset;
        ref.read(selectedFieldIndexProvider.notifier).state = 9;
        _activateField(menu, newOffset, 9);
      }
    }
  }

  // ── Go to NEXT GROUP of 10 fields (次項 button) ──
  void _goNextGroup() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    if (!canGoNext(menu, offset)) return;

    _confirmCurrent();
    final newOffset = offset + 1;
    ref.read(fieldGroupOffsetProvider.notifier).state = newOffset;
    ref.read(selectedFieldIndexProvider.notifier).state = 0;
    _activateField(menu, newOffset, 0);
  }

  // ── Go to PREVIOUS GROUP of 10 fields (前項 button) ──
  void _goPrevGroup() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    if (!canGoPrev(offset)) return;

    _confirmCurrent();
    final newOffset = offset - 1;
    ref.read(fieldGroupOffsetProvider.notifier).state = newOffset;
    ref.read(selectedFieldIndexProvider.notifier).state = 0;
    _activateField(menu, newOffset, 0);
  }

  // ── Activate (highlight + start editing) a specific field ──
  void _activateField(MenuDef menu, int groupOffset, int fieldIdx) {
    final visible = menu.fields.skip(groupOffset * 10).take(10).toList();
    if (fieldIdx < visible.length) {
      final field = visible[fieldIdx];
      if (field.type == FieldType.readonly) {
        ref.read(numpadStateProvider.notifier).cancel();
      } else {
        final cur = ref.read(fieldValuesProvider).getValue(menu.code, field.num);
        ref.read(numpadStateProvider.notifier).activate(cur);
      }
    }
  }

  // ── Press a numpad key ──
  void _pressKey(String key) {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;

    // Auto-activate selected field if not yet active
    if (!ref.read(numpadStateProvider).active) {
      final offset = ref.read(fieldGroupOffsetProvider);
      final selIdx = ref.read(selectedFieldIndexProvider);
      _activateField(menu, offset, selIdx);
    }
    ref.read(numpadStateProvider.notifier).pressKey(key);
  }

  @override
  Widget build(BuildContext context) {
    final menu   = ref.watch(openMenuProvider);
    final offset = ref.watch(fieldGroupOffsetProvider);

    final prevEnabled = canGoPrev(offset);
    final nextEnabled = menu != null && canGoNext(menu, offset);

    // Show current group info e.g. "1/2"
    final totalGroups = menu != null ? fieldGroupCount(menu) : 1;
    final groupLabel  = '${offset + 1}/$totalGroups';

    return KeyboardListener(
      focusNode: _focus,
      onKeyEvent: _handleKey,
      child: Container(
        width: 92,
        decoration: const BoxDecoration(
          color: AppColors.numpadBg,
          border: Border(left: BorderSide(color: AppColors.tableBorder))),
        child: Column(children: [

          // ── 終了 | 号5 ──
          _Row(children: [
            _Btn(label: '終了', onTap: () {
              ref.read(openMenuProvider.notifier).state = null;
              ref.read(numpadStateProvider.notifier).cancel();
              ref.read(selectedFieldIndexProvider.notifier).state = 0;
              ref.read(fieldGroupOffsetProvider.notifier).state = 0;
            }),
            _Btn(label: '号5', onTap: () {}),
          ]),

          _HDivider(),

          // ── Field group indicator ──
          Container(
            height: 18,
            color: const Color(0xFFB8C8D8),
            alignment: Alignment.center,
            child: Text(groupLabel,
              style: const TextStyle(fontFamily: AppText.mono,
                fontSize: 8, color: AppColors.textSec)),
          ),

          _HDivider(),

          // ── 前項 | 次項 ──
          // 前項 disabled (grayed) when on first group
          // 次項 disabled (grayed) when on last group
          _Row(children: [
            _Btn(
              label: '前項',
              enabled: prevEnabled,
              onTap: _goPrevGroup,
            ),
            _Btn(
              label: '次項',
              enabled: nextEnabled,
              onTap: _goNextGroup,
            ),
          ]),

          _HDivider(),

          // ── Hex keys D E F ──
          _Row(children: [
            _Btn(label: 'D', bg: AppColors.numpadHex, onTap: () => _pressKey('D')),
            _Btn(label: 'E', bg: AppColors.numpadHex, onTap: () => _pressKey('E')),
            _Btn(label: 'F', bg: AppColors.numpadHex, onTap: () => _pressKey('F')),
          ]),

          // ── Hex keys A B C ──
          _Row(children: [
            _Btn(label: 'A', bg: AppColors.numpadHex, onTap: () => _pressKey('A')),
            _Btn(label: 'B', bg: AppColors.numpadHex, onTap: () => _pressKey('B')),
            _Btn(label: 'C', bg: AppColors.numpadHex, onTap: () => _pressKey('C')),
          ]),

          // ── 7 8 9 ──
          _Row(children: [
            _Btn(label: '7', onTap: () => _pressKey('7')),
            _Btn(label: '8', onTap: () => _pressKey('8')),
            _Btn(label: '9', onTap: () => _pressKey('9')),
          ]),

          // ── 4 5 6 ──
          _Row(children: [
            _Btn(label: '4', onTap: () => _pressKey('4')),
            _Btn(label: '5', onTap: () => _pressKey('5')),
            _Btn(label: '6', onTap: () => _pressKey('6')),
          ]),

          // ── 1 2 3 ──
          _Row(children: [
            _Btn(label: '1', onTap: () => _pressKey('1')),
            _Btn(label: '2', onTap: () => _pressKey('2')),
            _Btn(label: '3', onTap: () => _pressKey('3')),
          ]),

          // ── 0 (wide) | ⌫ ──
          _Row(children: [
            _Btn(label: '0', flex: 2, onTap: () => _pressKey('0')),
            _Btn(
              label: '⌫',
              bg: const Color(0xFFCCAAAA),
              onTap: () => _pressKey('⌫')),
          ]),

          const Spacer(),

          _HDivider(),

          // ── ログオフ ──
          _Btn(
            label: 'ログオフ',
            height: 28,
            bg: const Color(0xFFBBBBCC),
            onTap: () {},
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────

class _Row extends StatelessWidget {
  final List<_Btn> children;
  const _Row({required this.children});
  @override
  Widget build(BuildContext context) => Row(
    children: children.map((b) => Expanded(flex: b.flex, child: b)).toList());
}

class _HDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.tableBorder);
}

class _Btn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color? fg;
  final VoidCallback onTap;
  final int flex;
  final double height;
  final bool enabled;

  const _Btn({
    required this.label,
    required this.onTap,
    this.bg = AppColors.numpadKey,
    this.fg,
    this.flex = 1,
    this.height = 34,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = enabled ? bg : const Color(0xFFD8DDE4);
    final effectiveFg = enabled
        ? (fg ?? AppColors.textPrimary)
        : AppColors.textDim;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: effectiveBg,
          border: Border.all(color: AppColors.tableBorder, width: 0.5)),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
            style: TextStyle(
              fontFamily: AppText.mono,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: effectiveFg)),
        ),
      ),
    );
  }
}

// ── Extension to read field value cleanly ──
extension _FieldValExt on Map<String, Map<String, String>> {
  String getValue(String menuCode, String fieldNum) =>
      this[menuCode]?[fieldNum] ?? '';
}
