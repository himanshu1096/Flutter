import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_multidemo/app_color.dart';
import 'package:qr_multidemo/provider/provider.dart';
import 'package:qr_multidemo/qr_process/qr_process_menu.dart';
import 'package:qr_multidemo/secondary_tab_content_core.dart';
import 'package:intl/intl.dart';

import '../app_icon.dart';
import '../utility/confirm_dialog.dart';
import '../utility/constant.dart';
import 'secondary_tab_process_information.dart';
import 'secondary_tab_process.dart';
import 'secondary_tab_process_fare_judge.dart';
import 'secondary_tab_process_fare_judge_route.dart';

enum QrReadPageBtnKind {
  nyuuzyou('入場処理'),
  syutuzyou('出場処理'),
  hatuekiCancel('発駅キャンセル処理'),
  seisanSyoriRoute('精算処理経路'),
  seisanSyori('精算処理'),
  haikenSyori('廃券処理'),
  zyouhoHyouzi('情報表示');

  final String name;

  const QrReadPageBtnKind(this.name);
}

class SecondaryTabContentUnselected extends StatelessWidget {
  const SecondaryTabContentUnselected({required this.onComplete, super.key});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context) {
    return SecondaryTabContentBase(
      contentTop: _SecondaryTabContentTop(onComplete: onComplete),
    );
  }
}

class _SecondaryTabContentTop extends ConsumerWidget {
  const _SecondaryTabContentTop({required this.onComplete});

  final void Function(QrReadPageBtnKind pageKind) onComplete;
  static const buttonDist = SizedBox(width: 25);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBtn = ref.watch(qrReadPageSelectedBtnProvider);
    final btnNotifier = ref.watch(qrReadPageSelectedBtnProvider.notifier);
    final judgeRouteBtnNotifier = ref.watch(judgeRouteListProvider.notifier);
    final judgeRouteBtnIdNotifier = ref.watch(judgeRouteIdProvider.notifier);

    // 0x1281 ボタン制御フラグ
    final displayData = ref.watch(displayDataNotifierProvider);
    final enterEnabled = displayData?.enterBtnEnabled ?? false;
    final exitEnabled = displayData?.exitBtnEnabled ?? false;
    final adjustEnabled = displayData?.adjustBtnEnabled ?? false;
    final haisaEnabled = displayData?.haisaCancelBtnEnabled ?? false;
    final enterCancelEnabled = displayData?.enterCancelBtnEnabled ?? false;

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TransitionButton(
                    onPressed: () async {
                      if (enterEnabled &&
                          QrReadPageBtnKind.zyouhoHyouzi == selectedBtn) {
                        await TcpService().sendBusinessSelect(10);
                        btnNotifier.changePage(QrReadPageBtnKind.nyuuzyou);
                      }
                    },
                    text: '　入場　',
                    isPushed: QrReadPageBtnKind.nyuuzyou == selectedBtn,
                    btnColors: enterEnabled &&
                            QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                        ? orengeGradient
                        : grayGradient,
                  ),
                  buttonDist,
                  TransitionButton(
                    onPressed: () async {
                      if (exitEnabled &&
                          QrReadPageBtnKind.zyouhoHyouzi == selectedBtn) {
                        await TcpService().sendBusinessSelect(11);
                        btnNotifier.changePage(QrReadPageBtnKind.syutuzyou);
                      }
                    },
                    text: '　出場　',
                    isPushed: QrReadPageBtnKind.syutuzyou == selectedBtn,
                    btnColors: exitEnabled &&
                            QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                        ? orengeGradient
                        : grayGradient,
                  ),
                  buttonDist,
                  TransitionButton(
                    onPressed: () async {
                      if (!adjustEnabled ||
                          QrReadPageBtnKind.zyouhoHyouzi != selectedBtn) return;
                      await TcpService().sendBusinessSelect(12);
                      // ROUTECAND から経路候補を設定
                      final displayData = ref.read(displayDataNotifierProvider);
                      final cands = displayData?.routeCandidates ?? [];
                      if (cands.length > 1) {
                        // 経路選択画面へ
                        btnNotifier.changePage(QrReadPageBtnKind.seisanSyoriRoute);
                      } else {
                        // 経路選択不要 → 直接精算処理へ
                        judgeRouteBtnIdNotifier.set(1);
                        btnNotifier.changePage(QrReadPageBtnKind.seisanSyori);
                      }
                    },
                    text: '精算処理',
                    isPushed:
                        (QrReadPageBtnKind.seisanSyori == selectedBtn ||
                            QrReadPageBtnKind.seisanSyoriRoute == selectedBtn),
                    btnColors: adjustEnabled &&
                            QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                        ? orengeGradient
                        : grayGradient,
                  ),
                  buttonDist,
                  TransitionButton(
                    onPressed: () async {
                      if (haisaEnabled &&
                          QrReadPageBtnKind.zyouhoHyouzi == selectedBtn) {
                        await TcpService().sendBusinessSelect(13);
                        btnNotifier.changePage(QrReadPageBtnKind.haikenSyori);
                      }
                    },
                    text: '廃券処理',
                    isPushed: QrReadPageBtnKind.haikenSyori == selectedBtn,
                    btnColors: haisaEnabled &&
                            QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                        ? orengeGradient
                        : grayGradient,
                  ),
                  buttonDist,
                  TransitionButton(
                    onPressed: () async {
                      if (enterCancelEnabled &&
                          QrReadPageBtnKind.zyouhoHyouzi == selectedBtn) {
                        await TcpService().sendBusinessSelect(14);
                        btnNotifier.changePage(QrReadPageBtnKind.hatuekiCancel);
                      }
                    },
                    text: '発駅キャンセル',
                    isPushed: QrReadPageBtnKind.hatuekiCancel == selectedBtn,
                    btnColors: enterCancelEnabled &&
                            QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                        ? orengeGradient
                        : grayGradient,
                    // width: 190,
                    fontSize: 22.0,
                  ),
                  buttonDist,
                  TransitionButton(
                    onPressed: () {
                      QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                          ? btnNotifier.changePage(
                            QrReadPageBtnKind.zyouhoHyouzi,
                          )
                          : Null;
                    },
                    text: '情報表示',
                    isPushed: QrReadPageBtnKind.zyouhoHyouzi == selectedBtn,
                    btnColors:
                        QrReadPageBtnKind.zyouhoHyouzi == selectedBtn
                            ? orengeGradient
                            : grayGradient,
                  ),
                ],
              ),
              // QrTicketNoWidget(),
            ],
          ),
          if (selectedBtn != QrReadPageBtnKind.seisanSyoriRoute)
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: EdgeInsets.only(top: 15),
                child: CardInfoContents(),
              ),
            ),

          Padding(
            padding: EdgeInsets.only(bottom: 20.0, top: 0.0),
            child: SecondaryTabContent(onComplete: onComplete),
          ),
        ],
      ),
    );
  }
}

class SecondaryTabContent extends ConsumerWidget {
  const SecondaryTabContent({required this.onComplete, super.key});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageKind = ref.watch(qrReadPageSelectedBtnProvider);
    return switch (pageKind) {
      QrReadPageBtnKind.zyouhoHyouzi => ZyouhoHyouziFooter(),
      QrReadPageBtnKind.seisanSyoriRoute => SeisanSyoriRoute(
        onComplete: onComplete,
      ),
      QrReadPageBtnKind.seisanSyori => SeisanSyori(onComplete: onComplete),
      _ => SeisanSonotaSyori(onComplete: onComplete),
    };
  }
}

/// 業務処理実行 — TCP送信してから完了画面へ
Future<void> _sendProcessRequest(
  BuildContext context,
  QrReadPageBtnKind pageKind,
  void Function(QrReadPageBtnKind) onComplete,
) async {
  final container = ProviderScope.containerOf(context);
  final displayData = container.read(displayDataNotifierProvider);
  final qrNumber = displayData?.qrNumber ?? '';

  if (qrNumber.isEmpty) {
    AppLogger().error('ExecuteButton', 'QRNUMBERが空です');
    return;
  }

  final commandId = switch (pageKind) {
    QrReadPageBtnKind.nyuuzyou => CommandId.enterRequest,
    QrReadPageBtnKind.syutuzyou => CommandId.exitRequest,
    QrReadPageBtnKind.seisanSyori => CommandId.adjustRequest,
    QrReadPageBtnKind.haikenSyori => CommandId.cancelTicketRequest,
    QrReadPageBtnKind.hatuekiCancel => CommandId.enterCancelRequest,
    _ => 0,
  };

  if (commandId == 0) {
    AppLogger().warn('ExecuteButton', '不明なページ: $pageKind');
    return;
  }

  if (context.mounted) {
    showCustomAlertDialog(context: context, text: '処理中');
  }

  try {
    final response = await TcpService().sendProcessRequest(
      commandId: commandId,
      qrNumber: qrNumber,
    );
    if (context.mounted) Navigator.of(context).pop();

    if (response.result) {
      AppLogger().info('ExecuteButton', '処理成功');
      onComplete.call(pageKind);
    } else {
      AppLogger().warn('ExecuteButton', '処理失敗: ${response.errCode}');
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomConfirmDialog(
            text: '処理が失敗しました
エラーコード: ${response.errCode}',
            trueBtnText: '確認',
            hasFalseBtn: false,
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    AppLogger().error('ExecuteButton', '処理エラー', e);
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomConfirmDialog(
          text: '通信エラーが発生しました',
          trueBtnText: '確認',
          hasFalseBtn: false,
        ),
      );
    }
  }
}

// 実行ボタン
class ExecuteButton extends ConsumerWidget {
  const ExecuteButton({required this.onComplete});

  final void Function(QrReadPageBtnKind pageKind) onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(qrReadPageSelectedBtnProvider);
    final dialogText =
        currentPage == QrReadPageBtnKind.hatuekiCancel
            ? '発駅キャンセルを実行します。\n処理を実行すると係員窓口のみ\n利用が可能となります。よろしいですか？'
            : null;
    final dialogTextColor =
        currentPage == QrReadPageBtnKind.hatuekiCancel
            ? Theme.of(context).colorScheme.error
            : null;
    return ActiveLargeButton(
      text: '実行    ',
      onPressed: () async {
        // 実行確認
        final isExecute = await showDialog<bool?>(
          // barrierColor: Colors.transparent,
          barrierColor: Colors.black26,
          context: context,
          builder:
              (context) => ConfirmDialog(
                porpose: currentPage.name,
                customText: dialogText,
                customFontColor: dialogTextColor,
              ),
        );

        // 実行が「はい」かつ、contextがあれば
        if ((isExecute ?? false) && context.mounted) {
          // 0x2101~0x2501 送信
          await _sendProcessRequest(context, currentPage, onComplete);
        }
      },
    );
  }
}
