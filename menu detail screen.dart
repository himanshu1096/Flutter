import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_def.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/side_numpad.dart';

class MenuDetailScreen extends ConsumerWidget {
  const MenuDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu      = ref.watch(openMenuProvider)!;
    final offset    = ref.watch(fieldGroupOffsetProvider);   // ← fixed name
    final selIdx    = ref.watch(selectedFieldIndexProvider);
    final fieldVals = ref.watch(fieldValuesProvider);
    final npState   = ref.watch(numpadStateProvider);
    final execState = ref.watch(execProvider);

    // Visible 10 fields for current group
    final visibleFields = menu.fields.skip(offset * 10).take(10).toList();

    // Currently selected field
    final selField = selIdx < visibleFields.length ? visibleFields[selIdx] : null;
    final selValue = selField != null
        ? (fieldVals[menu.code]?[selField.num] ?? selField.defaultValue)
        : '';

    return Row(children: [
      // ── Main content area ──
      Expanded(
        child: Column(children: [

          // ── Breadcrumb + instruction ──
          _SubHeader(menu: menu),

          // ── Field rows (10 at a time) with scroll indicator ──
          Expanded(
            child: _FieldListWithArrow(
              fields: visibleFields,
              selIdx: selIdx,
              menuCode: menu.code,
              fieldVals: fieldVals,
              npState: npState,
              selField: selField,
              onTapField: (i, value) {
                if (npState.active && selField != null) {
                  ref.read(numpadStateProvider.notifier)
                      .confirm(menu.code, selField.num, format: selField.format);
                }
                ref.read(selectedFieldIndexProvider.notifier).state = i;
                ref.read(numpadStateProvider.notifier).activate(value);
              },
            ),
          ),

          // ── Bottom: selected field label + range + input box ──
          if (selField != null)
            _BottomInputArea(
              field: selField,
              npBuffer: npState.active ? npState.buffer : selValue,
              isActive: npState.active,
            ),

          // ── Execution status banner ──
          if (execState.status != ExecStatus.idle)
            _ExecBanner(state: execState),

          // ── 実行 / 取消 ──
          _ActionButtons(
            onExec: () {
              if (npState.active && selField != null) {
                ref.read(numpadStateProvider.notifier)
                    .confirm(menu.code, selField.num, format: selField.format);
              }
              final vals = ref.read(fieldValuesProvider)[menu.code] ?? {};
              ref.read(execProvider.notifier).run(menu.code, vals);
            },
            onCancel: () {
              ref.read(openMenuProvider.notifier).state = null;
              ref.read(numpadStateProvider.notifier).cancel();
              ref.read(selectedFieldIndexProvider.notifier).state = 0;
              ref.read(fieldGroupOffsetProvider.notifier).state = 0;  // ← fixed
            },
          ),
        ]),
      ),

      // ── Permanent right numpad ──
      SideNumpad(menuCode: menu.code),
    ]);
  }
}

// ─────────────────────────────────────────
// FIELD LIST WITH SCROLL DOWN ARROW
// ─────────────────────────────────────────
class _FieldListWithArrow extends StatefulWidget {
  final List<FieldDef> fields;
  final int selIdx;
  final String menuCode;
  final Map<String, Map<String, String>> fieldVals;
  final NumpadState npState;
  final FieldDef? selField;
  final void Function(int index, String value) onTapField;

  const _FieldListWithArrow({
    required this.fields, required this.selIdx, required this.menuCode,
    required this.fieldVals, required this.npState, required this.selField,
    required this.onTapField,
  });
  @override
  State<_FieldListWithArrow> createState() => _FieldListWithArrowState();
}

class _FieldListWithArrowState extends State<_FieldListWithArrow> {
  final ScrollController _scroll = ScrollController();
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didUpdateWidget(_FieldListWithArrow old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!_scroll.hasClients) return;
    final can = _scroll.position.maxScrollExtent > 0 &&
        _scroll.offset < _scroll.position.maxScrollExtent - 1;
    if (can != _canScrollDown) setState(() => _canScrollDown = can);
  }

  void _scrollToBottom() => _scroll.animateTo(
    _scroll.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut);

  @override
  void dispose() { _scroll.removeListener(_check); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: AppColors.surface,
        child: ListView.builder(
          controller: _scroll,
          itemCount: widget.fields.length,
          itemBuilder: (ctx, i) {
            final field      = widget.fields[i];
            final value      = widget.fieldVals[widget.menuCode]?[field.num] ?? field.defaultValue;
            final isSelected = i == widget.selIdx;
            final isReadonly = field.type == FieldType.readonly;
            final isToggle   = field.type == FieldType.toggle;

            return GestureDetector(
              onTap: isReadonly ? null : () => widget.onTapField(i, value),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.rowSelected
                      : (i.isEven ? AppColors.surface : AppColors.rowAlt),
                  border: const Border(bottom: BorderSide(color: AppColors.tableBorder))),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(children: [
                  SizedBox(width: 26, child: Text(field.num, style: AppText.fieldNum)),
                  const SizedBox(width: 8),
                  Expanded(flex: 3,
                    child: Text(field.label,
                      style: isSelected
                          ? AppText.fieldLabel.copyWith(fontWeight: FontWeight.w700)
                          : AppText.fieldLabel,
                      overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 2,
                    child: isToggle
                        ? Center(child: _ToggleChip(on: value == '1'))
                        : Text(
                            isSelected && widget.npState.active
                                ? widget.npState.buffer : value,
                            style: AppText.fieldValue.copyWith(
                              color: isSelected && widget.npState.active
                                  ? AppColors.accent : AppColors.textPrimary),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis)),
                ]),
              ),
            );
          },
        ),
      ),

      // ── Down arrow — shown when more content below ──
      if (_canScrollDown)
        Positioned(
          bottom: 6, left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _scrollToBottom,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.keyboard_arrow_down,
                      size: 15, color: AppColors.accent),
                  const SizedBox(width: 3),
                  Text('下へ', style: TextStyle(
                    fontFamily: AppText.mono, fontSize: 8,
                    color: AppColors.accent.withOpacity(0.85))),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}

// ─────────────────────────────────────────
// SUB HEADER
// ─────────────────────────────────────────
class _SubHeader extends StatelessWidget {
  final dynamic menu;
  const _SubHeader({required this.menu});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        color: AppColors.rowAlt,
        child: Text('< ${menu.label}  >',
          style: const TextStyle(fontFamily: AppText.mono,
            fontSize: 9, color: AppColors.textSec))),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        color: const Color(0xFFDDE8F4), // distinct light blue — never confused with yellow row
        child: Text(menu.instruction,
          style: const TextStyle(
            fontFamily: AppText.mono, fontSize: 9,
            color: Color(0xFF1A4A7A), fontWeight: FontWeight.w600))),
    ]);
  }
}

// ─────────────────────────────────────────
// BOTTOM INPUT AREA
// ─────────────────────────────────────────
class _BottomInputArea extends StatelessWidget {
  final FieldDef field;
  final String npBuffer;
  final bool isActive;
  const _BottomInputArea({
    required this.field, required this.npBuffer, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final fmt      = field.format;
    final rangeStr = fmt?.rangeDisplay ?? field.range?.displayRange ?? '';
    final enumStr  = fmt?.enumDesc;

    return Container(
      color: AppColors.rowAlt,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            // Field label
            Flexible(child: Text('${field.num}  ${field.label}',
              style: const TextStyle(fontFamily: AppText.mono,
                fontSize: 9, color: AppColors.textSec),
              overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            // Range
            if (rangeStr.isNotEmpty)
              Flexible(child: Text(rangeStr,
                style: AppText.rangeText,
                overflow: TextOverflow.ellipsis)),
            const Spacer(),
            // Input box
            Container(
              width: 160, height: 26,
              decoration: BoxDecoration(
                color: AppColors.inputBox,
                border: Border.all(
                  color: isActive ? AppColors.accent : AppColors.tableBorder,
                  width: isActive ? 1.5 : 1.0)),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.centerLeft,
              child: Row(children: [
                Expanded(child: Text(npBuffer,
                  style: AppText.fieldValue.copyWith(
                    color: isActive ? AppColors.accent : AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis)),
                if (isActive)
                  Container(width: 1.5, height: 16, color: AppColors.accent),
              ]),
            ),
          ]),
          // Enum description line (e.g. "0: なし / 1: あり")
          if (enumStr != null) ...[
            const SizedBox(height: 2),
            Text(enumStr,
              style: const TextStyle(
                fontFamily: AppText.mono, fontSize: 8,
                color: AppColors.accent),
              overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onExec;
  final VoidCallback onCancel;
  const _ActionButtons({required this.onExec, required this.onCancel});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rowAlt,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Btn('実行',  AppColors.accent,      Colors.white,     onExec),
        const SizedBox(width: 20),
        _Btn('取消',  Colors.white,          AppColors.textSec, onCancel,
          border: AppColors.tableBorder),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final VoidCallback onTap;
  final Color? border;
  const _Btn(this.label, this.bg, this.fg, this.onTap, {this.border});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 100, height: 32,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border ?? bg),
        borderRadius: BorderRadius.circular(3)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontFamily: AppText.mono,
        fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    ),
  );
}

// ─────────────────────────────────────────
// EXEC BANNER
// ─────────────────────────────────────────
class _ExecBanner extends StatelessWidget {
  final ExecState state;
  const _ExecBanner({required this.state});
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (state.status) {
      case ExecStatus.loading: bg = AppColors.warnBg;          fg = AppColors.warn;    break;
      case ExecStatus.success: bg = const Color(0xFFEAF6EA);   fg = AppColors.success; break;
      case ExecStatus.error:   bg = const Color(0xFFFAEAEA);   fg = AppColors.danger;  break;
      default:                 bg = AppColors.rowAlt;          fg = AppColors.textDim;
    }
    return Container(
      width: double.infinity, color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(children: [
        if (state.status == ExecStatus.loading)
          SizedBox(width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: fg)),
        const SizedBox(width: 8),
        Text(state.message,
          style: TextStyle(fontFamily: AppText.mono, fontSize: 10, color: fg)),
      ]),
    );
  }
}

// ─────────────────────────────────────────
// TOGGLE CHIP
// ─────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final bool on;
  const _ToggleChip({required this.on});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: on ? const Color(0xFFDDF0DD) : const Color(0xFFF0F0F0),
      border: Border.all(
        color: on ? AppColors.success : AppColors.tableBorder),
      borderRadius: BorderRadius.circular(2)),
    child: Text(on ? '1' : '0',
      style: TextStyle(fontFamily: AppText.mono, fontSize: 10,
        color: on ? AppColors.success : AppColors.textSec,
        fontWeight: FontWeight.w600)),
  );
}
