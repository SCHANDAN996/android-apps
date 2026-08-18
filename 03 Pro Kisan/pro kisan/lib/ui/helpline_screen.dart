import 'package:flutter/material.dart';
import 'theme/dairy_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/link_service.dart';
// ignore_for_file: deprecated_member_use

/// ---------------------------------------------------------------------------
///  ज़रूरी हेल्पलाइन (Important Helplines Screen)
/// ---------------------------------------------------------------------------
class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  static const List<Map<String, String>> _helplines = [
    {
      'title': '🌾 किसान कॉल सेंटर (KCC)',
      'titleEn': '🌾 Kisan Call Centre (KCC)',
      'number': '18001801551',
      'purpose': 'कृषि वैज्ञानिकों से फसलों, खाद, रोग और कीटों के बारे में मुफ्त सलाह लें।',
      'purposeEn': 'Free advice from agri scientists on crops, fertilizer, disease and pests.',
      'time': '⏰ सुबह 6:00 बजे से रात 10:00 बजे तक (रोजाना)',
      'timeEn': '⏰ 6:00 AM to 10:00 PM (daily)',
      'icon': '🌱',
      'color': 'green',
    },
    {
      'title': '💳 पीएम-किसान हेल्पलाइन',
      'titleEn': '💳 PM-Kisan Helpline',
      'number': '155261',
      'purpose': 'प्रधानमंत्री किसान सम्मान निधि योजना की किश्त, स्टेटस और रजिस्ट्रेशन सहायता।',
      'purposeEn': 'Help with PM-Kisan installment, status and registration.',
      'time': '⏰ 24 घंटे उपलब्ध (टोल-फ्री)',
      'timeEn': '⏰ Available 24 hours (toll-free)',
      'icon': '💰',
      'color': 'orange',
    },
    {
      'title': '🐄 पशुपालन आपातकालीन चिकित्सा',
      'titleEn': '🐄 Animal Emergency (Ambulance)',
      'number': '1962',
      'purpose': 'पशुओं के बीमार होने पर एम्बुलेंस और डॉक्टर की सहायता प्राप्त करें।',
      'purposeEn': 'Get ambulance and vet help when your cattle fall ill.',
      'time': '⏰ 24 घंटे उपलब्ध',
      'timeEn': '⏰ Available 24 hours',
      'icon': '🚑',
      'color': 'red',
    },
    {
      'title': '🌧️ राष्ट्रीय मौसम पूर्वानुमान (IMD)',
      'titleEn': '🌧️ Weather Forecast (IMD)',
      'number': '18001801717',
      'purpose': 'मौसम विभाग से बारिश, आंधी, तापमान और कृषि-मौसम सलाह की जानकारी लें।',
      'purposeEn': 'Rain, storm, temperature and agro-weather advice from IMD.',
      'time': '⏰ सुबह 9:00 से शाम 6:00 तक',
      'timeEn': '⏰ 9:00 AM to 6:00 PM',
      'icon': '⛈️',
      'color': 'blue',
    },
    {
      'title': '🛡️ प्रधानमंत्री फसल बीमा योजना',
      'titleEn': '🛡️ PM Crop Insurance (PMFBY)',
      'number': '18001801551',
      'purpose': 'फसल नुकसान, ओलावृष्टि, या बाढ़ आने पर बीमा क्लेम की जानकारी और शिकायत।',
      'purposeEn': 'Insurance claim help for crop loss due to hail or flood.',
      'time': '⏰ सुबह 6:00 से रात 10:00 तक',
      'timeEn': '⏰ 6:00 AM to 10:00 PM',
      'icon': '🌾',
      'color': 'teal',
    },
    {
      'title': '🧪 खाद-उर्वरक शिकायत केंद्र',
      'titleEn': '🧪 Fertilizer Complaint Centre',
      'number': '1800115526',
      'purpose': 'नकली खाद, बीज या कीटनाशकों की बिक्री होने पर टोल-फ्री शिकायत दर्ज करें।',
      'purposeEn': 'Toll-free complaint against fake fertilizer, seed or pesticide.',
      'time': '⏰ सुबह 9:30 से शाम 5:30 तक',
      'timeEn': '⏰ 9:30 AM to 5:30 PM',
      'icon': '🧪',
      'color': 'deepPurple',
    },
  ];

  /// canLaunchUrl नहीं — Android 11+ पर वह false लौटाकर बटन को चुप कर देता है।
  /// यह StatelessWidget है इसलिए संदेश दिखाने को context बाहर से लेते हैं।
  Future<void> _makeCall(BuildContext context, String phone) =>
      LinkService.dial(context, phone,
          errorMsg: 'फ़ोन ऐप नहीं खुल सका — नंबर: $phone');

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(context, 'dashHelplines')),
        backgroundColor: DairyTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _helplines.length,
          itemBuilder: (context, index) {
            final h = _helplines[index];
            return _buildHelplineCard(context, h, isHi);
          },
        ),
      ),
    );
  }

  Widget _buildHelplineCard(BuildContext context, Map<String, String> h, bool isHi) {
    Color cardColor;
    switch (h['color']) {
      case 'green': cardColor = Colors.green; break;
      case 'orange': cardColor = Colors.orange.shade800; break;
      case 'red': cardColor = Colors.red.shade800; break;
      case 'blue': cardColor = Colors.blue.shade800; break;
      case 'teal': cardColor = Colors.teal; break;
      default: cardColor = Colors.deepPurple.shade600;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(h['icon'] ?? '📞', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    (isHi ? h['title'] : h['titleEn']) ?? h['title'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              (isHi ? h['purpose'] : h['purposeEn']) ?? h['purpose'] ?? '',
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              (isHi ? h['time'] : h['timeEn']) ?? h['time'] ?? '',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _makeCall(context, h['number'] ?? ''),
                icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
                label: Text(
                  '${AppLocalizations.get(context, 'callBtn')}: ${h['number']}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
