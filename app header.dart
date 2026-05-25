import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// Station name — hardcoded for now.
/// TODO [BACKEND]: fetch from server/DB at startup:
///   Option A — HTTP: GET /api/station → { "name": "小川町駅" }
///   Option B — SharedPreferences: prefs.getString('stationName')
///   Option C — KBA IPC: KbaInterface.getStationName()
const String kStationName = '小川町駅';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({super.key});
  @override ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  String _time = '';
  @override void initState() { super.initState(); _tick(); }
  void _tick() {
    if (!mounted) return;
    final n = DateTime.now();
    final dow = ['月','火','水','木','金','土','日'][n.weekday - 1];
    setState(() => _time =
      '${n.year}.${_p(n.month)}.${_p(n.day)}(${dow})${_p(n.hour)}:${_p(n.minute)}');
    Future.delayed(const Duration(seconds: 1), _tick);
  }
  String _p(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connProvider);
    final online = conn.asData?.value ?? false;

    return Container(
      height: 36,
      color: AppColors.headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        // System title
        const Text('保守メニュー', style: AppText.headerTitle),
        const SizedBox(width: 12),
        // Station name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF253555),
            border: Border.all(color: const Color(0xFF3A5570)),
            borderRadius: BorderRadius.circular(3)),
          child: Text(kStationName,
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 10,
              color: Color(0xFF8AC0DA), fontWeight: FontWeight.w600)),
        ),
        const Spacer(),
        // Status badge — green "ID デ集" or red X like original
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: online ? AppColors.statusGreen : AppColors.statusRed,
          child: Text(online ? 'ID デ集' : 'ID エラー',
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 8,
              color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        // Date/time — day of week smaller inside ()
        _DateTimeWidget(time: _time),
        const SizedBox(width: 12),
        // Logoff — right side
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF6A3A3A)),
              borderRadius: BorderRadius.circular(3),
              color: const Color(0xFF3A1A1A)),
            child: const Text('ログオフ',
              style: TextStyle(fontFamily: AppText.mono, fontSize: 9,
                color: Color(0xFFCC8888), fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────
// DATE TIME WIDGET
// Renders: 2027.04.08(水)12:17
// Day of week is smaller font inside ()
// ─────────────────────────────────────────
class _DateTimeWidget extends StatelessWidget {
  final String time; // format: "2027.04.08(水)12:17"
  const _DateTimeWidget({required this.time});

  @override
  Widget build(BuildContext context) {
    // Split on ( and ) to isolate the day character
    final openParen  = time.indexOf('(');
    final closeParen = time.indexOf(')');
    if (openParen == -1 || closeParen == -1) {
      return Text(time,
        style: const TextStyle(fontFamily: AppText.mono,
          fontSize: 9, color: Color(0xFF8AB0CC)));
    }

    final before = time.substring(0, openParen);       // "2027.04.08"
    final day    = time.substring(openParen + 1, closeParen); // "水"
    final after  = time.substring(closeParen + 1);      // "12:17"

    return RichText(
      text: TextSpan(children: [
        TextSpan(text: before,
          style: const TextStyle(fontFamily: AppText.mono,
            fontSize: 9, color: Color(0xFF8AB0CC))),
        TextSpan(text: '(',
          style: const TextStyle(fontFamily: AppText.mono,
            fontSize: 9, color: Color(0xFF6A90AA))),
        TextSpan(text: day,
          style: const TextStyle(fontFamily: AppText.mono,
            fontSize: 7, color: Color(0xFF6AAAC8))), // smaller day
        TextSpan(text: ')',
          style: const TextStyle(fontFamily: AppText.mono,
            fontSize: 9, color: Color(0xFF6A90AA))),
        TextSpan(text: after,
          style: const TextStyle(fontFamily: AppText.mono,
            fontSize: 9, color: Color(0xFF8AB0CC))),
      ]),
    );
  }
}
