import 'package:equatable/equatable.dart';

enum FieldType { hex, numeric, text, toggle, readonly }
enum MemoryAccessType { readWrite, readOnly, writeOnly }

/// Value range definition — shown in 設定値 card while numpad is open
class FieldRange {
  final String min;
  final String max;
  final String description; // shown to user
  final List<String>? allowedValues; // for enum fields
  const FieldRange({required this.min, required this.max, required this.description, this.allowedValues});
}

/// ─────────────────────────────────────────
/// FIELD DEFINITION
/// One row in a menu screen, maps to a memory address.
/// ─────────────────────────────────────────
class FieldDef extends Equatable {
  final String num;
  final String label;

  /// Default/fallback value shown before real data is loaded.
  ///
  /// ════════════════════════════════════════════════════
  /// TODO [BACKEND — KBA .EXE REALTIME FETCH]:
  /// This defaultValue is a static placeholder only.
  /// In production, replace with a live read from the KBA system .exe:
  ///
  ///   Future<String> fetchLiveValue() async {
  ///     // 1. Connect to KBA .exe via named pipe / shared memory / COM port
  ///     //    Example: await KbaInterface.connect(port: 'COM3', baudRate: 9600);
  ///     //
  ///     // 2. Send read command with this field's memoryAddress
  ///     //    final raw = await KbaInterface.read(
  ///     //      address: int.parse(memoryAddress!.replaceFirst('0x',''), radix:16),
  ///     //      size: memorySize,
  ///     //    );
  ///     //
  ///     // 3. Parse the raw bytes into display string
  ///     //    return bytesToValue(raw);
  ///   }
  ///
  /// Call fetchLiveValue() in FieldValuesNotifier._initDefaults()
  /// instead of using field.defaultValue.
  /// ════════════════════════════════════════════════════
  final String defaultValue;

  final FieldType type;
  final String? unit;

  /// ════════════════════════════════════════════════════
  /// MEMORY MAPPING — used by backend for read/write
  /// ════════════════════════════════════════════════════
  final String? memoryAddress; // hex string e.g. "0x2000"
  final int memorySize;        // byte count
  final MemoryAccessType memoryAccess;
  final String? description;  // developer note

  /// Value range shown to user in 設定値 card
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
  List<Object?> get props => [num, label, memoryAddress];

  /// ════════════════════════════════════════════════════
  /// TODO [BACKEND — KBA .EXE WRITE-BACK]:
  /// When user confirms a value in the numpad, call this
  /// to write the new value back to the KBA .exe:
  ///
  ///   Future<bool> writeValueToKba(String newValue) async {
  ///     final bytes = valueToBytes(newValue);
  ///     // 1. Open connection to KBA .exe
  ///     //    await KbaInterface.connect(port: 'COM3');
  ///     //
  ///     // 2. Write bytes to the memory address
  ///     //    final ok = await KbaInterface.write(
  ///     //      address: int.parse(memoryAddress!.replaceFirst('0x',''), radix:16),
  ///     //      data: bytes,
  ///     //    );
  ///     //
  ///     // 3. Verify write was successful (optional read-back)
  ///     //    final verify = await KbaInterface.read(address:..., size: memorySize);
  ///     //    return verify == bytes;
  ///     //
  ///     // 4. Update the UI value only if write succeeds
  ///     //    return ok;
  ///   }
  ///
  /// Call writeValueToKba(value) inside NumpadNotifier.confirm()
  /// BEFORE updating the provider state.
  /// ════════════════════════════════════════════════════

  /// Convert display string value → raw bytes for memory write
  List<int> valueToBytes(String value) {
    try {
      if (type == FieldType.hex) {
        final v = int.parse(value.replaceAll(' ', ''), radix: 16);
        return _intToBytes(v, memorySize);
      } else if (type == FieldType.numeric) {
        final v = int.tryParse(value.replaceAll('.', '').replaceAll(':', '')) ?? 0;
        return _intToBytes(v, memorySize);
      } else {
        return value.codeUnits.take(memorySize).toList();
      }
    } catch (_) {
      return List.filled(memorySize, 0);
    }
  }

  /// Convert raw bytes from memory → display string
  String bytesToValue(List<int> bytes) {
    if (bytes.isEmpty) return defaultValue;
    try {
      if (type == FieldType.hex) {
        return _bytesToInt(bytes)
            .toRadixString(16)
            .toUpperCase()
            .padLeft(memorySize * 2, '0');
      } else if (type == FieldType.numeric) {
        return _bytesToInt(bytes).toString();
      } else {
        return String.fromCharCodes(bytes.where((b) => b != 0));
      }
    } catch (_) {
      return defaultValue;
    }
  }

  List<int> _intToBytes(int value, int size) {
    return List.generate(size, (i) => (value >> ((size - 1 - i) * 8)) & 0xFF);
  }

  int _bytesToInt(List<int> bytes) =>
      bytes.fold(0, (acc, b) => (acc << 8) | b);
}
