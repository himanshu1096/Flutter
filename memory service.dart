import 'dart:math';

abstract class MemoryService {
  Future<List<int>> readMemory(int address, int length);
  Future<bool> writeMemory(int address, List<int> bytes);
  Future<ExecResult> executeCommand(String menuCode, Map<String, String> values);
  Future<bool> ping();
}

class ExecResult {
  final bool success;
  final String message;
  const ExecResult({required this.success, required this.message});
}

class MockMemoryService implements MemoryService {
  final Map<int, int> _mem = {};
  final _rng = Random();
  MockMemoryService() { _seed(); }

  void _seed() {
    void w(int a, List<int> b) { for (int i=0; i<b.length; i++) _mem[a+i]=b[i]; }
    w(0x2000, [0x01]); w(0x2001, [0x1F]); w(0x2002, [0x15]);
    w(0x3000, [192,168,10,100]); w(0x3004, [255,255,255,0]);
    w(0x3008, [192,168,10,1]);   w(0x300C, [127,0,0,1]);
    w(0x3010, [255,255,255,0]);  w(0x3014, [0,0,0,0]);
    w(0x3018, [192,168,10,10]);  w(0x301C, [10,12,1,80]);
    w(0x3020, [0x1D,0xDB]);      w(0x3022, [0x9E,0x35]);
  }

  @override
  Future<List<int>> readMemory(int address, int length) async {
    await Future.delayed(const Duration(milliseconds: 40));
    return List.generate(length, (i) => _mem[address+i] ?? 0);
  }

  @override
  Future<bool> writeMemory(int address, List<int> bytes) async {
    await Future.delayed(const Duration(milliseconds: 60));
    for (int i=0; i<bytes.length; i++) _mem[address+i] = bytes[i];
    return true;
  }

  @override
  Future<ExecResult> executeCommand(String menuCode, Map<String, String> values) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_rng.nextInt(15) == 0) return const ExecResult(success:false, message:'通信エラー: タイムアウト');
    return ExecResult(success:true, message:'$menuCode 実行完了');
  }

  @override
  Future<bool> ping() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return true;
  }
}

/// TODO [BACKEND]: Replace MockMemoryService with RealMemoryService
/// connected to KBA hardware via serial/TCP/IPC
class RealMemoryService implements MemoryService {
  @override Future<List<int>> readMemory(int address, int length) => throw UnimplementedError('KBA read');
  @override Future<bool> writeMemory(int address, List<int> bytes) => throw UnimplementedError('KBA write');
  @override Future<ExecResult> executeCommand(String menuCode, Map<String, String> values) => throw UnimplementedError('KBA exec');
  @override Future<bool> ping() => throw UnimplementedError('KBA ping');
}
