import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// बाहर की चीज़ें खोलने का एक ही भरोसेमंद रास्ता — वेबसाइट, ईमेल, फ़ोन, शेयर।
///
/// ⚠️ यहाँ `canLaunchUrl()` जान-बूझकर इस्तेमाल नहीं किया गया।
/// Android 11+ पर वह तभी सच लौटाता है जब manifest के `<queries>` में उस scheme
/// की घोषणा हो, और थोड़ी सी चूक पर भी हमेशा false देता है — जिससे ऐप चुपचाप
/// कुछ नहीं करता और उपयोगकर्ता को लगता है बटन टूटा है।
/// सही तरीक़ा: सीधे launch करो, न चले तो पकड़ो और साफ़ संदेश दिखाओ।
class LinkService {
  /// वेबसाइट खोलो (ब्राउज़र में)।
  static Future<bool> openUrl(BuildContext context, String url,
      {String? errorMsg}) async {
    if (url.trim().isEmpty) return false;
    var fixed = url.trim();
    // कुछ feed बिना scheme के लिंक देते हैं
    if (!fixed.startsWith('http://') && !fixed.startsWith('https://')) {
      fixed = 'https://$fixed';
    }
    return _try(
      context,
      Uri.parse(fixed),
      LaunchMode.externalApplication,
      errorMsg ?? 'लिंक नहीं खुल सका',
    );
  }

  /// ईमेल ऐप खोलो (विषय के साथ)।
  static Future<bool> sendEmail(
    BuildContext context, {
    required String to,
    String subject = '',
    String body = '',
    String? errorMsg,
  }) async {
    // mailto में query को Uri(queryParameters:) से मत बनाओ — वह space को '+'
    // कर देता है और कई ईमेल ऐप उसे ठीक से नहीं पढ़ते। खुद encode करना सही है।
    final q = <String>[
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');
    final uri = Uri.parse('mailto:$to${q.isEmpty ? '' : '?$q'}');

    return _try(
      context,
      uri,
      LaunchMode.externalApplication,
      errorMsg ?? 'ईमेल ऐप नहीं मिला। पता: $to',
    );
  }

  /// डायलर खोलो।
  static Future<bool> dial(BuildContext context, String phone,
      {String? errorMsg}) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return false;
    return _try(
      context,
      Uri.parse('tel:$clean'),
      LaunchMode.externalApplication,
      errorMsg ?? 'फ़ोन ऐप नहीं खुल सका',
    );
  }

  static Future<bool> _try(BuildContext context, Uri uri, LaunchMode mode,
      String errorMsg) async {
    try {
      final ok = await launchUrl(uri, mode: mode);
      if (!ok && context.mounted) _snack(context, errorMsg);
      return ok;
    } catch (_) {
      // कोई ऐप ही न हो, या OS मना कर दे
      if (context.mounted) _snack(context, errorMsg);
      return false;
    }
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
    );
  }
}
