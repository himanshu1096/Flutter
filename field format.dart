/// ─────────────────────────────────────────
/// FIELD INPUT FORMAT
/// Defines real-time formatting rules:
/// - auto-insert separators (. - /)
/// - allowed characters (digits, hex)
/// - value range validation
/// - description shown in 設定値 card
/// ─────────────────────────────────────────

enum FormatType {
  plain,       // free hex/text input
  ipAddress,   // NNN.NNN.NNN.NNN
  codeHyphen,  // NNN-NNN  (3+3 digits)
  code2Hyphen, // NN-NNN   (2+3 digits)
  ipLike4,     // NNN-NNN-NNN-NNN (4 groups of 3, hyphen separated)
  ipLike2x3,   // NN-NNN-NN-NNN
  toggle,      // 0 or 1 only
  hexByte,     // 2 hex chars  (00–FF)
  hexWord,     // 4 hex chars  (0000–FFFF)
  hexDword,    // 8 hex chars
  hexRange,    // hex with explicit min/max e.g. 0x30–0x7F
  decimal,     // plain decimal with min/max
  decimalLarge,// large decimal no separator
}

class FieldFormat {
  final FormatType type;
  final int? minVal;
  final int? maxVal;
  final String rangeDisplay; // shown in 設定値 card
  final String? enumDesc;    // e.g. "0: なし / 1: あり"

  const FieldFormat({
    required this.type,
    this.minVal,
    this.maxVal,
    this.rangeDisplay = '',
    this.enumDesc,
  });

  // ── Presets ──
  static const toggle = FieldFormat(
    type: FormatType.toggle, minVal: 0, maxVal: 1,
    rangeDisplay: '0 または 1');

  static const hexByte = FieldFormat(
    type: FormatType.hexByte, minVal: 0, maxVal: 0xFF,
    rangeDisplay: '00〜FF');

  static const hexWord = FieldFormat(
    type: FormatType.hexWord, minVal: 0, maxVal: 0xFFFF,
    rangeDisplay: '0000〜FFFF');

  static const hexDword = FieldFormat(
    type: FormatType.hexDword, minVal: 0, maxVal: 0xFFFFFFFF,
    rangeDisplay: '00000000〜FFFFFFFF');

  static const ipAddress = FieldFormat(
    type: FormatType.ipAddress,
    rangeDisplay: '000.000.000.000〜255.255.255.255');

  static const codeHyphen = FieldFormat(
    type: FormatType.codeHyphen,
    rangeDisplay: '000-000〜999-999');

  static const code2Hyphen = FieldFormat(
    type: FormatType.code2Hyphen,
    rangeDisplay: '00-000〜99-999');

  // NNN-NNN-NNN-NNN (like 03 自駅設定)
  static const ipLike4 = FieldFormat(
    type: FormatType.ipLike4,
    rangeDisplay: '000-000-000-000〜255-255-255-255');

  // NN-NNN-NN-NNN (like 04 事業者コード)
  static const ipLike2x3 = FieldFormat(
    type: FormatType.ipLike2x3,
    rangeDisplay: '00-000-00-000〜99-255-99-255');

  static FieldFormat hexRng(int min, int max) => FieldFormat(
    type: FormatType.hexRange, minVal: min, maxVal: max,
    rangeDisplay:
      '0x${min.toRadixString(16).toUpperCase().padLeft(2,"0")}〜'
      '0x${max.toRadixString(16).toUpperCase().padLeft(2,"0")}');

  static FieldFormat dec(int min, int max, {String? extra}) => FieldFormat(
    type: FormatType.decimal, minVal: min, maxVal: max,
    rangeDisplay: '$min〜$max',
    enumDesc: extra);

  static FieldFormat decLarge(int max) => FieldFormat(
    type: FormatType.decimalLarge, minVal: 0, maxVal: max,
    rangeDisplay: '0〜$max');

  static FieldFormat enum01(String desc) => FieldFormat(
    type: FormatType.toggle, minVal: 0, maxVal: 1,
    rangeDisplay: '0 または 1',
    enumDesc: desc);

  // ── Full display for 設定値 card ──
  String get fullDisplay {
    if (enumDesc != null) return '$rangeDisplay\n$enumDesc';
    return rangeDisplay;
  }

  // ─────────────────────────────────────────
  // PROCESS KEY — returns new buffer or null (ignore key)
  // ─────────────────────────────────────────
  String? processKey(String buf, String key) {
    switch (type) {
      case FormatType.toggle:
        if (key == '⌫' || key == 'CLR') return '';
        if (key == '0' || key == '1') return key;
        return null;

      case FormatType.hexByte:
        return _hexInput(buf, key, 2);
      case FormatType.hexWord:
        return _hexInput(buf, key, 4);
      case FormatType.hexDword:
        return _hexInput(buf, key, 8);
      case FormatType.hexRange:
        return _hexRangeInput(buf, key);

      case FormatType.ipAddress:
        return _groupInput(buf, key, groupSizes: [3,3,3,3], sep: '.', isDecimal: true, groupMax: 255);

      case FormatType.ipLike4:
        return _groupInput(buf, key, groupSizes: [3,3,3,3], sep: '-', isDecimal: true, groupMax: 255);

      case FormatType.ipLike2x3:
        return _groupInput(buf, key, groupSizes: [2,3,2,3], sep: '-', isDecimal: true, groupMax: 999);

      case FormatType.codeHyphen:
        return _groupInput(buf, key, groupSizes: [3,3], sep: '-');

      case FormatType.code2Hyphen:
        return _groupInput(buf, key, groupSizes: [2,3], sep: '-');

      case FormatType.decimal:
        return _decimalInput(buf, key);

      case FormatType.decimalLarge:
        return _decimalLargeInput(buf, key);

      case FormatType.plain:
        if (key == '⌫') return buf.isEmpty ? '' : buf.substring(0, buf.length - 1);
        if (key == 'CLR') return '';
        return buf + key;
    }
  }

  // ── Hex input ──
  String? _hexInput(String buf, String key, int maxChars) {
    if (key == '⌫') return buf.isEmpty ? '' : buf.substring(0, buf.length - 1);
    if (key == 'CLR') return '';
    if (buf.length >= maxChars) return null;
    final k = key.toUpperCase();
    if (RegExp(r'^[0-9A-F]$').hasMatch(k)) return buf + k;
    return null;
  }

  // ── Hex with range e.g. 0x30–0x7F ──
  String? _hexRangeInput(String buf, String key) {
    if (key == '⌫') return buf.isEmpty ? '' : buf.substring(0, buf.length - 1);
    if (key == 'CLR') return '';
    final maxChars = maxVal != null
        ? maxVal!.toRadixString(16).toUpperCase().length.clamp(2, 8)
        : 4;
    if (buf.length >= maxChars) return null;
    final k = key.toUpperCase();
    if (!RegExp(r'^[0-9A-F]$').hasMatch(k)) return null;
    final newBuf = buf + k;
    // Range check
    if (minVal != null || maxVal != null) {
      final v = int.tryParse(newBuf, radix: 16);
      if (v != null && maxVal != null && v > maxVal!) return null;
    }
    return newBuf;
  }

  // ── Generic grouped input (IP, NNN-NNN, etc.) ──
  String? _groupInput(String buf, String key,
      {required List<int> groupSizes, required String sep,
       bool isDecimal = false, int groupMax = 999}) {
    if (key == '⌫') {
      if (buf.isEmpty) return '';
      if (buf.endsWith(sep)) return buf.substring(0, buf.length - 1);
      return buf.substring(0, buf.length - 1);
    }
    if (key == 'CLR') return '';
    if (!RegExp(r'^\d$').hasMatch(key)) return null;

    final parts    = buf.split(sep);
    final groupIdx = parts.length - 1;
    if (groupIdx >= groupSizes.length) return null;

    final curGroup = parts.last;
    final maxLen   = groupSizes[groupIdx];

    if (curGroup.length >= maxLen) {
      // Auto-advance to next group
      if (groupIdx + 1 < groupSizes.length) {
        if (isDecimal) {
          final v = int.tryParse(curGroup) ?? 0;
          if (v > groupMax) return null;
        }
        return '$buf$sep$key';
      }
      return null;
    }

    final newGroup = curGroup + key;
    if (isDecimal) {
      final v = int.tryParse(newGroup) ?? 0;
      if (v > groupMax) return null;
    }
    final newBuf = buf + key;

    // Auto-insert separator after group is full
    final np = newBuf.split(sep);
    if (np.last.length == maxLen && np.length < groupSizes.length) {
      return '$newBuf$sep';
    }
    return newBuf;
  }

  // ── Decimal with min/max ──
  String? _decimalInput(String buf, String key) {
    if (key == '⌫') return buf.isEmpty ? '' : buf.substring(0, buf.length - 1);
    if (key == 'CLR') return '';
    if (!RegExp(r'^\d$').hasMatch(key)) return null;
    final maxDigits = maxVal != null ? maxVal.toString().length : 10;
    if (buf.length >= maxDigits) return null;
    final newBuf = buf + key;
    if (maxVal != null) {
      final v = int.tryParse(newBuf) ?? 0;
      if (v > maxVal!) return null;
    }
    return newBuf;
  }

  // ── Large decimal (no range limit on digits) ──
  String? _decimalLargeInput(String buf, String key) {
    if (key == '⌫') return buf.isEmpty ? '' : buf.substring(0, buf.length - 1);
    if (key == 'CLR') return '';
    if (!RegExp(r'^\d$').hasMatch(key)) return null;
    if (maxVal != null && buf.length >= maxVal.toString().length) return null;
    return buf + key;
  }

  // ── Validate final value ──
  bool isValid(String value) {
    if (value.isEmpty) return false;
    switch (type) {
      case FormatType.toggle:
        return value == '0' || value == '1';
      case FormatType.ipAddress:
        final p = value.split('.');
        if (p.length != 4) return false;
        return p.every((s) { final v = int.tryParse(s); return v != null && v >= 0 && v <= 255; });
      case FormatType.ipLike4:
        final p = value.split('-');
        if (p.length != 4) return false;
        return p.every((s) { final v = int.tryParse(s); return v != null && v >= 0 && v <= 255; });
      case FormatType.ipLike2x3:
        final p = value.split('-');
        if (p.length != 4) return false;
        return p.every((s) { final v = int.tryParse(s); return v != null && v != null; });
      case FormatType.hexRange:
      case FormatType.hexByte:
      case FormatType.hexWord:
      case FormatType.hexDword:
        final v = int.tryParse(value, radix: 16);
        if (v == null) return false;
        if (minVal != null && v < minVal!) return false;
        if (maxVal != null && v > maxVal!) return false;
        return true;
      case FormatType.decimal:
      case FormatType.decimalLarge:
        final v = int.tryParse(value);
        if (v == null) return false;
        if (minVal != null && v < minVal!) return false;
        if (maxVal != null && v > maxVal!) return false;
        return true;
      default:
        return true;
    }
  }
}
