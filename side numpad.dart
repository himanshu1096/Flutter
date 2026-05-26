import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_def.dart';
import '../models/field_format.dart';
import '../models/menu_def.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// PERMANENT RIGHT-SIDE NUMPAD
/// 終了 | 号5
/// [group N/M]
/// 前項 | 次項  (disabled at boundaries)
/// D  E  F
/// A  B  C
/// 7  8  9
/// 4  5  6
/// 1  2  3
/// 0(wide) ⌫
/// ログオフ
///
/// All key presses routed through FieldFormat
/// for auto-separators and range enforcement.
/// Physical keyboard also supported.
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

  // ── Get current field's format ──
  FieldFormat? _currentFormat() {
    final menu   = ref.read(openMenuProvider);
    if (menu == null) return null;
    final offset = ref.read(fieldGroupOffsetProvider);
    final selIdx = ref.read(selectedFieldIndexProvider);
    final visible = menu.fields.skip(offset * 10).take(10).toList();
    if (selIdx >= visible.length) return null;
    return visible[selIdx].format;
  }

  // ── Physical keyboard ──
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final k = event.logicalKey;

    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _confirmCurrent(); return;
    }
    if (k == LogicalKeyboardKey.escape)    { ref.read(numpadStateProvider.notifier).cancel(); return; }
    if (k == LogicalKeyboardKey.backspace) { _pressKey('⌫'); return; }
    if (k == LogicalKeyboardKey.delete)    { _pressKey('CLR'); return; }
    if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.tab) { _goNextField(); return; }
    if (k == LogicalKeyboardKey.arrowUp)   { _goPrevField(); return; }
    if (k == LogicalKeyboardKey.pageDown)  { _goNextGroup(); return; }
    if (k == LogicalKeyboardKey.pageUp)    { _goPrevGroup(); return; }

    if (!ref.read(numpadStateProvider).active) return;

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
    if (digits.containsKey(k)) { _pressKey(digits[k]!); return; }

    final hexKeys = {
      LogicalKeyboardKey.keyA:'A', LogicalKeyboardKey.keyB:'B',
      LogicalKeyboardKey.keyC:'C', LogicalKeyboardKey.keyD:'D',
      LogicalKeyboardKey.keyE:'E', LogicalKeyboardKey.keyF:'F',
    };
    if (hexKeys.containsKey(k)) _pressKey(hexKeys[k]!);
  }

  // ── Press key with format awareness ──
  void _pressKey(String key) {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    if (!ref.read(numpadStateProvider).active) {
      _activateSelected();
    }
    ref.read(numpadStateProvider.notifier)
        .pressKey(key, format: _currentFormat());
  }

  // ── Confirm current field ──
  void _confirmCurrent() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset  = ref.read(fieldGroupOffsetProvider);
    final selIdx  = ref.read(selectedFieldIndexProvider);
    final visible = menu.fields.skip(offset * 10).take(10).toList();
    if (selIdx < visible.length) {
      final field = visible[selIdx];
      ref.read(numpadStateProvider.notifier)
          .confirm(widget.menuCode, field.num, format: field.format);
    }
  }

  // ── Activate selected field ──
  void _activateSelected() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset  = ref.read(fieldGroupOffsetProvider);
    final selIdx  = ref.read(selectedFieldIndexProvider);
    final visible = menu.fields.skip(offset * 10).take(10).toList();
    if (selIdx < visible.length) {
      final field = visible[selIdx];
      if (field.type == FieldType.readonly) return;
      final cur = ref.read(fieldValuesProvider).getValue(menu.code, field.num);
      ref.read(numpadStateProvider.notifier).activate(cur);
    }
  }

  // ── Next/prev field (within group) ──
  void _goNextField() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset  = ref.read(fieldGroupOffsetProvider);
    final selIdx  = ref.read(selectedFieldIndexProvider);
    final visible = menu.fields.skip(offset * 10).take(10).toList();
    _confirmCurrent();
    if (selIdx < visible.length - 1) {
      ref.read(selectedFieldIndexProvider.notifier).state = selIdx + 1;
    } else if (canGoNext(menu, offset)) {
      ref.read(fieldGroupOffsetProvider.notifier).state = offset + 1;
      ref.read(selectedFieldIndexProvider.notifier).state = 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _activateSelected());
  }

  void _goPrevField() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    final selIdx = ref.read(selectedFieldIndexProvider);
    _confirmCurrent();
    if (selIdx > 0) {
      ref.read(selectedFieldIndexProvider.notifier).state = selIdx - 1;
    } else if (canGoPrev(offset)) {
      ref.read(fieldGroupOffsetProvider.notifier).state = offset - 1;
      ref.read(selectedFieldIndexProvider.notifier).state = 9;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _activateSelected());
  }

  // ── Next/prev GROUP (10 fields at a time) ──
  void _goNextGroup() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    if (!canGoNext(menu, offset)) return;
    _confirmCurrent();
    ref.read(fieldGroupOffsetProvider.notifier).state = offset + 1;
    ref.read(selectedFieldIndexProvider.notifier).state = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _activateSelected());
  }

  void _goPrevGroup() {
    final menu = ref.read(openMenuProvider);
    if (menu == null) return;
    final offset = ref.read(fieldGroupOffsetProvider);
    if (!canGoPrev(offset)) return;
    _confirmCurrent();
    ref.read(fieldGroupOffsetProvider.notifier).state = offset - 1;
    ref.read(selectedFieldIndexProvider.notifier).state = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _activateSelected());
  }

  @override
  Widget build(BuildContext context) {
    final menu        = ref.watch(openMenuProvider);
    final offset      = ref.watch(fieldGroupOffsetProvider);
    final prevEnabled = canGoPrev(offset);
    final nextEnabled = menu != null && canGoNext(menu, offset);
    final totalGroups = menu != null ? fieldGroupCount(menu) : 1;
    final groupLabel  = '${offset + 1} / $totalGroups';

    return KeyboardListener(
      focusNode: _focus,
      onKeyEvent: _handleKey,
      child: LayoutBuilder(builder: (ctx, constraints) {
        // Responsive key height based on available height
        final availH    = constraints.maxHeight;
        final keyRows   = 9; // number of key rows
        final keyH      = ((availH - 80) / keyRows).clamp(28.0, 46.0);

        return Container(
          width: 120,
          decoration: const BoxDecoration(
            color: AppColors.numpadBg,
            border: Border(left: BorderSide(color: AppColors.tableBorder))),
          child: Column(children: [

            // ── 終了 | 号5 ──
            _npRow([
              _NpBtn(label:'終了', h:keyH,
                bg: const Color(0xFFB0BCCC), fg: AppColors.textPrimary,
                onTap: () {
                  ref.read(openMenuProvider.notifier).state = null;
                  ref.read(numpadStateProvider.notifier).cancel();
                  ref.read(selectedFieldIndexProvider.notifier).state = 0;
                  ref.read(fieldGroupOffsetProvider.notifier).state = 0;
                }),
              _NpBtn(label:'号5', h:keyH,
                bg: const Color(0xFFB0BCCC), fg: AppColors.textPrimary,
                onTap: () {}),
            ]),

            _HDivider(),

            // ── Group indicator ──
            Container(
              height: 18,
              color: const Color(0xFFBBCBDB),
              alignment: Alignment.center,
              child: Text(groupLabel,
                style: const TextStyle(fontFamily: AppText.mono,
                  fontSize: 9, color: AppColors.textSec,
                  fontWeight: FontWeight.w600))),

            _HDivider(),

            // ── 前項 | 次項 ──
            _npRow([
              _NpBtn(label:'前項', h:keyH, enabled:prevEnabled,
                bg: const Color(0xFFB0BCCC), fg: AppColors.textPrimary,
                onTap: _goPrevGroup),
              _NpBtn(label:'次項', h:keyH, enabled:nextEnabled,
                bg: const Color(0xFFB0BCCC), fg: AppColors.textPrimary,
                onTap: _goNextGroup),
            ]),

            _HDivider(),

            // ── D E F ──
            _npRow([
              _NpBtn(label:'D', h:keyH, bg:AppColors.numpadHex, onTap:()=>_pressKey('D')),
              _NpBtn(label:'E', h:keyH, bg:AppColors.numpadHex, onTap:()=>_pressKey('E')),
              _NpBtn(label:'F', h:keyH, bg:AppColors.numpadHex, onTap:()=>_pressKey('F')),
            ]),
            // ── A B C ──
            _npRow([
              _NpBtn(label:'A', h:keyH, bg:AppColors.numpadHex, onTap:()=>_pressKey('A')),
              _NpBtn(label:'B', h:keyH, bg:AppColors.numpadHex, onTap:()=>_pressKey('B')),
              _NpBtn(label:'C', h:keyH, bg:AppColors.numpadHex, onTap:()=>_pressKey('C')),
            ]),
            // ── 7 8 9 ──
            _npRow([
              _NpBtn(label:'7', h:keyH, onTap:()=>_pressKey('7')),
              _NpBtn(label:'8', h:keyH, onTap:()=>_pressKey('8')),
              _NpBtn(label:'9', h:keyH, onTap:()=>_pressKey('9')),
            ]),
            // ── 4 5 6 ──
            _npRow([
              _NpBtn(label:'4', h:keyH, onTap:()=>_pressKey('4')),
              _NpBtn(label:'5', h:keyH, onTap:()=>_pressKey('5')),
              _NpBtn(label:'6', h:keyH, onTap:()=>_pressKey('6')),
            ]),
            // ── 1 2 3 ──
            _npRow([
              _NpBtn(label:'1', h:keyH, onTap:()=>_pressKey('1')),
              _NpBtn(label:'2', h:keyH, onTap:()=>_pressKey('2')),
              _NpBtn(label:'3', h:keyH, onTap:()=>_pressKey('3')),
            ]),
            // ── 0 (wide) | ⌫ ──
            _npRow([
              _NpBtn(label:'0',  h:keyH, flex:2, onTap:()=>_pressKey('0')),
              _NpBtn(label:'⌫', h:keyH,
                bg:const Color(0xFFCCAAAA), fg:AppColors.textPrimary,
                onTap:()=>_pressKey('⌫')),
            ]),

            const Spacer(),
            _HDivider(),

            // ── ログオフ ──
            _NpBtn(
              label: 'ログオフ', h: 28,
              bg: const Color(0xFFBBBBCC),
              fg: AppColors.textPrimary,
              onTap: () {}),
          ]),
        );
      }),
    );
  }

  Widget _npRow(List<_NpBtn> children) => Row(
    children: children.map((b) => Expanded(flex: b.flex, child: b)).toList());
}

// ─────────────────────────────────────────
// DIVIDER
// ─────────────────────────────────────────
class _HDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.tableBorder);
}

// ─────────────────────────────────────────
// BUTTON
// ─────────────────────────────────────────
class _NpBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final int flex;
  final double h;
  final bool enabled;

  const _NpBtn({
    required this.label,
    required this.onTap,
    required this.h,
    this.bg = AppColors.numpadKey,
    this.fg = AppColors.textPrimary,
    this.flex = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final eBg = enabled ? bg : const Color(0xFFD8DDE4);
    final eFg = enabled ? fg : AppColors.textDim;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: eBg,
          border: Border.all(color: AppColors.tableBorder, width: 0.5)),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
            style: TextStyle(
              fontFamily: AppText.mono, fontSize: 11,
              fontWeight: FontWeight.w600, color: eFg))),
      ),
    );
  }
}

// ── Extension ──
extension _FVExt on Map<String, Map<String, String>> {
  String getValue(String menuCode, String fieldNum) =>
      this[menuCode]?[fieldNum] ?? '';
}
