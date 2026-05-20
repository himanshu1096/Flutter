import 'dart:math';
import '../models/memory_block.dart';

abstract class MemoryService {
  Future<MemoryBlock> readMemory(int address, int length);
  Future<bool> writeMemory(int address, List<int> bytes);
  Future<ExecutionResult> executeCommand(String menuCode, Map<String, String> fieldValues);
  Future<bool> ping();
  Stream<MemoryBlock> watchAddress(int address, int length);
}

class ExecutionResult {
  final bool success;
  final String message;
  final String? errorCode;
  final Map<String, String>? updatedValues;
  const ExecutionResult({required this.success, required this.message, this.errorCode, this.updatedValues});
  factory ExecutionResult.ok(String msg, {Map<String, String>? updated}) =>
      ExecutionResult(success: true, message: msg, updatedValues: updated);
  factory ExecutionResult.fail(String msg, {String? code}) =>
      ExecutionResult(success: false, message: msg, errorCode: code);
}

class MockMemoryService implements MemoryService {
  final Map<int, int> _mem = {};
  final _rng = Random();

  MockMemoryService() { _seed(); }

  void _seed() {
    void w(int addr, List<int> b) { for (int i = 0; i < b.length; i++) _mem[addr + i] = b[i]; }
    w(MemoryMap.corner,           [0x01]);
    w(MemoryMap.unitNumber,       [0x01]);
    w(MemoryMap.autoSet,          [0x15]);
    w(MemoryMap.operatorCode,     [0x01, 0x93, 0x84]);
    w(MemoryMap.externalStaCode,  [0x09, 0x38, 0x45]);
    w(MemoryMap.upperConnection,  [0x99, 0x37, 0x30, 0x04]);
    w(MemoryMap.magneticUnit,     [0x00]);
    w(MemoryMap.icUnit,           [0x00]);
    w(MemoryMap.restModeFlag,     [0x00]);
    w(MemoryMap.planTicketFlag,   [0x00]);
    w(MemoryMap.magIssuableFlag,  [0x00]);
    w(MemoryMap.icWindowFlag,     [0x00]);
    w(MemoryMap.icFixedIssueFlag, [0x00]);
    w(MemoryMap.icFixedLimitFlag, [0x00]);
    w(MemoryMap.icSeasonNewFlag,  [0x01]);
    w(MemoryMap.icSeasonContFlag, [0x01]);
    w(MemoryMap.magSeasonNewFlag, [0x01]);
    w(MemoryMap.magSeasonContFlag,[0x01]);
    w(MemoryMap.magSeasonSpecFlag,[0x00]);
    w(MemoryMap.lan1IpAddr,       [192, 168, 10, 100]);
    w(MemoryMap.lan1NetMask,      [255, 255, 255, 0]);
    w(MemoryMap.lan1Gateway,      [192, 168, 10, 1]);
    w(MemoryMap.lan2IpAddr,       [127, 0, 0, 1]);
    w(MemoryMap.lan2NetMask,      [255, 255, 255, 0]);
    w(MemoryMap.lan2Gateway,      [0, 0, 0, 0]);
    w(MemoryMap.upperIp,          [192, 168, 10, 10]);
    w(MemoryMap.distServerIp,     [10, 12, 1, 80]);
    w(MemoryMap.distServerSocket, [0x1D, 0xDB]);
    w(MemoryMap.distServerFtp,    [0x9E, 0x35]);
  }

  @override
  Future<MemoryBlock> readMemory(int address, int length) async {
    await Future.delayed(const Duration(milliseconds: 40));
    final bytes = List.generate(length, (i) => _mem[address + i] ?? 0);
    return MemoryBlock(baseAddress: address, bytes: bytes, readAt: DateTime.now());
  }

  @override
  Future<bool> writeMemory(int address, List<int> bytes) async {
    await Future.delayed(const Duration(milliseconds: 60));
    for (int i = 0; i < bytes.length; i++) { _mem[address + i] = bytes[i]; }
    return true;
  }

  @override
  Future<ExecutionResult> executeCommand(String menuCode, Map<String, String> fieldValues) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (_rng.nextInt(15) == 0) return ExecutionResult.fail('通信エラー: タイムアウト', code: 'E_TIMEOUT');
    return ExecutionResult.ok('$menuCode 実行完了');
  }

  @override
  Future<bool> ping() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return true;
  }

  @override
  Stream<MemoryBlock> watchAddress(int address, int length) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield await readMemory(address, length);
    }
  }
}

/// ════════════════════════════════════════════════
/// TODO [BACKEND]: Replace MockMemoryService with this
/// when connecting to real KBA hardware.
/// ════════════════════════════════════════════════
class RealMemoryService implements MemoryService {
  // TODO: inject SerialPort / TCP / SharedMemory interface here

  @override
  Future<MemoryBlock> readMemory(int address, int length) async {
    // TODO:
    // 1. Send read command to KBA .exe via IPC/serial
    // 2. Parse response bytes
    // 3. Return MemoryBlock
    throw UnimplementedError('Implement KBA hardware read');
  }

  @override
  Future<bool> writeMemory(int address, List<int> bytes) async {
    // TODO:
    // 1. Send write command to KBA .exe
    // 2. Verify write acknowledged
    throw UnimplementedError('Implement KBA hardware write');
  }

  @override
  Future<ExecutionResult> executeCommand(String menuCode, Map<String, String> fieldValues) async {
    throw UnimplementedError('Implement KBA command execution');
  }

  @override
  Future<bool> ping() async {
    throw UnimplementedError('Implement KBA ping');
  }

  @override
  Stream<MemoryBlock> watchAddress(int address, int length) async* {
    throw UnimplementedError('Implement KBA memory watch');
  }
}
