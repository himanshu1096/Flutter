import 'package:flutter/material.dart';
import '../models/field_def.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// FIELD ROW
/// Tighter flex ratios so the default value
/// stays fully visible even when the 240px
/// numpad overlaps from the right.
/// ─────────────────────────────────────────
class FieldRow extends StatelessWidget {
  final FieldDef field;
  final String value;
  final VoidCallback? onTap;
  final double screenWidth;

  const FieldRow({
    super.key,
    required this.field,
    required this.value,
    this.onTap,
    this.screenWidth = 600,
  });

  bool get _ro     => field.type == FieldType.readonly;
  bool get _toggle => field.type == FieldType.toggle;
  bool get _isHex  => field.type == FieldType.hex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: _ro ? Colors.transparent : Colors.white,
          border: Border.all(
            color: _ro ? Colors.transparent : AppColors.border),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _ro
              ? null
              : [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1))],
        ),
        child: Row(children: [

          // ── Row number (fixed 20px) ──
          SizedBox(
            width: 20,
            child: Text(field.num, style: AppText.fieldNum,
                textAlign: TextAlign.right)),
          const SizedBox(width: 8),

          // ── Label (flex 2 — compressed when numpad open) ──
          Expanded(
            flex: 2,
            child: Text(field.label,
              style: _ro
                  ? AppText.fieldLabel.copyWith(color: AppColors.textDim)
                  : AppText.fieldLabel,
              overflow: TextOverflow.ellipsis,
              maxLines: 1)),

          const SizedBox(width: 6),

          // ── Value / toggle (flex 2 — same weight as label) ──
          if (_toggle)
            _ToggleChip(on: value == '1')
          else
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _ro
                      ? const Color(0xFFF0F2F5)
                      : AppColors.surface3,
                  border: Border.all(
                    color: _ro
                        ? Colors.transparent
                        : AppColors.borderDark),
                  borderRadius: BorderRadius.circular(3)),
                child: Row(children: [
                  // HEX badge — small, doesn't push value out
                  if (_isHex && !_ro) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2)),
                      child: const Text('HEX', style: AppText.hexBadge)),
                    const SizedBox(width: 4),
                  ],
                  // Value — ellipsis so it never overflows
                  Expanded(
                    child: Text(value,
                      style: _ro
                          ? AppText.fieldValue.copyWith(
                              color: AppColors.textDim,
                              fontWeight: FontWeight.normal)
                          : AppText.fieldValue,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1)),
                  if (field.unit != null)
                    Text(' ${field.unit}',
                      style: const TextStyle(
                        fontFamily: AppText.mono,
                        fontSize: 9,
                        color: AppColors.textDim)),
                  if (!_ro) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.edit, size: 10,
                        color: AppColors.accentLight.withOpacity(0.5)),
                  ],
                ]),
              ),
            ),

          // ── Memory address badge — only on wide screens, hidden when tight ──
          if (field.memoryAddress != null && screenWidth > 520) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(2)),
              child: Text(field.memoryAddress!, style: AppText.memAddr)),
          ],

        ]),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final bool on;
  const _ToggleChip({required this.on});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: on
            ? AppColors.success.withOpacity(0.12)
            : const Color(0xFFF0F2F5),
        border: Border.all(
          color: on
              ? AppColors.success.withOpacity(0.5)
              : AppColors.borderDark),
        borderRadius: BorderRadius.circular(100)),
      child: Text(
        on ? 'ON  1' : 'OFF 0',
        style: TextStyle(
          fontFamily: AppText.mono,
          fontSize: 9,
          color: on ? AppColors.success : AppColors.textDim,
          fontWeight: FontWeight.w700)),
    );
  }
}
