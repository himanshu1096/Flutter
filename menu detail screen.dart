import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_def.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/field_row.dart';

class MenuDetailScreen extends ConsumerWidget {
  const MenuDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu      = ref.watch(openMenuProvider)!;
    final fieldVals = ref.watch(fieldValuesProvider);
    final execState = ref.watch(execStateProvider);

    return Column(children: [
      // Sub-header
      Container(
        height: 28,
        color: AppColors.surface2,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              ref.read(openMenuProvider.notifier).state = null;
              ref.read(numpadProvider.notifier).close();
            },
            child: Row(children: [
              const Icon(Icons.arrow_back_ios_new, size: 10, color: AppColors.textDim),
              const Text(' 戻る', style: TextStyle(fontFamily: AppText.mono, fontSize: 9, color: AppColors.textDim)),
            ]),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text('${menu.code}  ${menu.label}',
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 10, color: AppColors.textSec, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis)),
          const Spacer(),
          if (menu.memoryBaseAddress != null)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(3)),
              child: Text('MEM ${menu.memoryBaseAddress}',
                style: const TextStyle(fontFamily: AppText.mono, fontSize: 7, color: AppColors.accent)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warnBg,
              border: Border.all(color: AppColors.warn.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(3)),
            child: FittedBox(fit: BoxFit.scaleDown,
              child: Text(menu.instruction, style: AppText.instruction)),
          ),
        ]),
      ),

      // Field rows
      Expanded(
        child: Container(
          color: AppColors.surface3,
          child: LayoutBuilder(builder: (ctx, constraints) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: menu.fields.length,
              itemBuilder: (ctx, i) {
                final field = menu.fields[i];
                final value = fieldVals[menu.code]?[field.num] ?? field.defaultValue;
                return FieldRow(
                  field: field,
                  value: value,
                  screenWidth: constraints.maxWidth,
                  onTap: field.type == FieldType.readonly
                      ? null
                      : field.type == FieldType.toggle
                          ? () => ref.read(fieldValuesProvider.notifier)
                              .setValue(menu.code, field.num, value == '1' ? '0' : '1')
                          : () => ref.read(numpadProvider.notifier).open(
                                menuCode: menu.code, fieldNum: field.num,
                                fieldLabel: field.label, currentValue: value,
                                isHex: field.type == FieldType.hex,
                                range: field.range,
                              ),
                );
              },
            );
          }),
        ),
      ),

      // Exec banner
      if (execState.status != ExecStatus.idle) _ExecBanner(state: execState),

      // Footer
      Container(
        height: 36,
        color: AppColors.surface2,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          const Spacer(),
          _FooterBtn('取消', AppColors.textDim, const Color(0xFFCCD5E0), () {
            ref.read(openMenuProvider.notifier).state = null;
            ref.read(numpadProvider.notifier).close();
          }),
          const SizedBox(width: 8),
          _FooterBtn('実行', Colors.white, AppColors.accent, () {
            final vals = ref.read(fieldValuesProvider)[menu.code] ?? {};
            ref.read(execStateProvider.notifier).execute(menu.code, vals);
          }, bold: true),
        ]),
      ),
    ]);
  }
}

class _FooterBtn extends StatelessWidget {
  final String label;
  final Color fg, bg;
  final VoidCallback onTap;
  final bool bold;
  const _FooterBtn(this.label, this.fg, this.bg, this.onTap, {this.bold = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bg == AppColors.accent ? AppColors.accent : AppColors.borderDark)),
      child: Text(label, style: TextStyle(fontFamily: AppText.mono, fontSize: 11,
        color: fg, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
    ),
  );
}

class _ExecBanner extends StatelessWidget {
  final ExecState state;
  const _ExecBanner({required this.state});
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (state.status) {
      case ExecStatus.loading: bg = AppColors.warnBg;   fg = AppColors.warn;    break;
      case ExecStatus.success: bg = const Color(0xFFEAF6EE); fg = AppColors.success; break;
      case ExecStatus.error:   bg = const Color(0xFFFAEAEA); fg = AppColors.danger;  break;
      default:                 bg = AppColors.surface2; fg = AppColors.textDim;
    }
    return Container(
      width: double.infinity, color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(children: [
        if (state.status == ExecStatus.loading)
          SizedBox(width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: fg)),
        const SizedBox(width: 8),
        Text(state.message, style: TextStyle(fontFamily: AppText.mono, fontSize: 10, color: fg)),
      ]),
    );
  }
}
