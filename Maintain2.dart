import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MaintenanceApp());
}

// ═══════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════
const kBg       = Color(0xFF0B0F14);
const kSurface  = Color(0xFF141920);
const kSurface2 = Color(0xFF1A2130);
const kSurface3 = Color(0xFF1F2A3A);
const kBorder   = Color(0xFF263040);
const kAccent   = Color(0xFF00B4D8);
const kAccent2  = Color(0xFF06D6A0);
const kAccent3  = Color(0xFFFF6B6B);
const kWarn     = Color(0xFFFFD166);
const kText     = Color(0xFFD6E4F0);
const kTextDim  = Color(0xFF6B8099);
const kTextMid  = Color(0xFF9AB0C8);

// ═══════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════

enum FieldType { numeric, hex, text, toggle, readonly }

class FieldDef {
  final String num;
  final String label;
  final String defaultValue;
  final FieldType type;
  final String? unit;
  FieldDef(this.num, this.label, this.defaultValue,
      {this.type = FieldType.hex, this.unit});
}

class MenuDef {
  final String code;
  final String label;
  final String instruction;
  final List<FieldDef> fields;
  MenuDef(this.code, this.label, this.instruction, this.fields);
}

class PageDef {
  final String label;
  final String name;
  final List<MenuDef> menus;
  PageDef(this.label, this.name, this.menus);
}

// ═══════════════════════════════════════════
// ALL 10 PAGES DATA
// ═══════════════════════════════════════════

final List<PageDef> kAllPages = [
  // ── PAGE 1 ──
  PageDef('P1', 'システム設定', [
    MenuDef('001', 'システム起動エラー情報', '画面情報を確認してください', [
      FieldDef('01', '画面No.',       '0001', type: FieldType.readonly),
      FieldDef('02', '画面名',        'システム起動エラー情報', type: FieldType.readonly),
      FieldDef('03', '画面画像',      '---', type: FieldType.readonly),
      FieldDef('04', 'エラーコード',  '0000', type: FieldType.hex),
      FieldDef('05', 'エラー詳細',    '0000 0000', type: FieldType.hex),
      FieldDef('06', '発生日時',      '2027.04.08 18:30', type: FieldType.readonly),
      FieldDef('07', '復旧状態',      '01', type: FieldType.hex),
    ]),
    MenuDef('002', '定数設定', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', 'コーナ',              '1F',    type: FieldType.hex),
      FieldDef('02', '号機',               '01',    type: FieldType.hex),
      FieldDef('03', '自動設定',            '21',    type: FieldType.hex),
      FieldDef('04', '事業者コード',        '193844', type: FieldType.hex),
      FieldDef('05', '外部媒体用駅所コード','93845',  type: FieldType.hex),
      FieldDef('06', '上位接続',            '9937304', type: FieldType.hex),
      FieldDef('07', '磁気ユニット',        '0',     type: FieldType.hex),
      FieldDef('08', 'ICユニット',          '0',     type: FieldType.hex),
      FieldDef('09', 'レストモードの表示可否', '0',  type: FieldType.toggle),
      FieldDef('10', '企画券フラグ',        '0',     type: FieldType.toggle),
      FieldDef('11', '予備',               '0',     type: FieldType.hex),
      FieldDef('12', '磁気定発使用可否フラグ', '0',  type: FieldType.toggle),
      FieldDef('13', 'IC窓処使用可否フラグ',  '0',  type: FieldType.toggle),
      FieldDef('14', 'IC定発使用可否フラグ',  '0',  type: FieldType.toggle),
      FieldDef('15', 'IC定発限定フラグ',      '0',  type: FieldType.toggle),
      FieldDef('16', 'IC定期券新規発売可能',   '1',  type: FieldType.toggle),
      FieldDef('17', 'IC定期券継続発売可能',   '1',  type: FieldType.toggle),
      FieldDef('18', '磁気定期券新規発売可能', '1',  type: FieldType.toggle),
      FieldDef('19', '磁気定期券継続発売可能', '1',  type: FieldType.toggle),
      FieldDef('20', '磁気定期券特別発行可能', '0',  type: FieldType.toggle),
    ]),
    MenuDef('003', 'IPアドレス設定', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', 'LAN1 IPアドレス',               '192.168.010.100', type: FieldType.numeric),
      FieldDef('02', 'LAN1 ネットマスク',             '255.255.255.000', type: FieldType.numeric),
      FieldDef('03', 'LAN1 ゲートウェイ',             '192.168.010.001', type: FieldType.numeric),
      FieldDef('04', 'LAN2 IPアドレス',               '127.000.000.001', type: FieldType.numeric),
      FieldDef('05', 'LAN2 ネットマスク',             '255.255.255.000', type: FieldType.numeric),
      FieldDef('06', 'LAN2 ゲートウェイ',             '000.000.000.000', type: FieldType.numeric),
      FieldDef('07', '上位 IP',                        '192.168.010.010', type: FieldType.numeric),
      FieldDef('08', '遠調配信サーバ IPアドレス',      '010.012.001.080', type: FieldType.numeric),
      FieldDef('09', '遠調配信サーバ ソケットポート',  '7635',            type: FieldType.numeric),
      FieldDef('10', '遠調配信サーバ FTPポート',       '40501',           type: FieldType.numeric),
    ]),
    MenuDef('004', 'Kbytesエディタ',    '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', 'アドレス', '0000', type: FieldType.hex),
      FieldDef('02', 'データ',   '00',   type: FieldType.hex),
      FieldDef('03', 'サイズ',   '0001', type: FieldType.hex),
    ]),
    MenuDef('005', 'FK_DATAコピー',     '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', 'コピー元', '0000', type: FieldType.hex),
      FieldDef('02', 'コピー先', '0001', type: FieldType.hex),
    ]),
    MenuDef('009', '本体ソフトバージョン表示', '画面情報を確認してください', [
      FieldDef('01', 'バージョン', 'V2.10', type: FieldType.readonly),
      FieldDef('02', 'ビルド日',   '2027.04.01', type: FieldType.readonly),
    ]),
    MenuDef('010', '手数料確認',   '確認してください', [
      FieldDef('01', '手数料コード', '01', type: FieldType.hex),
      FieldDef('02', '金額',         '0000', type: FieldType.hex, unit: '円'),
    ]),
    MenuDef('011', '表示用駅名データロード', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', '種別',       '表示用', type: FieldType.readonly),
      FieldDef('02', '実行ファイル','SUB-00273-25', type: FieldType.readonly),
      FieldDef('03', 'CFパス',     r'C:\EKIMEI', type: FieldType.text),
    ]),
    MenuDef('012', '8文字駅名データロード', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', '種別',        '8文字', type: FieldType.readonly),
      FieldDef('02', '実行ファイル','SUB-00274-12', type: FieldType.readonly),
      FieldDef('03', 'CFパス',      r'C:\MOJI', type: FieldType.text),
    ]),
    MenuDef('013', '表示用地社会名データロード', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', '種別',        '社名', type: FieldType.readonly),
      FieldDef('02', '実行ファイル','SUB-00275-08', type: FieldType.readonly),
    ]),
    MenuDef('014', '表示用バス会社名データロード', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', '種別',        'バス', type: FieldType.readonly),
      FieldDef('02', '実行ファイル','SUB-00276-03', type: FieldType.readonly),
    ]),
    MenuDef('015', '払戻手数料データロード', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', '種別',        '払戻', type: FieldType.readonly),
      FieldDef('02', '実行ファイル','SUB-00277-19', type: FieldType.readonly),
    ]),
    MenuDef('016', 'マスタデータロード', '入力・選択を行い実行ボタンを押してください', [
      FieldDef('01', '種別',        'マスタ', type: FieldType.readonly),
      FieldDef('02', '実行ファイル','SUB-00278-44', type: FieldType.readonly),
    ]),
    MenuDef('017', 'マスタアップデート', '実行ボタンを押してください', [
      FieldDef('01', 'バージョン', '現在: V2.09', type: FieldType.readonly),
      FieldDef('02', '適用後',     'V2.10',       type: FieldType.readonly),
    ]),
    MenuDef('018', 'マスタバージョン番号クリア', '実行ボタンを押してください', [
      FieldDef('01', '現バージョン', 'V2.10', type: FieldType.readonly),
    ]),
    MenuDef('019', '新旧駅IDデータ外部媒体出力', '実行ボタンを押してください', [
      FieldDef('01', '出力先', r'C:\OUTPUT', type: FieldType.text),
    ]),
    MenuDef('020', '手数料確認2', '確認してください', [
      FieldDef('01', '確認コード', '00', type: FieldType.hex),
    ]),
  ]),

  // ── PAGE 2 ──
  PageDef('P2', '駅名データ', [
    MenuDef('021', '駅名マスタ同期',  '実行ボタンを押してください', [FieldDef('01', '同期先', '0001', type: FieldType.hex)]),
    MenuDef('022', '駅コード変換',    '入力・選択を行い実行ボタンを押してください', [FieldDef('01', '駅コード', '0000', type: FieldType.hex)]),
    MenuDef('023', '新旧ID変換',      '入力後実行してください', [FieldDef('01', '旧ID', '0000', type: FieldType.hex), FieldDef('02', '新ID', '0000', type: FieldType.hex)]),
    MenuDef('024', '駅名一覧印刷',    '実行ボタンを押してください', [FieldDef('01', '部数', '001', type: FieldType.numeric)]),
    MenuDef('025', '駅順コード設定',  '入力後実行', [FieldDef('01', '開始コード', '0000', type: FieldType.hex)]),
  ]),

  // ── PAGE 3 ──
  PageDef('P3', '社員情報', [
    MenuDef('031', '社員マスタ設定',  '入力後実行', [FieldDef('01', '社員コード', '000000', type: FieldType.hex), FieldDef('02', '権限レベル', '01', type: FieldType.hex)]),
    MenuDef('032', '権限ログ確認',    '確認してください', [FieldDef('01', '社員No.', '000001', type: FieldType.readonly)]),
    MenuDef('033', 'パスワード変更',  '入力後実行', [FieldDef('01', '旧PW', '****', type: FieldType.hex), FieldDef('02', '新PW', '****', type: FieldType.hex)]),
    MenuDef('034', '社員名データロード', '実行ボタンを押してください', [FieldDef('01', '種別', '社員', type: FieldType.readonly)]),
    MenuDef('035', '勤務記録確認',    '確認してください', [FieldDef('01', '日付', '2027.04.08', type: FieldType.readonly)]),
  ]),

  // ── PAGE 4 ──
  PageDef('P4', 'バス路線', [
    MenuDef('041', 'バス路線マスタ',  '入力後実行', [FieldDef('01', '路線コード', '0001', type: FieldType.hex), FieldDef('02', '路線名', '---', type: FieldType.text)]),
    MenuDef('042', 'バス停設定',      '入力後実行', [FieldDef('01', '停留所コード', '0000', type: FieldType.hex)]),
    MenuDef('043', 'バス会社設定',    '入力後実行', [FieldDef('01', '会社コード', '01', type: FieldType.hex)]),
    MenuDef('044', 'バスデータロード', '実行ボタンを押してください', [FieldDef('01', '実行ファイル', 'SUB-00280', type: FieldType.readonly)]),
  ]),

  // ── PAGE 5 ──
  PageDef('P5', '料金管理', [
    MenuDef('051', '料金マスタ設定',  '入力後実行', [FieldDef('01', '種別コード', '01', type: FieldType.hex), FieldDef('02', '金額', '0000', type: FieldType.hex, unit: '円')]),
    MenuDef('052', '割引設定',        '入力後実行', [FieldDef('01', '割引率', '00', type: FieldType.hex, unit: '%')]),
    MenuDef('053', '手数料設定',      '入力後実行', [FieldDef('01', '手数料', '0000', type: FieldType.hex, unit: '円')]),
    MenuDef('054', '料金データロード', '実行ボタンを押してください', [FieldDef('01', 'ファイル', r'C:\FARE', type: FieldType.text)]),
    MenuDef('055', '料金一覧確認',    '確認してください', [FieldDef('01', '表示件数', '20', type: FieldType.numeric)]),
  ]),

  // ── PAGE 6 ──
  PageDef('P6', 'マスタ管理', [
    MenuDef('061', 'マスタ初期化',    '実行ボタンを押してください', [FieldDef('01', '確認コード', '0000', type: FieldType.hex)]),
    MenuDef('062', 'マスタバックアップ', '実行ボタンを押してください', [FieldDef('01', '出力先', r'C:\BACKUP', type: FieldType.text)]),
    MenuDef('063', 'マスタリストア',  '実行ボタンを押してください', [FieldDef('01', '入力元', r'C:\BACKUP', type: FieldType.text)]),
    MenuDef('064', 'マスタ整合性確認', '確認してください', [FieldDef('01', '状態', '正常', type: FieldType.readonly)]),
    MenuDef('065', 'マスタバージョン管理', '確認・入力してください', [FieldDef('01', 'バージョン', 'V2.10', type: FieldType.readonly)]),
  ]),

  // ── PAGE 7 ──
  PageDef('P7', 'バージョン管理', [
    MenuDef('071', 'ソフトバージョン表示', '確認してください', [FieldDef('01', 'バージョン', 'V2.10', type: FieldType.readonly), FieldDef('02', 'ビルド', '20270401', type: FieldType.readonly)]),
    MenuDef('072', 'バージョンアップ',     '実行ボタンを押してください', [FieldDef('01', '適用ファイル', r'C:\UPDATE', type: FieldType.text)]),
    MenuDef('073', 'バージョン履歴',       '確認してください', [FieldDef('01', '履歴件数', '10', type: FieldType.readonly)]),
    MenuDef('074', 'ロールバック',         '実行ボタンを押してください', [FieldDef('01', '戻すバージョン', 'V2.09', type: FieldType.text)]),
  ]),

  // ── PAGE 8 ──
  PageDef('P8', '障害ログ', [
    MenuDef('081', '障害ログ表示',    '確認してください', [FieldDef('01', '表示件数', '20', type: FieldType.numeric), FieldDef('02', 'フィルタ', '00', type: FieldType.hex)]),
    MenuDef('082', '障害ログクリア', '実行ボタンを押してください', [FieldDef('01', '確認コード', '0000', type: FieldType.hex)]),
    MenuDef('083', '障害ログ出力',   '実行ボタンを押してください', [FieldDef('01', '出力先', r'C:\LOG', type: FieldType.text)]),
    MenuDef('084', 'エラー統計',     '確認してください', [FieldDef('01', '集計期間', '30', type: FieldType.numeric, unit: '日')]),
    MenuDef('085', 'アラート設定',   '入力後実行', [FieldDef('01', 'しきい値', '10', type: FieldType.numeric)]),
  ]),

  // ── PAGE 9 ──
  PageDef('P9', 'ネットワーク', [
    MenuDef('091', 'ネット接続確認',  '実行ボタンを押してください', [FieldDef('01', '接続先IP', '192.168.010.001', type: FieldType.numeric)]),
    MenuDef('092', '通信速度測定',   '実行ボタンを押してください', [FieldDef('01', '測定回数', '5', type: FieldType.numeric)]),
    MenuDef('093', 'ポート確認',     '入力後実行', [FieldDef('01', 'ポート番号', '7635', type: FieldType.numeric)]),
    MenuDef('094', 'DNS設定',        '入力後実行', [FieldDef('01', 'DNS1', '8.8.8.8', type: FieldType.numeric), FieldDef('02', 'DNS2', '8.8.4.4', type: FieldType.numeric)]),
    MenuDef('095', 'ネット診断',     '実行ボタンを押してください', [FieldDef('01', '診断レベル', '01', type: FieldType.hex)]),
  ]),

  // ── PAGE 10 ──
  PageDef('P10', 'バックアップ', [
    MenuDef('101', 'フルバックアップ', '実行ボタンを押してください', [FieldDef('01', '出力先', r'C:\BACKUP', type: FieldType.text)]),
    MenuDef('102', '差分バックアップ', '実行ボタンを押してください', [FieldDef('01', '出力先', r'C:\BACKUP\DIFF', type: FieldType.text)]),
    MenuDef('103', 'リストア',        '実行ボタンを押してください', [FieldDef('01', '入力元', r'C:\BACKUP', type: FieldType.text)]),
    MenuDef('104', 'バックアップ確認', '確認してください', [FieldDef('01', '最終日時', '2027.04.08 18:00', type: FieldType.readonly)]),
    MenuDef('105', 'スケジュール設定', '入力後実行', [FieldDef('01', '時刻', '02:00', type: FieldType.text), FieldDef('02', '頻度', '毎日', type: FieldType.readonly)]),
  ]),
];

// ═══════════════════════════════════════════
// APP
// ═══════════════════════════════════════════

class MaintenanceApp extends StatelessWidget {
  const MaintenanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '保守メニュー',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ═══════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  int _pageIdx = 0;
  MenuDef? _openMenu;

  // Per-menu field value maps: menuCode -> {fieldNum -> value}
  final Map<String, Map<String, String>> _fieldValues = {};

  // Numpad state
  bool _numpadOpen = false;
  String _numpadTarget = ''; // "menuCode:fieldNum"
  String _numpadBuf = '';
  String _numpadLabel = '';
  FieldType _numpadType = FieldType.hex;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: kAllPages.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _pageIdx = _tabCtrl.index;
          _openMenu = null;
          _numpadOpen = false;
        });
      }
    });
    // Init all field values to defaults
    for (final page in kAllPages) {
      for (final menu in page.menus) {
        _fieldValues[menu.code] = {};
        for (final f in menu.fields) {
          _fieldValues[menu.code]![f.num] = f.defaultValue;
        }
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  PageDef get _curPage => kAllPages[_pageIdx];

  String _getVal(String menuCode, String fieldNum) =>
      _fieldValues[menuCode]?[fieldNum] ?? '';

  void _setVal(String menuCode, String fieldNum, String val) {
    setState(() => _fieldValues[menuCode]![fieldNum] = val);
  }

  // ── Numpad ──
  void _openNumpad(String menuCode, FieldDef field) {
    setState(() {
      _numpadTarget = '$menuCode:${field.num}';
      _numpadBuf = _getVal(menuCode, field.num);
      _numpadLabel = field.label;
      _numpadType = field.type;
      _numpadOpen = true;
    });
  }

  void _numpadKey(String k) => setState(() {
    if (k == '⌫') {
      if (_numpadBuf.isNotEmpty) _numpadBuf = _numpadBuf.substring(0, _numpadBuf.length - 1);
    } else if (k == 'CLR') {
      _numpadBuf = '';
    } else {
      _numpadBuf += k;
    }
  });

  void _numpadConfirm() {
    final parts = _numpadTarget.split(':');
    if (parts.length == 2 && _numpadBuf.isNotEmpty) {
      _setVal(parts[0], parts[1], _numpadBuf);
    }
    setState(() { _numpadOpen = false; _numpadBuf = ''; });
  }

  void _numpadClose() => setState(() { _numpadOpen = false; _numpadBuf = ''; });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Column(children: [
            _Header(pageIdx: _pageIdx, openMenu: _openMenu,
              onLogoff: () {}, totalH: h),
            _TabBar(ctrl: _tabCtrl, pages: kAllPages, totalW: w),
            Expanded(child: Stack(children: [
              Row(children: [
                // Left nav
                SizedBox(
                  width: w < 600 ? w * 0.32 : 200,
                  child: _NavPanel(
                    page: _curPage,
                    openMenu: _openMenu,
                    onSelect: (m) => setState(() {
                      _openMenu = m;
                      _numpadOpen = false;
                    }),
                  ),
                ),
                // Right content
                Expanded(child: _openMenu == null
                  ? _WelcomePanel(page: _curPage)
                  : _MenuDetailPanel(
                      menu: _openMenu!,
                      getVal: (fn) => _getVal(_openMenu!.code, fn),
                      onTapField: (f) => _openNumpad(_openMenu!.code, f),
                      onToggle: (f) {
                        final cur = _getVal(_openMenu!.code, f.num);
                        _setVal(_openMenu!.code, f.num, cur == '0' ? '1' : '0');
                      },
                      onBack: () => setState(() { _openMenu = null; _numpadOpen = false; }),
                      onExec: () => _showSnack('✓ ${_openMenu!.label} 実行完了'),
                      onCancel: () => setState(() { _openMenu = null; _numpadOpen = false; }),
                    ),
                ),
              ]),
              // Numpad overlay
              if (_numpadOpen)
                _NumpadOverlay(
                  label: _numpadLabel,
                  buffer: _numpadBuf,
                  type: _numpadType,
                  onKey: _numpadKey,
                  onOk: _numpadConfirm,
                  onClose: _numpadClose,
                ),
            ])),
            _Footer(pageIdx: _pageIdx, total: kAllPages.length,
              itemCount: _curPage.menus.length,
              onPrev: () { if (_tabCtrl.index > 0) _tabCtrl.animateTo(_tabCtrl.index - 1); },
              onNext: () { if (_tabCtrl.index < kAllPages.length - 1) _tabCtrl.animateTo(_tabCtrl.index + 1); },
            ),
          ]);
        }),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: kAccent2)),
      backgroundColor: kSurface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: kAccent2.withOpacity(0.3))),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ═══════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════
class _Header extends StatefulWidget {
  final int pageIdx;
  final MenuDef? openMenu;
  final VoidCallback onLogoff;
  final double totalH;
  const _Header({required this.pageIdx, required this.openMenu, required this.onLogoff, required this.totalH});
  @override State<_Header> createState() => _HeaderState();
}
class _HeaderState extends State<_Header> {
  String _time = '';
  @override void initState() { super.initState(); _tick(); }
  void _tick() {
    if (!mounted) return;
    final n = DateTime.now();
    setState(() => _time = '${n.year}.${_p(n.month)}.${_p(n.day)} ${_p(n.hour)}:${_p(n.minute)}:${_p(n.second)}');
    Future.delayed(const Duration(seconds: 1), _tick);
  }
  String _p(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final page = kAllPages[widget.pageIdx];
    return Container(
      height: 40,
      color: kSurface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        Container(width: 7, height: 7,
          decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text('保守メニュー', style: TextStyle(fontFamily: 'monospace',
          fontSize: 12, fontWeight: FontWeight.w700, color: kAccent, letterSpacing: 1.5)),
        const SizedBox(width: 10),
        const Text('›', style: TextStyle(color: kBorder, fontFamily: 'monospace')),
        const SizedBox(width: 6),
        Flexible(child: Text(page.name,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: kTextMid),
          overflow: TextOverflow.ellipsis)),
        if (widget.openMenu != null) ...[
          const Text('  ›  ', style: TextStyle(color: kBorder, fontFamily: 'monospace', fontSize: 10)),
          Flexible(child: Text(widget.openMenu!.label,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: kAccent),
            overflow: TextOverflow.ellipsis)),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: kAccent2.withOpacity(0.1),
            border: Border.all(color: kAccent2.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(100)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 5, height: 5,
              decoration: const BoxDecoration(color: kAccent2, shape: BoxShape.circle)),
            const SizedBox(width: 3),
            const Text('ONLINE', style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: kAccent2)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(_time, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: kTextDim)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: widget.onLogoff,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: kAccent3.withOpacity(0.15),
              border: Border.all(color: kAccent3.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4)),
            child: const Text('ログオフ',
              style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: kAccent3, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
// TAB BAR
// ═══════════════════════════════════════════
class _TabBar extends StatelessWidget {
  final TabController ctrl;
  final List<PageDef> pages;
  final double totalW;
  const _TabBar({required this.ctrl, required this.pages, required this.totalW});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: kSurface2,
      child: TabBar(
        controller: ctrl,
        isScrollable: totalW < 700,
        indicatorColor: kAccent,
        indicatorWeight: 2,
        labelColor: kAccent,
        unselectedLabelColor: kTextDim,
        dividerColor: kBorder,
        tabAlignment: totalW < 700 ? TabAlignment.start : TabAlignment.fill,
        labelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 9),
        tabs: pages.map((p) => Tab(height: 32,
          child: FittedBox(fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(p.label, style: const TextStyle(fontSize: 7, color: kTextDim)),
              const SizedBox(width: 2),
              Text(p.name.length > 5 ? '${p.name.substring(0, 4)}…' : p.name),
            ])))).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// LEFT NAV PANEL
// ═══════════════════════════════════════════
class _NavPanel extends StatelessWidget {
  final PageDef page;
  final MenuDef? openMenu;
  final ValueChanged<MenuDef> onSelect;
  const _NavPanel({required this.page, required this.openMenu, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: kSurface,
        border: Border(right: BorderSide(color: kBorder))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          color: kSurface2,
          width: double.infinity,
          child: Text('< 保守メニュー ${page.label}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 8,
              color: kTextDim, letterSpacing: 1), overflow: TextOverflow.ellipsis),
        ),
        Expanded(child: ListView.builder(
          itemCount: page.menus.length,
          itemBuilder: (ctx, i) {
            final m = page.menus[i];
            final active = openMenu?.code == m.code;
            return GestureDetector(
              onTap: () => onSelect(m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kAccent.withOpacity(0.1) : Colors.transparent,
                  border: Border(
                    left: BorderSide(color: active ? kAccent : Colors.transparent, width: 2),
                    bottom: BorderSide(color: kBorder.withOpacity(0.4)),
                  ),
                ),
                child: Row(children: [
                  Text(m.code, style: TextStyle(fontFamily: 'monospace', fontSize: 9,
                    color: active ? kAccent : kAccent.withOpacity(0.6), fontWeight: FontWeight.w700)),
                  const SizedBox(width: 5),
                  Expanded(child: Text(m.label,
                    style: TextStyle(fontSize: 10, color: active ? kText : kTextMid),
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
// WELCOME PANEL
// ═══════════════════════════════════════════
class _WelcomePanel extends StatelessWidget {
  final PageDef page;
  const _WelcomePanel({required this.page});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: kWarn.withOpacity(0.08),
          border: Border.all(color: kWarn.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(4)),
        child: const Text('入力・選択を行い実行ボタンを押してください',
          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: kWarn)),
      ),
      const SizedBox(height: 20),
      Text(page.name, style: const TextStyle(fontFamily: 'monospace', fontSize: 16,
        color: kTextDim, letterSpacing: 2)),
      const SizedBox(height: 8),
      Text('${page.menus.length} メニュー', style: const TextStyle(fontFamily: 'monospace',
        fontSize: 10, color: kBorder)),
    ]));
  }
}

// ═══════════════════════════════════════════
// MENU DETAIL PANEL
// ═══════════════════════════════════════════
class _MenuDetailPanel extends StatelessWidget {
  final MenuDef menu;
  final String Function(String fieldNum) getVal;
  final void Function(FieldDef) onTapField;
  final void Function(FieldDef) onToggle;
  final VoidCallback onBack;
  final VoidCallback onExec;
  final VoidCallback onCancel;
  const _MenuDetailPanel({
    required this.menu, required this.getVal,
    required this.onTapField, required this.onToggle,
    required this.onBack, required this.onExec, required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Sub-header
      Container(
        height: 30,
        color: kSurface2,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          GestureDetector(onTap: onBack,
            child: Row(children: const [
              Icon(Icons.arrow_back_ios, size: 11, color: kTextDim),
              Text('戻る', style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: kTextDim)),
            ])),
          const SizedBox(width: 10),
          Flexible(child: Text('${menu.code}  ${menu.label}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: kTextMid),
            overflow: TextOverflow.ellipsis)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: kWarn.withOpacity(0.07),
              border: Border.all(color: kWarn.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(3)),
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(menu.instruction,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 8, color: kWarn))),
          ),
        ]),
      ),
      // Fields list
      Expanded(child: LayoutBuilder(builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w < 400 ? 6 : 12, vertical: 6),
          child: Column(children: menu.fields.map((f) {
            final val = getVal(f.num);
            final isReadonly = f.type == FieldType.readonly;
            final isToggle = f.type == FieldType.toggle;

            return GestureDetector(
              onTap: isReadonly ? null : isToggle ? () => onToggle(f) : () => onTapField(f),
              child: Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: EdgeInsets.symmetric(horizontal: w < 400 ? 6 : 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isReadonly ? Colors.transparent : kSurface2,
                  border: Border(
                    bottom: BorderSide(color: kBorder.withOpacity(0.4)),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(children: [
                  // Row number
                  SizedBox(width: 22, child: Text(f.num,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: kTextDim),
                    textAlign: TextAlign.right)),
                  const SizedBox(width: 10),
                  // Label
                  Expanded(flex: 3, child: Text(f.label,
                    style: TextStyle(fontFamily: 'monospace', fontSize: w < 400 ? 9 : 10,
                      color: isReadonly ? kTextDim : kTextMid),
                    overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  // Value
                  if (isToggle)
                    _ToggleChip(value: val == '1')
                  else
                    Expanded(flex: 2, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isReadonly ? Colors.transparent : kSurface3,
                        border: isReadonly ? null : Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(children: [
                        Expanded(child: Text(val,
                          style: TextStyle(fontFamily: 'monospace',
                            fontSize: w < 400 ? 9 : 11,
                            color: isReadonly ? kTextDim : kText,
                            fontWeight: isReadonly ? FontWeight.normal : FontWeight.w500),
                          overflow: TextOverflow.ellipsis)),
                        if (f.unit != null) Text(' ${f.unit}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: kTextDim)),
                        if (!isReadonly) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 10, color: kTextDim.withOpacity(0.4)),
                        ],
                      ]),
                    )),
                ]),
              ),
            );
          }).toList()),
        );
      })),
      // Footer buttons
      _DetailFooter(onCancel: onCancel, onExec: onExec),
    ]);
  }
}

class _ToggleChip extends StatelessWidget {
  final bool value;
  const _ToggleChip({required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: value ? kAccent2.withOpacity(0.15) : kSurface3,
        border: Border.all(color: value ? kAccent2.withOpacity(0.4) : kBorder),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(value ? 'ON  1' : 'OFF 0',
        style: TextStyle(fontFamily: 'monospace', fontSize: 9,
          color: value ? kAccent2 : kTextDim, fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onExec;
  const _DetailFooter({required this.onCancel, required this.onExec});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      color: kSurface2,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        const Spacer(),
        GestureDetector(onTap: onCancel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(color: kSurface,
              border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(4)),
            child: const Text('取消', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: kTextDim)),
          )),
        const SizedBox(width: 8),
        GestureDetector(onTap: onExec,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(color: kAccent,
              borderRadius: BorderRadius.circular(4)),
            child: const Text('実行', style: TextStyle(fontFamily: 'monospace', fontSize: 10,
              color: Colors.black, fontWeight: FontWeight.w700)),
          )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
// FOOTER
// ═══════════════════════════════════════════
class _Footer extends StatelessWidget {
  final int pageIdx;
  final int total;
  final int itemCount;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _Footer({required this.pageIdx, required this.total, required this.itemCount,
    required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: kSurface2,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        Text('PAGE ${pageIdx + 1} / $total  —  $itemCount items',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: kTextDim)),
        const Spacer(),
        _NavBtn('◀', onPrev),
        const SizedBox(width: 4),
        _NavBtn('▶', onNext),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(
        width: 26, height: 22,
        decoration: BoxDecoration(color: kAccent.withOpacity(0.07),
          border: Border.all(color: kAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(3)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: kAccent)),
      ));
  }
}

// ═══════════════════════════════════════════
// TRANSPARENT HEX/NUMERIC NUMPAD OVERLAY
// ═══════════════════════════════════════════

class _NumpadOverlay extends StatelessWidget {
  final String label;
  final String buffer;
  final FieldType type;
  final void Function(String) onKey;
  final VoidCallback onOk;
  final VoidCallback onClose;

  const _NumpadOverlay({
    required this.label, required this.buffer, required this.type,
    required this.onKey, required this.onOk, required this.onClose,
  });

  bool get _isHex => type == FieldType.hex;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: Stack(children: [
      // Backdrop dismiss
      GestureDetector(onTap: onClose,
        child: Container(color: Colors.black.withOpacity(0.2))),
      // Panel — bottom right
      Positioned(
        bottom: 8, right: 8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: LayoutBuilder(builder: (ctx, _) {
              return Container(
                width: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1A2A).withOpacity(0.72),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.07),
                      border: Border.all(color: kAccent.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(label.toUpperCase(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 8,
                          color: kAccent, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Row(children: [
                        if (_isHex)
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: kAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3)),
                            child: const Text('HEX', style: TextStyle(fontFamily: 'monospace',
                              fontSize: 7, color: kAccent, fontWeight: FontWeight.w700)),
                          ),
                        Expanded(child: Text(buffer,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 15,
                            fontWeight: FontWeight.w500, color: kText, letterSpacing: 1.5),
                          overflow: TextOverflow.ellipsis)),
                        Container(width: 2, height: 14, color: kAccent,
                          margin: const EdgeInsets.only(left: 2)),
                      ]),
                    ]),
                  ),
                  // Numeric row 1
                  _NpRow(['7','8','9','⌫'], onKey),
                  const SizedBox(height: 5),
                  _NpRow(['4','5','6', _isHex ? 'A' : '.'], onKey),
                  const SizedBox(height: 5),
                  _NpRow(['1','2','3', _isHex ? 'B' : '0'], onKey),
                  const SizedBox(height: 5),
                  if (_isHex) ...[
                    _NpRow(['C','D','E','F'], onKey),
                    const SizedBox(height: 5),
                    _NpRow(['0', '.', 'CLR', ''], onKey, lastIsEmpty: true),
                    const SizedBox(height: 5),
                  ] else ...[
                    _NpRow(['0', 'CLR', '', ''], onKey, lastIsEmpty: true, last2Empty: true),
                    const SizedBox(height: 5),
                  ],
                  // OK / Cancel
                  Row(children: [
                    Expanded(child: _NpKey('取消', onKey, isCancelBtn: true, onClose: onClose)),
                    const SizedBox(width: 5),
                    Expanded(flex: 2, child: _NpKey('OK', onKey, isOkBtn: true, onOk: onOk)),
                  ]),
                ]),
              );
            }),
          ),
        ),
      ),
    ]));
  }
}

class _NpRow extends StatelessWidget {
  final List<String> keys;
  final void Function(String) onKey;
  final bool lastIsEmpty;
  final bool last2Empty;
  const _NpRow(this.keys, this.onKey, {this.lastIsEmpty = false, this.last2Empty = false});
  @override
  Widget build(BuildContext context) {
    return Row(children: keys.asMap().entries.map((e) {
      final i = e.key; final k = e.value;
      final isEmpty = (lastIsEmpty && i == keys.length - 1) || (last2Empty && i >= keys.length - 2);
      if (isEmpty) return Expanded(child: Container());
      return Expanded(child: Padding(
        padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
        child: _NpKey(k, onKey),
      ));
    }).toList());
  }
}

class _NpKey extends StatelessWidget {
  final String label;
  final void Function(String) onKey;
  final bool isCancelBtn;
  final bool isOkBtn;
  final VoidCallback? onClose;
  final VoidCallback? onOk;

  const _NpKey(this.label, this.onKey,
      {this.isCancelBtn = false, this.isOkBtn = false, this.onClose, this.onOk});

  @override
  Widget build(BuildContext context) {
    Color bg, border, fg;
    if (label == '⌫') {
      bg = kAccent3.withOpacity(0.12); border = kAccent3.withOpacity(0.25); fg = kAccent3;
    } else if (label == 'CLR') {
      bg = kWarn.withOpacity(0.10); border = kWarn.withOpacity(0.2); fg = kWarn;
    } else if (isOkBtn) {
      bg = kAccent2.withOpacity(0.18); border = kAccent2.withOpacity(0.3); fg = kAccent2;
    } else if (isCancelBtn) {
      bg = Colors.white.withOpacity(0.04); border = Colors.white.withOpacity(0.08); fg = kTextDim;
    } else if (RegExp(r'^[A-F]$').hasMatch(label)) {
      // Hex letter keys
      bg = kAccent.withOpacity(0.10); border = kAccent.withOpacity(0.2); fg = kAccent;
    } else {
      bg = Colors.white.withOpacity(0.07); border = Colors.white.withOpacity(0.1); fg = kText;
    }

    return GestureDetector(
      onTap: () {
        if (isOkBtn) { onOk?.call(); return; }
        if (isCancelBtn) { onClose?.call(); return; }
        onKey(label);
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(color: bg, border: Border.all(color: border),
          borderRadius: BorderRadius.circular(7)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          fontFamily: (isOkBtn || isCancelBtn) ? null : 'monospace',
          fontSize: (isOkBtn || isCancelBtn) ? 11 : 15,
          fontWeight: FontWeight.w500, color: fg)),
      ),
    );
  }
}
