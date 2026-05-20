import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(currentPageProvider);
    return Container(
      color: AppColors.surface3,
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warnBg,
              border: Border.all(color: AppColors.warn.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(4)),
            child: const Text('入力・選択を行い実行ボタンを押してください', style: AppText.instruction)),
          const SizedBox(height: 24),
          Text(page.label,
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 28,
              color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 4)),
          const SizedBox(height: 8),
          Text('${page.menus.length} メニュー  —  左リストから選択',
            style: const TextStyle(fontFamily: AppText.mono, fontSize: 10, color: AppColors.textDim)),
        ]),
      ),
    );
  }
}
