import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// 印刷項目クラス
class PrintTicketContent {
  const PrintTicketContent({
    required this.key,
    required this.value,
    // keyとvalueで折り返すか
    this.hasBreak = false,
  });

  final String key;
  final String value;
  final bool hasBreak;
}

// 券情報を印刷する用のクラス
class CardInfoPrint {
  // 印刷する
  Future<void> printDocument({
    required String title,
    required List<PrintTicketContent> contents,
  }) async {
    final japaneseFont = await _loadJapaneseFont();
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: japaneseFont));
    // PDF作成
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: pw.EdgeInsets.symmetric(horizontal: 15.0),
        build: (pw.Context context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(fontSize: 9.5),
            child: pw.Padding(
              padding: pw.EdgeInsets.only(right: 20.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    margin: pw.EdgeInsets.only(bottom: 10.0),
                    alignment: pw.Alignment.center,
                    child: pw.Text(title),
                  ), // pw.Container
                  ..._getReceiptContents(contents),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(top: 8),
                    child: pw.Text('.', style: pw.TextStyle(fontSize: 5)),
                  ), // pw.Padding
                ],
              ), // pw.Column
            ), // pw.Padding
          ); // pw.DefaultTextStyle
        },
      ), // pw.Page
    );
    // プリンター一覧を取得してデフォルトに設定されたプリンタで印刷する
    List<Printer> printers = await Printing.listPrinters();
    final printer = printers.firstWhere((p) => p.isDefault);
    await Printing.directPrintPdf(
      printer: Printer(url: printer.url),
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // PDFを印刷する
  Future<void> printPdfDocument({required Uint8List pdfData}) async {
    // プリンター一覧を取得してデフォルトに設定されたプリンタで印刷する
    List<Printer> printers = await Printing.listPrinters();
    final printer = printers.firstWhere((p) => p.isDefault);
    await Printing.directPrintPdf(
      printer: Printer(url: printer.url),
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  // 印刷するレシートの中身を取得する
  List<pw.Widget> _getReceiptContents(List<PrintTicketContent> contents) {
    final result = <pw.Widget>[];
    for (var content in contents) {
      // 折り返しあり
      if (content.hasBreak) {
        result.add(pw.Text(content.key));
        result.add(pw.Text('　　　${content.value}'));
      }
      // 折り返しなし
      else {
        result.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text(content.key), pw.Text(content.value)],
          ), // pw.Row
        );
      }
    }
    return result;
  }

  // フォント情報を取得する
  Future<pw.Font> _loadJapaneseFont() async {
    final fontData = await rootBundle.load(
      'assets/font/M_PLUS_Rounded_1c/MPLUSRounded1c-Regular.ttf',
    );
    return pw.Font.ttf(fontData);
  }
}
