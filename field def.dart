import 'package:equatable/equatable.dart';

enum FieldType { hex, numeric, text, toggle, readonly }
enum MemoryAccessType { readWrite, readOnly, writeOnly }

class FieldRange {
  final String min;
  final String max;
  final String description;
  const FieldRange({required this.min, required this.max, required this.description});
  // Display format matching original: "000.000.000.000〜255.255.255.255"
  String get displayRange => '$min〜$max';
}

class FieldDef extends Equatable {
  final String num;
  final String label;

  /// Hardcoded default — future: fetched from KBA .exe at runtime.
  ///
  /// TODO [BACKEND — KBA REALTIME FETCH]:
  ///   final raw = await KbaInterface.read(
  ///     address: int.parse(memoryAddress!.replaceFirst('0x',''), radix:16),
  ///     size: memorySize,
  ///   );
  ///   return bytesToValue(raw);
  final String defaultValue;

  final FieldType type;
  final String? unit;
  final String? memoryAddress;
  final int memorySize;
  final MemoryAccessType memoryAccess;
  final String? description;
  final FieldRange? range;

  const FieldDef({
    required this.num,
    required this.label,
    required this.defaultValue,
    this.type = FieldType.hex,
    this.unit,
    this.memoryAddress,
    this.memorySize = 2,
    this.memoryAccess = MemoryAccessType.readWrite,
    this.description,
    this.range,
  });

  @override
  List<Object?> get props => [num, memoryAddress];

  List<int> valueToBytes(String value) {
    try {
      if (type == FieldType.hex) {
        final v = int.parse(value.replaceAll(' ', ''), radix: 16);
        return List.generate(memorySize, (i) => (v >> ((memorySize-1-i)*8)) & 0xFF);
      } else if (type == FieldType.numeric) {
        final v = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
        return List.generate(memorySize, (i) => (v >> ((memorySize-1-i)*8)) & 0xFF);
      }
      return value.codeUnits.take(memorySize).toList();
    } catch (_) { return List.filled(memorySize, 0); }
  }

  String bytesToValue(List<int> bytes) {
    if (bytes.isEmpty) return defaultValue;
    try {
      if (type == FieldType.hex) {
        final v = bytes.fold(0, (acc, b) => (acc << 8) | b);
        return v.toRadixString(16).toUpperCase().padLeft(memorySize * 2, '0');
      } else if (type == FieldType.numeric) {
        return bytes.fold(0, (acc, b) => (acc << 8) | b).toString();
      }
      return String.fromCharCodes(bytes.where((b) => b != 0));
    } catch (_) { return defaultValue; }
  }
}
