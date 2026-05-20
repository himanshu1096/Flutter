import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pages_data.dart';
import '../models/field_def.dart';
import '../models/menu_def.dart';
import '../models/page_def.dart';
import '../services/memory_service.dart';

// ── Service ──
final memoryServiceProvider = Provider<MemoryService>((ref) => MockMemoryService());

// ── Pages ──
final allPagesProvider = Provider<List<PageDef>>((ref) => kAllPages);

// ── Current page index ──
final currentPageIndexProvider = StateProvider<int>((ref) => 0);
final currentPageProvider = Provider<PageDef>((ref) {
  final i = ref.watch(currentPageIndexProvider);
  return kAllPages[i.clamp(0, kAllPages.length - 1)];
});

// ── Open menu ──
final openMenuProvider = StateProvider<MenuDef?>((ref) => null);

// ── Field values ──
final fieldValuesProvider =
    StateNotifierProvider<FieldValuesNotifier, Map<String, Map<String, String>>>(
  (ref) => FieldValuesNotifier(),
);

class FieldValuesNotifier extends StateNotifier<Map<String, Map<String, String>>> {
  FieldValuesNotifier() : super({}) { _initDefaults(); }

  void _initDefaults() {
    // ════════════════════════════════════════════
    // TODO [BACKEND — KBA REALTIME FETCH]:
    // Replace field.defaultValue below with a call to:
    //   final liveVal = await kbaService.readField(field.memoryAddress, field.memorySize);
    //   init[menu.code]![field.num] = field.bytesToValue(liveVal);
    //
    // This should be an async init — use AsyncNotifier instead
    // of StateNotifier once backend is connected.
    // ════════════════════════════════════════════
    final Map<String, Map<String, String>> init = {};
    for (final page in kAllPages) {
      for (final menu in page.menus) {
        init[menu.code] = {};
        for (final field in menu.fields) {
          init[menu.code]![field.num] = field.defaultValue; // ← replace with live fetch
        }
      }
    }
    state = init;
  }

  String getValue(String menuCode, String fieldNum) =>
      state[menuCode]?[fieldNum] ?? '';

  void setValue(String menuCode, String fieldNum, String value) {
    final next = Map<String, Map<String, String>>.from(state);
    next[menuCode] = Map<String, String>.from(next[menuCode] ?? {});
    next[menuCode]![fieldNum] = value;
    state = next;
  }
}

// ── Numpad state ──
class NumpadState {
  final bool isOpen;
  final String menuCode;
  final String fieldNum;
  final String fieldLabel;
  final String buffer;
  final bool isHex;
  final String? rangeMin;
  final String? rangeMax;
  final String? rangeDesc;

  const NumpadState({
    this.isOpen = false, this.menuCode = '', this.fieldNum = '',
    this.fieldLabel = '', this.buffer = '', this.isHex = true,
    this.rangeMin, this.rangeMax, this.rangeDesc,
  });

  NumpadState copyWith({
    bool? isOpen, String? menuCode, String? fieldNum, String? fieldLabel,
    String? buffer, bool? isHex, String? rangeMin, String? rangeMax, String? rangeDesc,
  }) => NumpadState(
    isOpen: isOpen ?? this.isOpen,
    menuCode: menuCode ?? this.menuCode,
    fieldNum: fieldNum ?? this.fieldNum,
    fieldLabel: fieldLabel ?? this.fieldLabel,
    buffer: buffer ?? this.buffer,
    isHex: isHex ?? this.isHex,
    rangeMin: rangeMin ?? this.rangeMin,
    rangeMax: rangeMax ?? this.rangeMax,
    rangeDesc: rangeDesc ?? this.rangeDesc,
  );
}

final numpadProvider =
    StateNotifierProvider<NumpadNotifier, NumpadState>((ref) => NumpadNotifier(ref));

class NumpadNotifier extends StateNotifier<NumpadState> {
  final Ref _ref;
  NumpadNotifier(this._ref) : super(const NumpadState());

  void open({required String menuCode, required String fieldNum,
    required String fieldLabel, required String currentValue,
    required bool isHex, FieldRange? range}) {
    state = state.copyWith(
      isOpen: true, menuCode: menuCode, fieldNum: fieldNum,
      fieldLabel: fieldLabel, buffer: currentValue, isHex: isHex,
      rangeMin: range?.min, rangeMax: range?.max, rangeDesc: range?.description,
    );
  }

  void pressKey(String key) {
    if (key == '⌫') {
      final b = state.buffer;
      state = state.copyWith(buffer: b.isEmpty ? '' : b.substring(0, b.length - 1));
    } else if (key == 'CLR') {
      state = state.copyWith(buffer: '');
    } else {
      state = state.copyWith(buffer: state.buffer + key);
    }
  }

  void confirm() {
    if (state.buffer.isNotEmpty) {
      // ════════════════════════════════════════════
      // TODO [BACKEND — KBA WRITE-BACK]:
      // Before updating the UI state, write the new value
      // back to the KBA .exe memory:
      //
      //   final field = menuDef.fieldByNum(state.fieldNum);
      //   if (field?.memoryAddress != null) {
      //     final bytes = field!.valueToBytes(state.buffer);
      //     final ok = await kbaService.writeMemory(
      //       int.parse(field.memoryAddress!.replaceFirst('0x',''), radix:16),
      //       bytes,
      //     );
      //     if (!ok) { showError('書き込み失敗'); return; }
      //   }
      // ════════════════════════════════════════════
      _ref.read(fieldValuesProvider.notifier)
          .setValue(state.menuCode, state.fieldNum, state.buffer);
    }
    close();
  }

  void close() => state = state.copyWith(isOpen: false, buffer: '');
}

// ── Execution state ──
enum ExecStatus { idle, loading, success, error }

class ExecState {
  final ExecStatus status;
  final String message;
  const ExecState({this.status = ExecStatus.idle, this.message = ''});
}

final execStateProvider =
    StateNotifierProvider<ExecNotifier, ExecState>((ref) => ExecNotifier(ref));

class ExecNotifier extends StateNotifier<ExecState> {
  final Ref _ref;
  ExecNotifier(this._ref) : super(const ExecState());

  Future<void> execute(String menuCode, Map<String, String> fieldValues) async {
    state = const ExecState(status: ExecStatus.loading, message: '実行中...');
    try {
      final svc = _ref.read(memoryServiceProvider);
      final result = await svc.executeCommand(menuCode, fieldValues);
      state = ExecState(
        status: result.success ? ExecStatus.success : ExecStatus.error,
        message: result.message,
      );
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) state = const ExecState();
    } catch (e) {
      state = ExecState(status: ExecStatus.error, message: '実行エラー: $e');
    }
  }
}

// ── Connection status ──
final connectionStatusProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(memoryServiceProvider).ping();
});
