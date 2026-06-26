import '../secondary_tab_content_core.dart';
import '../service/csv_service.dart';
import 'display_data.dart';

/// DisplayData → CardInfoEnum値マッパー
/// 0x1281のデータをUI表示用に変換する
class DisplayDataMapper {
  final DisplayData data;
  final CsvService _csv = CsvService();

  DisplayDataMapper(this.data);

  /// CardInfoEnumの値を取得
  String getValue(CardInfoEnum field) {
    switch (field) {
      case CardInfoEnum.qrYukoMukoStatus:
        return _csv.lookup('QRVALIDSTATUS', data.qrValidStatus);
      case CardInfoEnum.qrHakkouStatus:
        return _csv.lookup('QRPUBLISHSTATUS', data.qrPublishStatus);
      case CardInfoEnum.siyouStatus:
        return _csv.lookup('USESTATUS', data.useStatus);
      case CardInfoEnum.nyuusyutuzyouStatus:
        return _csv.lookup('GATESTATUS', data.gateStatus);
      case CardInfoEnum.baitaiSyubetu:
        return _csv.lookup('MEDIATYPE', data.mediaType);
      case CardInfoEnum.yukoKaisibi:
        return data.startDateFormatted;
      case CardInfoEnum.yukoSyuryoubi:
        return data.expiryDateFormatted;
      case CardInfoEnum.hatueki:
        return data.startStation ?? '';
      case CardInfoEnum.tyakueki:
        return data.transferStation ?? '';
      case CardInfoEnum.hatuekiKusu:
        return data.startZone?.toString() ?? '';
      case CardInfoEnum.renrakueki:
        return data.transferStation ?? '';
      case CardInfoEnum.renrakuekiKusu:
        return data.transferZone?.toString() ?? '';
      case CardInfoEnum.zyosyaeki:
        return data.boardingStation ?? '';
      case CardInfoEnum.nyusyutuzyoBit:
        return _csv.lookup('ENTRYSTATUS', data.entryStatus);
      case CardInfoEnum.zyosyaTukihi:
        return data.rideDateFormatted;
      case CardInfoEnum.zyosyaZikoku:
        return data.rideTimeFormatted;
      case CardInfoEnum.keiyu1:
        return data.route1 ?? '';
      case CardInfoEnum.keiyu2:
        return data.route2 ?? '';
      case CardInfoEnum.keiyu3:
        return data.route3 ?? '';
      case CardInfoEnum.keiyu4:
        return data.route4 ?? '';
      case CardInfoEnum.kensyu:
        return _csv.lookup('TICKETTYPE', data.ticketType);
      case CardInfoEnum.kensyu2:
        return data.ticketType2?.toString() ?? '';
      case CardInfoEnum.kensyu2Detail1:
        return _csv.lookup('TICKET2BIT5', data.ticket2Bit5);
      case CardInfoEnum.kensyu2Detail2:
        return [
          _csv.lookup('TICKET2BIT4', data.ticket2Bit4),
          _csv.lookup('TICKET2BIT1', data.ticket2Bit1),
        ].where((s) => s.isNotEmpty).join('、');
      case CardInfoEnum.huricode:
        return data.freeCode ?? '';
      case CardInfoEnum.empty:
        return '';
    }
  }
}
