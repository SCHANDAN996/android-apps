import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class WhatsAppService {
  WhatsAppService._();

  /// Direct WhatsApp send with phone & text message.
  /// Uses native `whatsapp://` protocol first for 1-click open,
  /// then web API fallback, then system Share fallback.
  static Future<void> sendMessage({String? phone, required String text}) async {
    final cleanText = text.trim();
    final encodedText = Uri.encodeComponent(cleanText);

    if (phone != null && phone.isNotEmpty) {
      final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final fullPhone = cleanedPhone.length == 10 ? '91$cleanedPhone' : cleanedPhone;

      // ⚠️ canLaunchUrl की जाँच हटा दी गई है। Android 11+ पर वह अक्सर false
      // लौटाती थी, जिससे तीनों कोशिशें छूटकर सीधे सामान्य share dialog खुल
      // जाता था — WhatsApp कभी खुलता ही नहीं था। अब हर तरीक़ा असल में आज़माते
      // हैं और नाकाम होने पर ही अगला।

      // 1) WhatsApp ऐप सीधे
      if (await _tryLaunch(
          'whatsapp://send?phone=$fullPhone&text=$encodedText')) {
        return;
      }

      // 2) WhatsApp का वेब लिंक
      if (await _tryLaunch(
          'https://api.whatsapp.com/send?phone=$fullPhone&text=$encodedText')) {
        return;
      }
    }

    // 3) बिना नंबर के WhatsApp शेयर
    if (await _tryLaunch('whatsapp://send?text=$encodedText')) return;

    // Ultimate fallback to general share dialog
    await Share.share(cleanText);
  }

  /// एक URL खोलने की कोशिश — चला तो true, नहीं तो false (अपवाद निगल जाता है)।
  static Future<bool> _tryLaunch(String url) async {
    try {
      return await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
