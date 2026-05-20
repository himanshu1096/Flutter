import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────
/// STATION NAME
///
/// Hardcoded for now.
/// TODO [BACKEND]: Replace _kStationName with a value
/// fetched from server/database at app startup:
///
///   Future<String> fetchStationName() async {
///     // Option A — HTTP/REST:
///     //   final res = await http.get(Uri.parse('$baseUrl/station/info'));
///     //   return jsonDecode(res.body)['stationName'] as String;
///     //
///     // Option B — Local DB (SQLite / shared_preferences):
///     //   final prefs = await SharedPreferences.getInstance();
///     //   return prefs.getString('stationName') ?? '小川駅前';
///     //
///     // Option C — Named pipe / IPC from KBA .exe:
///     //   return await KbaInterface.getStationName();
///   }
///
/// Expose the result via a Riverpod provider and watch it here.
/// ─────────────────────────────────────────
const String _kStationName = '小川駅前'; // ← replace with provider when backend ready

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({super.key});
  @override ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  String _time = '';

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final n = DateTime.now();
    setState(() => _time =
      '${n.year}.${_p(n.month)}.${_p(n.day)} ${_p(n.hour)}:${_p(n.minute)}:${_p(n.second)}');
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  String _p(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connectionStatusProvider);

    return Container(
      height: 38,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [

        // ── Logo dot + system title ──
        Container(
          width: 6, height: 6,
          decoration: const BoxDecoration(
            color: AppColors.accentLight, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text('保守メニュー', style: AppText.headerTitle),

        const SizedBox(width: 16),

        // ── Station name (hardcoded, future: from server) ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF253550),
            border: Border.all(color: const Color(0xFF3A5070)),
            borderRadius: BorderRadius.circular(3)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.location_on, size: 9, color: Color(0xFF5A8AAA)),
            const SizedBox(width: 4),
            Text(_kStationName,
              style: const TextStyle(
                fontFamily: AppText.mono, fontSize: 10,
                color: Color(0xFF8ABCD8), fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
          ]),
        ),

        const Spacer(),

        // ── Connection status ──
        conn.when(
          data: (ok) => _Pill(
            ok ? 'ONLINE' : 'OFFLINE',
            ok ? AppColors.success : AppColors.danger),
          loading: () => const _Pill('...', AppColors.warn),
          error: (_, __) => const _Pill('ERR', AppColors.danger),
        ),

        const SizedBox(width: 10),

        // ── Clock ──
        Text(_time,
          style: const TextStyle(
            fontFamily: AppText.mono, fontSize: 9,
            color: Color(0xFF4A6A8A))),

        const SizedBox(width: 12),

        // ── Logoff button — right side ──
        GestureDetector(
          onTap: () {
            // TODO: implement logout / session end
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.18),
              border: Border.all(color: AppColors.danger.withOpacity(0.45)),
              borderRadius: BorderRadius.circular(4)),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.logout, size: 11, color: Color(0xFFE07070)),
              SizedBox(width: 4),
              Text('ログオフ',
                style: TextStyle(
                  fontFamily: AppText.mono, fontSize: 9,
                  color: Color(0xFFE07070), fontWeight: FontWeight.w600)),
            ]),
          ),
        ),

      ]),
    );
  }
}

// ─────────────────────────────────────────
// STATUS PILL
// ─────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(100)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
          style: TextStyle(
            fontFamily: AppText.mono, fontSize: 8, color: color)),
      ]),
    );
  }
}
