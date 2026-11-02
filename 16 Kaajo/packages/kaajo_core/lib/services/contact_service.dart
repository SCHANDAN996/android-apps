import 'package:url_launcher/url_launcher.dart';

import '../content/catalog.dart';
import '../content/config.dart';
import '../models/booking.dart';
import '../models/complaint.dart';
import '../models/profiles.dart';
import '../utils/format.dart';

/// WhatsApp और कॉल खोलना, और भेजे जाने वाले मैसेज बनाना।
class ContactService {
  ContactService._();

  /// हमारे WhatsApp पर मैसेज खोलता है। खुल गया तो true।
  static Future<bool> whatsApp(String message, {String? toNumber}) async {
    final number = (toNumber ?? AppConfig.businessWhatsApp).replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// फ़ोन डायलर खोलता है।
  static Future<bool> call([String? number]) async {
    final uri = Uri(scheme: 'tel', path: number ?? AppConfig.businessPhone);
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  /// घर वाले की बुकिंग का मैसेज।
  static String bookingMessage(Booking b) {
    final lines = <String>[
      '*नई बुकिंग: ${b.serviceTitle}*',
      'बुकिंग नंबर: ${b.id}',
      '',
      'नाम: ${b.customerName}',
      'मोबाइल: ${b.mobile}',
      'पता: ${b.address}',
      if (b.landmark.isNotEmpty) 'लैंडमार्क: ${b.landmark}',
      'इलाका: ${b.area}',
      '',
      'सिस्टम: ${Catalog.kwLabel(b.systemKw)}',
      if (b.problem.isNotEmpty) 'दिक्कत: ${b.problem}',
      if (b.installerVendor.isNotEmpty) 'किसने लगाया: ${b.installerVendor}',
      'तारीख: ${hindiDate(b.date)}',
      'समय: ${b.timeSlot}',
      if (b.note.isNotEmpty) 'नोट: ${b.note}',
      '',
      'अनुमानित रेट: ${rupees(b.estimatedPrice)}',
      '(${AppConfig.appName} ऐप से भेजा गया)',
    ];
    return lines.join('\n');
  }

  /// वेंडर की शिकायत का मैसेज।
  static String complaintMessage(VendorComplaint c, VendorProfile v) {
    final lines = <String>[
      c.urgent ? '*जल्दी: शिकायत (48 घंटे)*' : '*नई शिकायत*',
      'शिकायत नंबर: ${c.id}',
      '',
      'वेंडर: ${v.firmName}',
      if (v.contactPerson.isNotEmpty) 'संपर्क: ${v.contactPerson}',
      'वेंडर मोबाइल: ${v.mobile}',
      '',
      'ग्राहक: ${c.customerName}',
      'ग्राहक मोबाइल: ${c.customerMobile}',
      'पता: ${c.address}',
      'इलाका: ${c.area}',
      'सिस्टम: ${Catalog.kwLabel(c.systemKw)}',
      'दिक्कत: ${c.problem}',
      'शिकायत की तारीख: ${hindiDate(c.complaintDate)}',
      if (c.portalComplaintId.isNotEmpty) 'पोर्टल शिकायत नंबर: ${c.portalComplaintId}',
      if (c.note.isNotEmpty) 'नोट: ${c.note}',
      '',
      '(${AppConfig.partnerAppName} ऐप से भेजा गया)',
    ];
    return lines.join('\n');
  }

  /// "जल्द आ रहा है" वाली सेवा में रुचि का मैसेज।
  static String interestMessage(String serviceTitle) =>
      'नमस्ते, मुझे "$serviceTitle" सेवा चाहिए। शुरू हो तो बताइए।\n(${AppConfig.appName} ऐप से)';

  /// किसी बुकिंग या शिकायत के बारे में पूछने का मैसेज।
  static String followUpMessage(String id) =>
      'नमस्ते, मेरी बुकिंग/शिकायत $id के बारे में जानकारी चाहिए।';

  /// वेंडर का मुफ़्त पायलट के बारे में पूछना।
  static String pilotMessage(VendorProfile v) =>
      'नमस्ते, मैं ${v.firmName.isEmpty ? 'एक सोलर वेंडर' : v.firmName} से। '
      'आपके मेंटेनेंस और शिकायत सर्विस के मुफ़्त पायलट के बारे में बात करनी है।\n'
      '(${AppConfig.partnerAppName} ऐप से)';
}
