/// 表示データ応答 (0x1281) データモデル
/// 53フィールド + COMMON
class DisplayData {
  // COMMON
  final bool result;
  final int errCode;

  // ボタン制御
  final bool enterBtnEnabled;
  final bool exitBtnEnabled;
  final bool adjustBtnEnabled;
  final bool haisaCancelBtnEnabled;
  final bool enterCancelBtnEnabled;

  // QR情報
  final String? qrNumber;
  final int? qrValidStatus;
  final int? qrPublishStatus;
  final int? useStatus;
  final int? gateStatus;
  final int? mediaType;

  // 有効開始日
  final int? startDateY;
  final int? startDateM;
  final int? startDateD;

  // 有効終了日
  final int? expiryDateY;
  final int? expiryDateM;
  final int? expiryDateD;

  // 駅情報
  final String? startStation;
  final int? startZone;
  final String? transferStation;
  final int? transferZone;

  // 券種
  final int? ticketType;
  final int? ticketType2;
  final int? ticket2Bit5;
  final int? ticket2Bit4;
  final int? ticket2Bit1;
  final int? ticketType3;

  // 入出場情報
  final int? entryStatus;
  final String? boardingStation;
  final int? rideDateM;
  final int? rideDateD;
  final int? rideTimeH;
  final int? rideTimeM;

  // 経由
  final String? route1;
  final String? route2;
  final String? route3;
  final String? route4;
  final String? route5;
  final String? route6;
  final String? route7;
  final String? route8;

  // その他
  final String? specialTicketName;
  final int? passengerType;
  final int? roundTripFlag;
  final int? freeSection;
  final String? freeCode;
  final int? adjustAmount;

  // 経路候補 (精算処理用)
  final int? routeCand1;
  final int? routeCand2;
  final int? routeCand3;
  final int? routeCand4;
  final int? routeCand5;
  final int? routeCand6;

  const DisplayData({
    required this.result,
    required this.errCode,
    required this.enterBtnEnabled,
    required this.exitBtnEnabled,
    required this.adjustBtnEnabled,
    required this.haisaCancelBtnEnabled,
    required this.enterCancelBtnEnabled,
    this.qrNumber,
    this.qrValidStatus,
    this.qrPublishStatus,
    this.useStatus,
    this.gateStatus,
    this.mediaType,
    this.startDateY,
    this.startDateM,
    this.startDateD,
    this.expiryDateY,
    this.expiryDateM,
    this.expiryDateD,
    this.startStation,
    this.startZone,
    this.transferStation,
    this.transferZone,
    this.ticketType,
    this.ticketType2,
    this.ticket2Bit5,
    this.ticket2Bit4,
    this.ticket2Bit1,
    this.ticketType3,
    this.entryStatus,
    this.boardingStation,
    this.rideDateM,
    this.rideDateD,
    this.rideTimeH,
    this.rideTimeM,
    this.route1,
    this.route2,
    this.route3,
    this.route4,
    this.route5,
    this.route6,
    this.route7,
    this.route8,
    this.specialTicketName,
    this.passengerType,
    this.roundTripFlag,
    this.freeSection,
    this.freeCode,
    this.adjustAmount,
    this.routeCand1,
    this.routeCand2,
    this.routeCand3,
    this.routeCand4,
    this.routeCand5,
    this.routeCand6,
  });

  factory DisplayData.fromJson(Map<String, dynamic> json) {
    final common = json['COMMON'] as Map<String, dynamic>? ?? {};
    final data = json['DATA'] as Map<String, dynamic>? ?? {};

    return DisplayData(
      result: common['RESULT'] as bool? ?? false,
      errCode: common['ERRCODE'] as int? ?? -1,
      enterBtnEnabled: data['ENTERBTNENABLED'] as bool? ?? false,
      exitBtnEnabled: data['EXITBTNENABLED'] as bool? ?? false,
      adjustBtnEnabled: data['ADJUSTBTNENABLED'] as bool? ?? false,
      haisaCancelBtnEnabled: data['HAISATUBTNENAABLED'] as bool? ?? false,
      enterCancelBtnEnabled: data['ENTERCANCELBTNENABLED'] as bool? ?? false,
      qrNumber: data['QRNUMBER'] as String?,
      qrValidStatus: data['QRVALIDSTATUS'] as int?,
      qrPublishStatus: data['QRPUBLISHSTATUS'] as int?,
      useStatus: data['USESTATUS'] as int?,
      gateStatus: data['GATESTATUS'] as int?,
      mediaType: data['MEDIATYPE'] as int?,
      startDateY: data['STARTDATEY'] as int?,
      startDateM: data['STARTDATEM'] as int?,
      startDateD: data['STARTDATED'] as int?,
      expiryDateY: data['EXPIRYDATEY'] as int?,
      expiryDateM: data['EXPIRYDATEM'] as int?,
      expiryDateD: data['EXPIRYDATED'] as int?,
      startStation: data['STARTSTATION'] as String?,
      startZone: data['STARTZONE'] as int?,
      transferStation: data['TRANSFERSTATION'] as String?,
      transferZone: data['TRANSFERZONE'] as int?,
      ticketType: data['TICKETTYPE'] as int?,
      ticketType2: data['TICKETTYPE2'] as int?,
      ticket2Bit5: data['TICKET2BIT5'] as int?,
      ticket2Bit4: data['TICKET2BIT4'] as int?,
      ticket2Bit1: data['TICKET2BIT1'] as int?,
      ticketType3: data['TICKETTYPE3'] as int?,
      entryStatus: data['ENTRYSTATUS'] as int?,
      boardingStation: data['BOARDINGSTATION'] as String?,
      rideDateM: data['RIDEDATEM'] as int?,
      rideDateD: data['RIDEDATED'] as int?,
      rideTimeH: data['RIDETIMEH'] as int?,
      rideTimeM: data['RIDETIMEM'] as int?,
      route1: data['ROUTE1'] as String?,
      route2: data['ROUTE2'] as String?,
      route3: data['ROUTE3'] as String?,
      route4: data['ROUTE4'] as String?,
      route5: data['ROUTE5'] as String?,
      route6: data['ROUTE6'] as String?,
      route7: data['ROUTE7'] as String?,
      route8: data['ROUTE8'] as String?,
      specialTicketName: data['SPECIALTICKETNAME'] as String?,
      passengerType: data['PASSENGERTYPE'] as int?,
      roundTripFlag: data['ROUNDTRIPFLAG'] as int?,
      freeSection: data['FREESECTION'] as int?,
      freeCode: data['FREECODE'] as String?,
      adjustAmount: data['ADJUSTAMOUNT'] as int?,
      routeCand1: data['ROUTECAND1'] as int?,
      routeCand2: data['ROUTECAND2'] as int?,
      routeCand3: data['ROUTECAND3'] as int?,
      routeCand4: data['ROUTECAND4'] as int?,
      routeCand5: data['ROUTECAND5'] as int?,
      routeCand6: data['ROUTECAND6'] as int?,
    );
  }

  /// 有効開始日フォーマット (MM/DD)
  String get startDateFormatted {
    if (startDateM == null || startDateD == null) return '';
    return '${startDateM!.toString().padLeft(2, '0')}/${startDateD!.toString().padLeft(2, '0')}';
  }

  /// 有効終了日フォーマット (MM/DD)
  String get expiryDateFormatted {
    if (expiryDateM == null || expiryDateD == null) return '';
    return '${expiryDateM!.toString().padLeft(2, '0')}/${expiryDateD!.toString().padLeft(2, '0')}';
  }

  /// 乗車月日フォーマット (MM/DD)
  String get rideDateFormatted {
    if (rideDateM == null || rideDateD == null) return '';
    return '${rideDateM!.toString().padLeft(2, '0')}/${rideDateD!.toString().padLeft(2, '0')}';
  }

  /// 乗車時刻フォーマット (HH:MM)
  String get rideTimeFormatted {
    if (rideTimeH == null || rideTimeM == null) return '';
    return '${rideTimeH!.toString().padLeft(2, '0')}:${rideTimeM!.toString().padLeft(2, '0')}';
  }

  /// 経路候補リスト (nullを除く)
  List<int> get routeCandidates {
    return [
      routeCand1,
      routeCand2,
      routeCand3,
      routeCand4,
      routeCand5,
      routeCand6,
    ].whereType<int>().toList();
  }
}
