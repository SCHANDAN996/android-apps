import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';

/// तालिका की एक पंक्ति — तारीख़-वार (सुबह/शाम) या ग्राहक-वार, दोनों इसी से बनते हैं।
class BillRow {
  final String label; // तारीख़ या ग्राहक का नाम
  final List<String> cells; // बाक़ी खाने
  const BillRow(this.label, this.cells);
}

/// एक बिल/रिपोर्ट का पूरा विवरण।
class BillData {
  final String title; // प्रो किसान
  final String subtitle; // दूध का हिसाब / बिल
  final String periodName; // जुलाई 2026
  final String? customerLine; // ग्राहक का नाम/फ़ोन/पता (सिर्फ़ ग्राहक बिल में)
  final List<({String label, String value})> summary;
  final List<String> columnLabels; // पहला खाना = label वाला
  final List<BillRow> rows;
  final BillRow? totalRow;
  final bool showSignature;
  final String fileName;

  const BillData({
    required this.title,
    required this.subtitle,
    required this.periodName,
    required this.summary,
    required this.columnLabels,
    required this.rows,
    required this.fileName,
    this.customerLine,
    this.totalRow,
    this.showSignature = false,
  });
}

/// बिल की झलक + PDF शेयर।
///
/// ⚠️ यहाँ PDF **Flutter के अपने text rendering से** बनता है (widget → तस्वीर →
/// PDF), न कि `pdf` package के text से और न ही `Printing.convertHtml` से।
/// वजह:
///  • `pdf` package जटिल लिपियाँ (देवनागरी की मात्राएँ, तमिल/बांग्ला के
///    संयुक्ताक्षर) सही आकार में नहीं जोड़ पाता — अक्षर टूटे दिखते थे।
///  • `Printing.convertHtml` Android के WebView के जवाब का इंतज़ार करता है;
///    जवाब न आए तो वह **हमेशा के लिए अटक जाता है** — न error, न फ़ाइल।
///    इसी वजह से "PDF बनता ही नहीं" वाली शिकायत आई थी।
/// Flutter ख़ुद हर भारतीय भाषा सही जोड़ता है, इसलिए जो स्क्रीन पर दिखता है
/// वही हूबहू PDF में जाता है — दसों भाषाओं में।
class BillPreviewScreen extends StatefulWidget {
  final BillData data;
  const BillPreviewScreen({super.key, required this.data});

  @override
  State<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends State<BillPreviewScreen> {
  /// हर पन्ने की अपनी key — capture करते समय चाहिए
  final List<GlobalKey> _pageKeys = [];
  bool _busy = false;

  /// एक पन्ने पर ज़्यादा से ज़्यादा इतनी पंक्तियाँ (A4 में आराम से आ जाती हैं)
  static const int _rowsPerPage = 20;

  List<List<BillRow>> get _pages {
    final rows = widget.data.rows;
    if (rows.isEmpty) return [[]];
    final out = <List<BillRow>>[];
    for (var i = 0; i < rows.length; i += _rowsPerPage) {
      out.add(rows.sublist(
          i, i + _rowsPerPage > rows.length ? rows.length : i + _rowsPerPage));
    }
    return out;
  }

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    while (_pageKeys.length < pages.length) {
      _pageKeys.add(GlobalKey());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        title: Text(widget.data.subtitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Print',
            onPressed: _busy ? null : () => _makePdf(share: false),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        itemCount: pages.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RepaintBoundary(
            key: _pageKeys[i],
            child: _BillPage(
              data: widget.data,
              rows: pages[i],
              pageNo: i + 1,
              totalPages: pages.length,
              isLast: i == pages.length - 1,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : () => _makePdf(share: true),
        backgroundColor: DairyTheme.primaryTeal,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.share_rounded, color: Colors.white),
        label: Text(_t('shareText'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// हर पन्ने की तस्वीर लो → PDF में डालो → शेयर/प्रिंट करो।
  Future<void> _makePdf({required bool share}) async {
    setState(() => _busy = true);
    try {
      final doc = pw.Document();

      for (final key in _pageKeys) {
        final boundary = key.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary == null) continue;
        // 2.6x — कागज़ पर भी अक्षर साफ़ रहें, फ़ाइल भी भारी न हो
        final image = await boundary.toImage(pixelRatio: 2.6);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        if (byteData == null) continue;
        final bytes = byteData.buffer.asUint8List();
        final mem = pw.MemoryImage(bytes);
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(18),
            build: (_) => pw.Center(child: pw.Image(mem, fit: pw.BoxFit.contain)),
          ),
        );
      }

      final Uint8List out = await doc.save();
      if (share) {
        await Printing.sharePdf(bytes: out, filename: widget.data.fileName);
      } else {
        await Printing.layoutPdf(onLayout: (_) async => out);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// A4 अनुपात का एक सफ़ेद पन्ना — यही तस्वीर बनकर PDF में जाता है।
class _BillPage extends StatelessWidget {
  final BillData data;
  final List<BillRow> rows;
  final int pageNo;
  final int totalPages;
  final bool isLast;

  const _BillPage({
    required this.data,
    required this.rows,
    required this.pageNo,
    required this.totalPages,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // बिल हमेशा हल्के काग़ज़ जैसा — dark mode में भी (छपने के लिए यही सही)
    return Container(
      color: Colors.white,
      child: AspectRatio(
        aspectRatio: 1 / 1.414, // A4
        child: DefaultTextStyle(
          style: const TextStyle(
              fontFamily: 'Mukta', color: Color(0xFF1B2E1B), fontSize: 11),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                if (data.customerLine != null && pageNo == 1) ...[
                  const SizedBox(height: 10),
                  _customerBox(),
                ],
                if (pageNo == 1) ...[
                  const SizedBox(height: 10),
                  _summaryStrip(),
                ],
                const SizedBox(height: 10),
                _table(),
                const Spacer(),
                if (isLast && data.showSignature) _signatures(context),
                const SizedBox(height: 6),
                _footer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset('assets/icon/app_icon.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.agriculture_rounded,
                    color: DairyTheme.primaryTeal)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: DairyTheme.secondaryTeal)),
                Text(data.subtitle,
                    style: const TextStyle(
                        fontSize: 10.5, color: Color(0xFF666666))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DairyTheme.primaryTeal),
            ),
            child: Text(data.periodName,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: DairyTheme.secondaryTeal)),
          ),
        ],
      );

  Widget _customerBox() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          border: Border.all(color: DairyTheme.primaryTeal),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(data.customerLine!,
            style: const TextStyle(fontSize: 11.5, height: 1.35)),
      );

  Widget _summaryStrip() => Row(
        children: [
          for (final s in data.summary) ...[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(s.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF666666))),
                    const SizedBox(height: 2),
                    Text(s.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ],
      );

  Widget _table() {
    const border = BorderSide(color: Color(0xFFBDBDBD), width: 0.6);
    final labels = data.columnLabels;

    TableRow head() => TableRow(
          decoration: const BoxDecoration(color: DairyTheme.primaryTeal),
          children: [
            for (final l in labels)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Text(l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
          ],
        );

    TableRow body(BillRow r, int i, {bool total = false}) => TableRow(
          decoration: BoxDecoration(
            color: total
                ? const Color(0xFFE8F5E9)
                : (i.isEven ? Colors.white : const Color(0xFFF7FBF7)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: Text(r.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          total ? FontWeight.w800 : FontWeight.w600)),
            ),
            for (final c in r.cells)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                child: Text(c,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            total ? FontWeight.w800 : FontWeight.normal)),
              ),
          ],
        );

    return Table(
      border: const TableBorder(
        top: border,
        bottom: border,
        left: border,
        right: border,
        horizontalInside: border,
        verticalInside: border,
      ),
      columnWidths: {
        0: const FlexColumnWidth(1.5),
        for (int i = 1; i < labels.length; i++) i: const FlexColumnWidth(1),
      },
      children: [
        head(),
        for (int i = 0; i < rows.length; i++) body(rows[i], i),
        if (isLast && data.totalRow != null) body(data.totalRow!, 0, total: true),
      ],
    );
  }

  Widget _signatures(BuildContext context) {
    String t(String k) => AppLocalizations.get(context, k);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final k in ['pdfSignCustomer', 'pdfSignDairy'])
            Column(
              children: [
                Container(
                    width: 120, height: 0.8, color: const Color(0xFF555555)),
                const SizedBox(height: 3),
                Text(t(k), style: const TextStyle(fontSize: 9.5)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final ts = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    return Column(
      children: [
        Container(height: 0.6, color: const Color(0xFFBDBDBD)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.get(context, 'pdfFooterNote'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 8.5, color: Color(0xFF777777)),
              ),
            ),
            Text('$ts   ·   $pageNo/$totalPages',
                style:
                    const TextStyle(fontSize: 8.5, color: Color(0xFF777777))),
          ],
        ),
      ],
    );
  }
}
