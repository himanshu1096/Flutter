import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pages_data.dart';
import '../models/field_def.dart';
import '../models/menu_def.dart';
import '../models/page_def.dart';
import '../services/memory_service.dart';

// ── Service ──
final memServiceProvider = Provider<MemoryService>((ref) => MockMemoryService());

// ── Pages ──
final allPagesProvider = Provider<List<PageDef>>((ref) => kAllPages);

// ── Current page ──
final pageIndexProvider = StateProvider<int>((ref) => 0);
final currentPageProvider = Provider<PageDef>((ref) {
  final i = ref.watch(pageIndexProvider);
  return kAllPages[i.clamp(0, kAllPages.length - 1)];
});

// ── Open menu (null = landing grid) ──
final openMenuProvider = StateProvider<MenuDef?>((ref) => null);

// ── Field values: menuCode → fieldNum → value ──
final fieldValuesProvider =
    StateNotifierProvider<FieldValuesNotifier, Map<String, Map<String, String>>>(
  (ref) => FieldValuesNotifier());

class FieldValuesNotifier extends StateNotifier<Map<String, Map<String, String>>> {
  FieldValuesNotifier() : super({}) { _init(); }

  void _init() {
    /// TODO [BACKEND]: Replace defaultValue with live KBA .exe read:
    ///   final raw = await KbaInterface.read(address, size);
    ///   value = field.bytesToValue(raw);
    final m = <String, Map<String, String>>{};
    for (final p in kAllPages) {
      for (final menu in p.menus) {
        m[menu.code] = {for (final f in menu.fields) f.num: f.defaultValue};
      }
    }
    state = m;
  }

  String getValue(String menuCode, String num) => state[menuCode]?[num] ?? '';

  void setValue(String menuCode, String num, String val) {
    /// TODO [BACKEND]: Write back to KBA .exe before updating UI:
    ///   final bytes = field.valueToBytes(val);
    ///   await KbaInterface.write(address, bytes);
    final next = Map<String, Map<String, String>>.from(state);
    next[menuCode] = Map<String, String>.from(next[menuCode] ?? {});
    next[menuCode]![num] = val;
    state = next;
  }
}

// ── Selected field index within the VISIBLE 10 fields ──
final selectedFieldIndexProvider = StateProvider<int>((ref) => 0);

// ── Field group offset
// 0 = fields index 0–9, 1 = fields index 10–19, 2 = fields index 20–29 etc.
// Controlled by 前項 / 次項 on the numpad
final fieldGroupOffsetProvider = StateProvider<int>((ref) => 0);

/// How many groups exist for a given menu
int fieldGroupCount(MenuDef menu) => (menu.fields.length / 10).ceil();

/// Can go to previous group?
bool canGoPrev(int offset) => offset > 0;

/// Can go to next group?
bool canGoNext(MenuDef menu, int offset) => offset + 1 < fieldGroupCount(menu);

// ── Numpad buffer ──
class NumpadState {
  final String buffer;
  final bool active;
  const NumpadState({this.buffer = '', this.active = false});
  NumpadState copyWith({String? buffer, bool? active}) =>
      NumpadState(buffer: buffer ?? this.buffer, active: active ?? this.active);
}

final numpadStateProvider =
    StateNotifierProvider<NumpadNotifier, NumpadState>((ref) => NumpadNotifier(ref));

class NumpadNotifier extends StateNotifier<NumpadState> {
  final Ref _ref;
  NumpadNotifier(this._ref) : super(const NumpadState());

  void activate(String currentValue) =>
      state = NumpadState(buffer: currentValue, active: true);

  void pressKey(String key) {
    if (!state.active) return;
    if (key == '⌫') {
      final b = state.buffer;
      state = state.copyWith(buffer: b.isEmpty ? '' : b.substring(0, b.length - 1));
    } else if (key == 'CLR') {
      state = state.copyWith(buffer: '');
    } else {
      state = state.copyWith(buffer: state.buffer + key);
    }
  }

  void confirm(String menuCode, String fieldNum) {
    if (state.active && state.buffer.isNotEmpty) {
      _ref.read(fieldValuesProvider.notifier).setValue(menuCode, fieldNum, state.buffer);
    }
    state = const NumpadState();
  }

  void cancel() => state = const NumpadState();
}

// ── Execution state ──
enum ExecStatus { idle, loading, success, error }

class ExecState {
  final ExecStatus status;
  final String message;
  const ExecState({this.status = ExecStatus.idle, this.message = ''});
}

final execProvider =
    StateNotifierProvider<ExecNotifier, ExecState>((ref) => ExecNotifier(ref));

class ExecNotifier extends StateNotifier<ExecState> {
  final Ref _ref;
  ExecNotifier(this._ref) : super(const ExecState());

  Future<void> run(String menuCode, Map<String, String> values) async {
    state = const ExecState(status: ExecStatus.loading, message: '実行中...');
    try {
      final r = await _ref.read(memServiceProvider).executeCommand(menuCode, values);
      state = ExecState(
        status: r.success ? ExecStatus.success : ExecStatus.error,
        message: r.message);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) state = const ExecState();
    } catch (e) {
      state = ExecState(status: ExecStatus.error, message: '実行エラー: $e');
    }
  }
}

// ── Connection ──
final connProvider = FutureProvider<bool>(
  (ref) => ref.read(memServiceProvider).ping());
