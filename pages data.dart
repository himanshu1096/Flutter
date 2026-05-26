import '../models/field_def.dart';
import '../models/field_format.dart';
import '../models/menu_def.dart';
import '../models/page_def.dart';

final List<PageDef> kAllPages = [_p1,_p2,_p3,_p4,_p5,_p6,_p7,_p8,_p9,_p10];

// ── Common ranges ──
const _ipRange   = FieldRange(min:'000.000.000.000', max:'255.255.255.255', description:'IPアドレス');
const _portRange = FieldRange(min:'1024',            max:'65535',           description:'ポート番号');
const _byteRange = FieldRange(min:'00',              max:'FF',              description:'16進 1バイト');
const _wordRange = FieldRange(min:'0000',            max:'FFFF',            description:'16進 2バイト');

// ════════════════════════════════════════════
// PAGE 1
// ════════════════════════════════════════════
final _p1 = PageDef(label: 'P1', menus: [

  // ── 001 システム起動エラー情報 ──
  MenuDef(code:'001', label:'システム起動エラー情報',
    instruction:'保守体目を押下してください',
    memoryBaseAddress:'0x1000',
    fields:[
      FieldDef(num:'01', label:'画面No.',     defaultValue:'0001',                 type:FieldType.readonly, memoryAddress:'0x1000', memorySize:2, memoryAccess:MemoryAccessType.readOnly),
      FieldDef(num:'02', label:'画面名',       defaultValue:'システム起動エラー情報', type:FieldType.readonly, memoryAddress:'0x1002', memorySize:20, memoryAccess:MemoryAccessType.readOnly),
      FieldDef(num:'03', label:'エラーコード', defaultValue:'0000',                 type:FieldType.hex,      memoryAddress:'0x1000', memorySize:2, memoryAccess:MemoryAccessType.readOnly, range:_wordRange, format:FieldFormat.hexWord),
      FieldDef(num:'04', label:'エラー詳細',   defaultValue:'00000000',             type:FieldType.hex,      memoryAddress:'0x1002', memorySize:4, memoryAccess:MemoryAccessType.readOnly, range:FieldRange(min:'00000000',max:'FFFFFFFF',description:'4バイト'), format:FieldFormat.hexDword),
      FieldDef(num:'05', label:'発生日時',     defaultValue:'2027.04.08 18:30',     type:FieldType.readonly, memoryAddress:'0x1006', memorySize:8, memoryAccess:MemoryAccessType.readOnly),
      FieldDef(num:'06', label:'復旧状態',     defaultValue:'01',                   type:FieldType.hex,      memoryAddress:'0x100E', memorySize:1, memoryAccess:MemoryAccessType.readOnly, range:_byteRange, format:FieldFormat.hexByte),
    ]),

  // ── 002 定数設定 (30 fields) ──
  MenuDef(code:'002', label:'定数設定',
    instruction:'入力・選択をおこない、「実行」ボタンを押下してください',
    memoryBaseAddress:'0x2000',
    fields:[
      // 01 コーナ — 0x30〜0x7F
      FieldDef(num:'01', label:'コーナ',
        defaultValue:'30', type:FieldType.hex,
        memoryAddress:'0x2000', memorySize:1,
        range:FieldRange(min:'0x30', max:'0x7F', description:'コーナ番号'),
        format:FieldFormat.hexRng(0x30, 0x7F)),

      // 02 号機 — 00–99
      FieldDef(num:'02', label:'号機',
        defaultValue:'31', type:FieldType.numeric,
        memoryAddress:'0x2001', memorySize:1,
        range:FieldRange(min:'00', max:'99', description:'号機番号'),
        format:FieldFormat.dec(0, 99)),

      // 03 自駅設定 — NNN-NNN-NNN-NNN (000-000-255-255)
      FieldDef(num:'03', label:'自駅設定',
        defaultValue:'000-000-255-255', type:FieldType.numeric,
        memoryAddress:'0x2002', memorySize:4,
        range:FieldRange(min:'000-000-000-000', max:'255-255-255-255', description:'自駅設定'),
        format:FieldFormat.ipLike4),

      // 04 事業者コード — NN-NNN-NN-NNN (00-000〜99-255)
      FieldDef(num:'04', label:'事業者コード',
        defaultValue:'16-904', type:FieldType.numeric,
        memoryAddress:'0x2003', memorySize:3,
        range:FieldRange(min:'00-000', max:'99-255', description:'事業者コード'),
        format:FieldFormat.ipLike2x3),

      // 05 外部媒体用駅所コード — 0〜99999999
      FieldDef(num:'05', label:'外部媒体用駅所コード',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2006', memorySize:4,
        range:FieldRange(min:'0', max:'99999999', description:'外部媒体用駅所コード'),
        format:FieldFormat.decLarge(99999999)),

      // 06 上位接続 — 0:なし / 1:あり
      FieldDef(num:'06', label:'上位接続',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2009', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: なし / 1: あり'),
        format:FieldFormat.enum01('0: なし / 1: あり')),

      // 07 磁気ユニット — 0:使用可能 / 1:使用禁止
      FieldDef(num:'07', label:'磁気ユニット',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x200D', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 使用可能 / 1: 使用禁止'),
        format:FieldFormat.enum01('0: 使用可能 / 1: 使用禁止')),

      // 08 ICユニット — 0:使用可能 / 1:使用禁止
      FieldDef(num:'08', label:'ICユニット',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x200E', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 使用可能 / 1: 使用禁止'),
        format:FieldFormat.enum01('0: 使用可能 / 1: 使用禁止')),

      // 09 レストモードの表示可否フラグ — 0:非表示 / 1:表示
      FieldDef(num:'09', label:'レストモードの表示可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x200F', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 非表示 / 1: 表示'),
        format:FieldFormat.enum01('0: 非表示 / 1: 表示')),

      // 10 企画券フラグ — 0:定期券モード / 1:企画券モード
      FieldDef(num:'10', label:'企画券フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2010', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 定期券モード / 1: 企画券モード'),
        format:FieldFormat.enum01('0: 定期券モード / 1: 企画券モード')),

      // 11 磁気窓処理使用可否フラグ — 0:可 / 1:不可
      FieldDef(num:'11', label:'磁気窓処理使用可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2011', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 12 磁気定発使用可否フラグ — 0:可 / 1:不可
      FieldDef(num:'12', label:'磁気定発使用可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2012', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 13 IC窓処理使用可否フラグ — 0:可 / 1:不可
      FieldDef(num:'13', label:'IC窓処理使用可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2013', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 14 IC定発使用可否フラグ — 0:可 / 1:不可
      FieldDef(num:'14', label:'IC定発使用可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2014', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 15 IC定発限定フラグ — 0:通常 / 1:限定モード
      FieldDef(num:'15', label:'IC定発限定フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x2015', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 通常 / 1: 限定モード'),
        format:FieldFormat.enum01('0: 通常 / 1: 限定モード')),

      // 16 IC定期券新規販売可能期間 — 0〜99
      FieldDef(num:'16', label:'IC定期券新規販売可能期間',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2016', memorySize:1,
        range:FieldRange(min:'0', max:'99', description:'有効期間開始日からの日数 (0〜99日)'),
        format:FieldFormat.dec(0, 99, extra:'有効期間開始日の当日から選択できる日数')),

      // 17 IC定期券継続販売可能期間 — 0〜99
      FieldDef(num:'17', label:'IC定期券継続販売可能期間',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2017', memorySize:1,
        range:FieldRange(min:'0', max:'99', description:'有効期間開始日からの日数 (0〜99日)'),
        format:FieldFormat.dec(0, 99, extra:'有効期間開始日の当日から選択できる日数')),

      // 18 磁気定期券新規販売可能期間 — 0〜99
      FieldDef(num:'18', label:'磁気定期券新規販売可能期間',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2018', memorySize:1,
        range:FieldRange(min:'0', max:'99', description:'有効期間開始日からの日数 (0〜99日)'),
        format:FieldFormat.dec(0, 99)),

      // 19 磁気定期券継続販売可能期間 — 0〜99
      FieldDef(num:'19', label:'磁気定期券継続販売可能期間',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2019', memorySize:1,
        range:FieldRange(min:'0', max:'99', description:'有効期間開始日からの日数 (0〜99日)'),
        format:FieldFormat.dec(0, 99)),

      // 20 磁気定期券特別発行可能期間 — 0〜99
      FieldDef(num:'20', label:'磁気定期券特別発行可能期間',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x201A', memorySize:1,
        range:FieldRange(min:'0', max:'99', description:'特別発行可能期間 (0〜99日)'),
        format:FieldFormat.dec(0, 99)),

      // 21 業務制限パスワード使用可否フラグ — 0:可 / 1:不可
      FieldDef(num:'21', label:'業務制限PW使用可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x201B', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 22 業務制限パスワード表示可否フラグ — 0:可 / 1:不可
      FieldDef(num:'22', label:'業務制限PW表示可否フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x201C', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 23 広域マップ付会員収納コード（親局）— 0:可 / 1:不可
      FieldDef(num:'23', label:'広域MAP会員収納コード(親局)',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x201D', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 24 広域マップ付会員収納コード（親局）親局コード — 0〜25
      FieldDef(num:'24', label:'広域MAP親局コード',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x201E', memorySize:1,
        range:FieldRange(min:'0', max:'25', description:'親局コード (0〜25)'),
        format:FieldFormat.dec(0, 25)),

      // 25 稼動対象フラグ — 0:可 / 1:不可
      FieldDef(num:'25', label:'稼動対象フラグ',
        defaultValue:'0', type:FieldType.toggle,
        memoryAddress:'0x201F', memorySize:1,
        range:FieldRange(min:'0', max:'1', description:'0: 可 / 1: 不可'),
        format:FieldFormat.enum01('0: 可 / 1: 不可')),

      // 26 広域伝送確認番号 — 0〜255
      FieldDef(num:'26', label:'広域伝送確認番号',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2020', memorySize:1,
        range:FieldRange(min:'0', max:'255', description:'広域伝送確認番号 (0〜255)'),
        format:FieldFormat.dec(0, 255)),

      // 27 契約伝送確認番号 — 0〜255
      FieldDef(num:'27', label:'契約伝送確認番号',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2021', memorySize:1,
        range:FieldRange(min:'0', max:'255', description:'契約伝送確認番号 (0〜255)'),
        format:FieldFormat.dec(0, 255)),

      // 28 17基本料・PM管理（年）— 0〜2018
      FieldDef(num:'28', label:'17基本料・PM管理（年）',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2022', memorySize:2,
        range:FieldRange(min:'0', max:'2018', description:'年 (0〜2018)'),
        format:FieldFormat.dec(0, 2018)),

      // 29 17基本料・PM管理（月）— 0〜31
      FieldDef(num:'29', label:'17基本料・PM管理（月）',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2024', memorySize:1,
        range:FieldRange(min:'0', max:'31', description:'月 (0〜31)'),
        format:FieldFormat.dec(0, 31)),

      // 30 17基本料・PM管理（日）— 0〜23
      FieldDef(num:'30', label:'17基本料・PM管理（日）',
        defaultValue:'0', type:FieldType.numeric,
        memoryAddress:'0x2025', memorySize:1,
        range:FieldRange(min:'0', max:'23', description:'日 (0〜23)'),
        format:FieldFormat.dec(0, 23)),
    ]),

  // ── 003 IPアドレス設定 ──
  MenuDef(code:'003', label:'IPアドレス設定',
    instruction:'入力・選択をおこない、「実行」ボタンを押下してください',
    memoryBaseAddress:'0x3000',
    fields:[
      FieldDef(num:'01', label:'LAN1 IPアドレス',              defaultValue:'192.168.010.100', type:FieldType.numeric, memoryAddress:'0x3000', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'02', label:'LAN1 ネットマスク',            defaultValue:'255.255.255.000', type:FieldType.numeric, memoryAddress:'0x3004', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'03', label:'LAN1 ゲートウェイ',            defaultValue:'192.168.010.001', type:FieldType.numeric, memoryAddress:'0x3008', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'04', label:'LAN2 IPアドレス',              defaultValue:'127.000.000.001', type:FieldType.numeric, memoryAddress:'0x300C', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'05', label:'LAN2 ネットマスク',            defaultValue:'255.255.255.000', type:FieldType.numeric, memoryAddress:'0x3010', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'06', label:'LAN2 ゲートウェイ',            defaultValue:'000.000.000.000', type:FieldType.numeric, memoryAddress:'0x3014', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'07', label:'上位 IP',                       defaultValue:'192.168.010.010', type:FieldType.numeric, memoryAddress:'0x3018', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'08', label:'遠調配信サーバ IPアドレス',     defaultValue:'010.012.001.080', type:FieldType.numeric, memoryAddress:'0x301C', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress),
      FieldDef(num:'09', label:'遠調配信サーバ ソケットポート', defaultValue:'7635',            type:FieldType.numeric, memoryAddress:'0x3020', memorySize:2, range:_portRange, format:FieldFormat.dec(1024,65535)),
      FieldDef(num:'10', label:'遠調配信サーバ FTPポート',      defaultValue:'40501',           type:FieldType.numeric, memoryAddress:'0x3022', memorySize:2, range:_portRange, format:FieldFormat.dec(1024,65535)),
    ]),

  MenuDef(code:'004', label:'Kbytesエディタ', instruction:'入力後実行してください', memoryBaseAddress:'0x4000', fields:[
    FieldDef(num:'01', label:'アドレス', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x4000', memorySize:2, range:_wordRange, format:FieldFormat.hexWord),
    FieldDef(num:'02', label:'データ',   defaultValue:'00',   type:FieldType.hex, memoryAddress:'0x4002', memorySize:1, range:_byteRange, format:FieldFormat.hexByte),
    FieldDef(num:'03', label:'サイズ',   defaultValue:'0001', type:FieldType.hex, memoryAddress:'0x4003', memorySize:2, range:FieldRange(min:'0001',max:'0100',description:'1〜256バイト'), format:FieldFormat.hexWord),
  ]),
  MenuDef(code:'005', label:'FK_DATAコピー', instruction:'入力後実行してください', memoryBaseAddress:'0x4100', fields:[
    FieldDef(num:'01', label:'コピー元', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x4100', memorySize:2, range:_wordRange, format:FieldFormat.hexWord),
    FieldDef(num:'02', label:'コピー先', defaultValue:'0001', type:FieldType.hex, memoryAddress:'0x4102', memorySize:2, range:_wordRange, format:FieldFormat.hexWord),
  ]),
  MenuDef(code:'009', label:'本体ソフトバージョン表示', instruction:'確認してください', memoryBaseAddress:'0x4200', fields:[
    FieldDef(num:'01', label:'バージョン', defaultValue:'V2.10',     type:FieldType.readonly, memoryAddress:'0x4200', memorySize:8,  memoryAccess:MemoryAccessType.readOnly),
    FieldDef(num:'02', label:'ビルド日',   defaultValue:'2027.04.01', type:FieldType.readonly, memoryAddress:'0x4208', memorySize:10, memoryAccess:MemoryAccessType.readOnly),
  ]),
  MenuDef(code:'010', label:'手数料確認', instruction:'確認してください', memoryBaseAddress:'0x4300', fields:[
    FieldDef(num:'01', label:'手数料コード', defaultValue:'01',   type:FieldType.hex, memoryAddress:'0x4300', memorySize:1, range:_byteRange, format:FieldFormat.hexByte),
    FieldDef(num:'02', label:'金額',         defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x4301', memorySize:2, unit:'円', range:FieldRange(min:'0000',max:'9999',description:'手数料'), format:FieldFormat.hexWord),
  ]),
  MenuDef(code:'011', label:'表示用駅名データロード',      instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5000', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00273-25', type:FieldType.readonly, memoryAddress:'0x5000', memorySize:12)]),
  MenuDef(code:'012', label:'8文字駅名データロード',       instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5100', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00274-12', type:FieldType.readonly, memoryAddress:'0x5100', memorySize:12)]),
  MenuDef(code:'013', label:'表示用地社会名データロード',  instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5200', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00275-08', type:FieldType.readonly, memoryAddress:'0x5200', memorySize:12)]),
  MenuDef(code:'014', label:'表示用バス会社名データロード',instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5300', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00276-03', type:FieldType.readonly, memoryAddress:'0x5300', memorySize:12)]),
  MenuDef(code:'015', label:'払戻手数料データロード',      instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5400', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00277-19', type:FieldType.readonly, memoryAddress:'0x5400', memorySize:12)]),
  MenuDef(code:'016', label:'マスタデータロード',          instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5500', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00278-44', type:FieldType.readonly, memoryAddress:'0x5500', memorySize:12)]),
  MenuDef(code:'017', label:'マスタアップデート',          instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5600', fields:[FieldDef(num:'01', label:'現バージョン', defaultValue:'V2.09', type:FieldType.readonly, memoryAddress:'0x5600', memorySize:8), FieldDef(num:'02', label:'適用後', defaultValue:'V2.10', type:FieldType.readonly, memoryAddress:'0x5608', memorySize:8)]),
  MenuDef(code:'018', label:'マスタバージョン番号クリア',  instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5700', fields:[FieldDef(num:'01', label:'現バージョン', defaultValue:'V2.10', type:FieldType.readonly, memoryAddress:'0x5700', memorySize:8)]),
  MenuDef(code:'019', label:'新旧駅IDデータ外部媒体出力',  instruction:'実行ボタンを押してください', memoryBaseAddress:'0x5800', fields:[FieldDef(num:'01', label:'出力先', defaultValue:r'C:\OUTPUT', type:FieldType.text, memoryAddress:'0x5800', memorySize:32)]),
  MenuDef(code:'020', label:'新旧駅IDデータ確認',          instruction:'確認してください',          memoryBaseAddress:'0x5900', fields:[FieldDef(num:'01', label:'確認コード', defaultValue:'00', type:FieldType.hex, memoryAddress:'0x5900', memorySize:1, range:_byteRange, format:FieldFormat.hexByte)]),
]);

// ════════════════════════════════════════════
// PAGES 2–10 (same pattern)
// ════════════════════════════════════════════
final _p2 = PageDef(label:'P2', menus:[
  MenuDef(code:'021', label:'駅名マスタ同期',  instruction:'実行ボタンを押してください', memoryBaseAddress:'0x6000', fields:[FieldDef(num:'01', label:'同期先', defaultValue:'0001', type:FieldType.hex, memoryAddress:'0x6000', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]),
  MenuDef(code:'022', label:'駅コード変換',    instruction:'入力後実行してください',    memoryBaseAddress:'0x6100', fields:[FieldDef(num:'01', label:'駅コード', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x6100', memorySize:2, range:_wordRange, format:FieldFormat.hexWord), FieldDef(num:'02', label:'変換先', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x6102', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]),
  MenuDef(code:'023', label:'新旧ID変換',      instruction:'入力後実行してください',    memoryBaseAddress:'0x6200', fields:[FieldDef(num:'01', label:'旧ID', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x6200', memorySize:2, range:_wordRange, format:FieldFormat.hexWord), FieldDef(num:'02', label:'新ID', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x6202', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]),
  MenuDef(code:'024', label:'駅名一覧印刷',    instruction:'実行ボタンを押してください', memoryBaseAddress:'0x6300', fields:[FieldDef(num:'01', label:'部数', defaultValue:'1', type:FieldType.numeric, memoryAddress:'0x6300', memorySize:1, range:FieldRange(min:'1',max:'99',description:'印刷部数'), format:FieldFormat.dec(1,99))]),
  MenuDef(code:'025', label:'駅順コード設定',  instruction:'入力後実行してください',    memoryBaseAddress:'0x6400', fields:[FieldDef(num:'01', label:'開始コード', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x6400', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]),
]);
final _p3 = PageDef(label:'P3', menus:[
  MenuDef(code:'031', label:'社員マスタ設定', instruction:'入力後実行してください', memoryBaseAddress:'0x7000', fields:[FieldDef(num:'01', label:'社員コード', defaultValue:'000000', type:FieldType.hex, memoryAddress:'0x7000', memorySize:3, range:FieldRange(min:'000000',max:'FFFFFF',description:'社員コード'), format:FieldFormat.hexDword), FieldDef(num:'02', label:'権限レベル', defaultValue:'01', type:FieldType.hex, memoryAddress:'0x7003', memorySize:1, range:FieldRange(min:'01',max:'05',description:'1=一般〜5=最高'), format:FieldFormat.hexRng(0x01,0x05))]),
  MenuDef(code:'032', label:'権限ログ確認',   instruction:'確認してください',       memoryBaseAddress:'0x7100', fields:[FieldDef(num:'01', label:'社員No.', defaultValue:'000001', type:FieldType.readonly, memoryAddress:'0x7100', memorySize:3, memoryAccess:MemoryAccessType.readOnly)]),
  MenuDef(code:'033', label:'パスワード変更', instruction:'入力後実行してください', memoryBaseAddress:'0x7200', fields:[FieldDef(num:'01', label:'旧PW', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x7200', memorySize:2, range:_wordRange, format:FieldFormat.hexWord), FieldDef(num:'02', label:'新PW', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x7202', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]),
  MenuDef(code:'034', label:'社員名データロード',instruction:'実行ボタンを押してください', memoryBaseAddress:'0x7300', fields:[FieldDef(num:'01', label:'実行ファイル', defaultValue:'SUB-00280-01', type:FieldType.readonly, memoryAddress:'0x7300', memorySize:12)]),
  MenuDef(code:'035', label:'勤務記録確認',   instruction:'確認してください', memoryBaseAddress:'0x7400', fields:[FieldDef(num:'01', label:'日付', defaultValue:'2027.04.08', type:FieldType.readonly, memoryAddress:'0x7400', memorySize:8, memoryAccess:MemoryAccessType.readOnly)]),
]);
final _p4  = PageDef(label:'P4',  menus:[MenuDef(code:'041', label:'バス路線マスタ', instruction:'入力後実行してください', memoryBaseAddress:'0x8000', fields:[FieldDef(num:'01', label:'路線コード', defaultValue:'0001', type:FieldType.hex, memoryAddress:'0x8000', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]), MenuDef(code:'042', label:'バス停設定', instruction:'入力後実行してください', memoryBaseAddress:'0x8100', fields:[FieldDef(num:'01', label:'停留所コード', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x8100', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]), MenuDef(code:'043', label:'バス会社設定', instruction:'入力後実行してください', memoryBaseAddress:'0x8200', fields:[FieldDef(num:'01', label:'会社コード', defaultValue:'01', type:FieldType.hex, memoryAddress:'0x8200', memorySize:1, range:_byteRange, format:FieldFormat.hexByte)])]);
final _p5  = PageDef(label:'P5',  menus:[MenuDef(code:'051', label:'料金マスタ設定', instruction:'入力後実行してください', memoryBaseAddress:'0x9000', fields:[FieldDef(num:'01', label:'種別コード', defaultValue:'01', type:FieldType.hex, memoryAddress:'0x9000', memorySize:1, range:_byteRange, format:FieldFormat.hexByte), FieldDef(num:'02', label:'金額', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0x9001', memorySize:2, unit:'円', range:FieldRange(min:'0000',max:'9999',description:'金額'), format:FieldFormat.hexWord)]), MenuDef(code:'052', label:'割引設定', instruction:'入力後実行してください', memoryBaseAddress:'0x9100', fields:[FieldDef(num:'01', label:'割引率', defaultValue:'0', type:FieldType.numeric, memoryAddress:'0x9100', memorySize:1, unit:'%', range:FieldRange(min:'0',max:'99',description:'割引率'), format:FieldFormat.dec(0,99))])]);
final _p6  = PageDef(label:'P6',  menus:[MenuDef(code:'061', label:'マスタ初期化', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xA000', fields:[FieldDef(num:'01', label:'確認コード', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0xA000', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)]), MenuDef(code:'062', label:'マスタバックアップ', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xA100', fields:[FieldDef(num:'01', label:'出力先', defaultValue:r'C:\BACKUP', type:FieldType.text, memoryAddress:'0xA100', memorySize:32)])]);
final _p7  = PageDef(label:'P7',  menus:[MenuDef(code:'071', label:'ソフトバージョン表示', instruction:'確認してください', memoryBaseAddress:'0xB000', fields:[FieldDef(num:'01', label:'バージョン', defaultValue:'V2.10', type:FieldType.readonly, memoryAddress:'0xB000', memorySize:8, memoryAccess:MemoryAccessType.readOnly), FieldDef(num:'02', label:'ビルド', defaultValue:'20270401', type:FieldType.readonly, memoryAddress:'0xB008', memorySize:8, memoryAccess:MemoryAccessType.readOnly)]), MenuDef(code:'072', label:'バージョンアップ', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xB100', fields:[FieldDef(num:'01', label:'適用ファイル', defaultValue:r'C:\UPDATE', type:FieldType.text, memoryAddress:'0xB100', memorySize:32)])]);
final _p8  = PageDef(label:'P8',  menus:[MenuDef(code:'081', label:'障害ログ表示', instruction:'確認してください', memoryBaseAddress:'0xC000', fields:[FieldDef(num:'01', label:'表示件数', defaultValue:'20', type:FieldType.numeric, memoryAddress:'0xC000', memorySize:1, range:FieldRange(min:'1',max:'50',description:'表示件数'), format:FieldFormat.dec(1,50)), FieldDef(num:'02', label:'フィルタ', defaultValue:'00', type:FieldType.hex, memoryAddress:'0xC001', memorySize:1, range:_byteRange, format:FieldFormat.hexByte)]), MenuDef(code:'082', label:'障害ログクリア', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xC100', fields:[FieldDef(num:'01', label:'確認コード', defaultValue:'0000', type:FieldType.hex, memoryAddress:'0xC100', memorySize:2, range:_wordRange, format:FieldFormat.hexWord)])]);
final _p9  = PageDef(label:'P9',  menus:[MenuDef(code:'091', label:'ネット接続確認', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xD000', fields:[FieldDef(num:'01', label:'接続先IP', defaultValue:'192.168.010.001', type:FieldType.numeric, memoryAddress:'0xD000', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress)]), MenuDef(code:'092', label:'通信速度測定', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xD100', fields:[FieldDef(num:'01', label:'測定回数', defaultValue:'5', type:FieldType.numeric, memoryAddress:'0xD100', memorySize:1, range:FieldRange(min:'1',max:'10',description:'測定回数'), format:FieldFormat.dec(1,10))]), MenuDef(code:'093', label:'DNS設定', instruction:'入力後実行してください', memoryBaseAddress:'0xD200', fields:[FieldDef(num:'01', label:'DNS1', defaultValue:'8.8.8.8', type:FieldType.numeric, memoryAddress:'0xD200', memorySize:4, range:_ipRange, format:FieldFormat.ipAddress)])]);
final _p10 = PageDef(label:'P10', menus:[MenuDef(code:'101', label:'フルバックアップ', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xE000', fields:[FieldDef(num:'01', label:'出力先', defaultValue:r'C:\BACKUP', type:FieldType.text, memoryAddress:'0xE000', memorySize:32)]), MenuDef(code:'102', label:'差分バックアップ', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xE100', fields:[FieldDef(num:'01', label:'出力先', defaultValue:r'C:\BACKUP\DIFF', type:FieldType.text, memoryAddress:'0xE100', memorySize:32)]), MenuDef(code:'103', label:'リストア', instruction:'実行ボタンを押してください', memoryBaseAddress:'0xE200', fields:[FieldDef(num:'01', label:'入力元', defaultValue:r'C:\BACKUP', type:FieldType.text, memoryAddress:'0xE200', memorySize:32)]), MenuDef(code:'104', label:'バックアップ確認', instruction:'確認してください', memoryBaseAddress:'0xE300', fields:[FieldDef(num:'01', label:'最終日時', defaultValue:'2027.04.08 18:00', type:FieldType.readonly, memoryAddress:'0xE300', memorySize:16, memoryAccess:MemoryAccessType.readOnly)])]);
