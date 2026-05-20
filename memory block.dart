class MemoryBlock {
  final int baseAddress;
  final List<int> bytes;
  final DateTime readAt;
  const MemoryBlock({required this.baseAddress, required this.bytes, required this.readAt});
  List<int> read(int offset, int length) {
    if (offset + length > bytes.length) return List.filled(length, 0);
    return bytes.sublist(offset, offset + length);
  }
  int readByte(int offset) => offset < bytes.length ? bytes[offset] : 0;
  int readWord(int offset) => offset + 1 < bytes.length ? (bytes[offset] << 8) | bytes[offset + 1] : 0;
  String get baseAddressHex => '0x${baseAddress.toRadixString(16).toUpperCase().padLeft(4, '0')}';
}

class MemoryWriteRequest {
  final int address;
  final List<int> bytes;
  final String fieldLabel;
  final String menuCode;
  const MemoryWriteRequest({required this.address, required this.bytes, required this.fieldLabel, required this.menuCode});
  String get addressHex => '0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')}';
}

/// All known memory addresses — backend fills in real values
class MemoryMap {
  MemoryMap._();
  // PAGE 1
  static const int errorInfoBase     = 0x1000;
  static const int constantsBase     = 0x2000;
  static const int corner            = 0x2000;
  static const int unitNumber        = 0x2001;
  static const int autoSet           = 0x2002;
  static const int operatorCode      = 0x2003;
  static const int externalStaCode   = 0x2006;
  static const int upperConnection   = 0x2009;
  static const int magneticUnit      = 0x200D;
  static const int icUnit            = 0x200E;
  static const int restModeFlag      = 0x200F;
  static const int planTicketFlag    = 0x2010;
  static const int magIssuableFlag   = 0x2012;
  static const int icWindowFlag      = 0x2013;
  static const int icFixedIssueFlag  = 0x2014;
  static const int icFixedLimitFlag  = 0x2015;
  static const int icSeasonNewFlag   = 0x2016;
  static const int icSeasonContFlag  = 0x2017;
  static const int magSeasonNewFlag  = 0x2018;
  static const int magSeasonContFlag = 0x2019;
  static const int magSeasonSpecFlag = 0x201A;
  static const int ipBase            = 0x3000;
  static const int lan1IpAddr        = 0x3000;
  static const int lan1NetMask       = 0x3004;
  static const int lan1Gateway       = 0x3008;
  static const int lan2IpAddr        = 0x300C;
  static const int lan2NetMask       = 0x3010;
  static const int lan2Gateway       = 0x3014;
  static const int upperIp           = 0x3018;
  static const int distServerIp      = 0x301C;
  static const int distServerSocket  = 0x3020;
  static const int distServerFtp     = 0x3022;
}
