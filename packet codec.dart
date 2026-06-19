import 'dart:convert';
import 'dart:typed_data';

/// コマンドID定義
/// 仕様書「東武QR窓処 画面⇔本体制御I/F」に基づく
class CommandId {
  // ── Server → Flutter ──────────────────────────────
  static const int initRequest = 0x0A81;           // 画面制御初期化要求
  static const int qrServerRefResponse = 0x1181;   // QRサーバ照会要求応答
  static const int displayDataResponse = 0x1281;   // 表示データ応答
  static const int loginResponse = 0xA181;         // ログイン要求応答
  static const int logoffResponse = 0xA281;        // ログオフ要求応答
  static const int connectionStatusNotify = 0xF181; // 接続状態変化通知
  static const int systemErrorNotify = 0xFA81;     // 本体制御異常通知
  static const int forceCancelNotify = 0xFB81;     // 業務強制取消通知

  // ── Flutter → Server ──────────────────────────────
  static const int initComplete = 0x0A01;          // 画面制御初期化完了通知
  static const int appExitRequest = 0x0F01;        // アプリケーション終了要求
  static const int qrServerRefRequest = 0x1101;    // QRサーバ照会要求
  static const int displayDataRequest = 0x1201;    // 表示データ要求
  static const int loginRequest = 0xA101;          // ログイン要求
  static const int logoffRequest = 0xA201;         // ログオフ要求
  static const int cancelRequest = 0xB101;         // 業務取消要求
}

/// TCPパケット
/// パケット構造:
///   [4 bytes データレングス (big-endian, unsigned)]
///   [2 bytes コマンドID    (big-endian, unsigned)]
///   [N bytes JSONデータ    (UTF-8)]
/// ※ データレングス = JSONデータのバイト数のみ（コマンドIDは含まない）
class TcpPacket {
  final int commandId;
  final Map<String, dynamic> json;

  const TcpPacket({required this.commandId, required this.json});

  /// パケットをバイト列にエンコード（Flutter → Server）
  static Uint8List encode({
    required int commandId,
    required Map<String, dynamic> json,
  }) {
    final jsonBytes = utf8.encode(jsonEncode(json));
    final length = jsonBytes.length;

    // ヘッダー6バイト + JSONバイト列
    final result = Uint8List(6 + length);
    final buffer = ByteData.sublistView(result);

    buffer.setUint32(0, length, Endian.big);      // 4 bytes データレングス
    buffer.setUint16(4, commandId, Endian.big);   // 2 bytes コマンドID
    result.setRange(6, 6 + length, jsonBytes);    // N bytes JSON

    return result;
  }

  /// バイト列からパケットをデコード（Server → Flutter）
  /// バッファにデータが足りない場合は null を返す
  static TcpPacket? decode(List<int> buffer) {
    // 最低6バイト必要（4 データレングス + 2 コマンドID）
    if (buffer.length < 6) return null;

    final byteData = ByteData.sublistView(Uint8List.fromList(buffer));

    // データレングス読み取り
    final length = byteData.getUint32(0, Endian.big);

    // 全データが揃っているか確認
    if (buffer.length < 6 + length) return null;

    // コマンドID読み取り（2バイト）
    final commandId = byteData.getUint16(4, Endian.big);

    // JSON読み取り
    final jsonBytes = buffer.sublist(6, 6 + length);
    final jsonStr = utf8.decode(jsonBytes);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return TcpPacket(commandId: commandId, json: json);
  }

  /// バッファ先頭のJSONバイト数を取得
  /// バッファ消費量計算に使用: consumed = 6 + getJsonLength(buffer)
  static int getJsonLength(List<int> buffer) {
    if (buffer.length < 4) return 0;
    final byteData = ByteData.sublistView(Uint8List.fromList(buffer));
    return byteData.getUint32(0, Endian.big);
  }
}
