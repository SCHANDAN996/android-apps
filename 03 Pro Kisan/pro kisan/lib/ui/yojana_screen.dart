import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/dairy_theme.dart';
import '../l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use

/// ---------------------------------------------------------------------------
///  सरकारी योजनाएं — Next-Level Interactive Guide
/// ---------------------------------------------------------------------------
class YojanaScreen extends StatefulWidget {
  const YojanaScreen({super.key});

  @override
  State<YojanaScreen> createState() => _YojanaScreenState();
}

class _YojanaScreenState extends State<YojanaScreen> {
  late FlutterTts _tts;
  int? _speakingIndex;
  bool _isSpeaking = false;


  // ── Scheme Data ──────────────────────────────────────────────────────────
  static final List<_Scheme> _schemes = [
    _Scheme(
      emoji: '💰',
      title: 'पीएम किसान सम्मान निधि',
      titleEn: 'PM Kisan Samman Nidhi',
      subtitle: '₹6,000 वार्षिक (3 किश्तें × ₹2,000)',
      subtitleEn: '₹6,000 yearly (3 installments × ₹2,000)',
      color: Colors.green,
      helpline: '155261',
      statusUrl: 'https://pmkisan.gov.in/BeneficiaryStatus.aspx',
      statusLabel: '₹ पेमेंट स्टेटस चेक करें',
      statusLabelEn: '₹ Check payment status',
      officialUrl: 'https://pmkisan.gov.in',
      eligibility: [
        'भारतीय नागरिक किसान परिवार',
        'खेती योग्य भूमि का स्वामित्व होना चाहिए',
        'आधार कार्ड बैंक खाते से लिंक होना अनिवार्य',
        'सरकारी कर्मचारी / आयकर दाता / पेंशनभोगी पात्र नहीं हैं',
      ],
      eligibilityEn: [
        'Indian citizen farmer families',
        'Must own cultivable land',
        'Aadhaar card must be linked to bank account',
        'Government employees / taxpayers / pensioners are not eligible',
      ],
      documents: ['आधार कार्ड', 'बैंक पासबुक (IFSC सहित)', 'खतौनी / भूमि रिकॉर्ड', 'मोबाइल नंबर (आधार से लिंक)'],
      documentsEn: ['Aadhaar Card', 'Bank Passbook (with IFSC)', 'Land Records (Khatauni)', 'Mobile Number (linked to Aadhaar)'],
      howToApply: '1. pmkisan.gov.in पर जाएं या CSC (जन सेवा केंद्र) जाएं।\n2. "New Farmer Registration" पर क्लिक करें।\n3. आधार नंबर और राज्य चुनें।\n4. बैंक, भूमि और व्यक्तिगत विवरण भरें।\n5. सबमिट करें — 30-60 दिन में पहली किश्त आएगी।',
      howToApplyEn: '1. Go to pmkisan.gov.in or visit a CSC (Common Service Center).\n2. Click on "New Farmer Registration".\n3. Enter Aadhaar number and select state.\n4. Fill bank, land and personal details.\n5. Submit — First installment will arrive in 30-60 days.',
      eligibilityQuestions: [
        _EligibilityQ('क्या आपके पास खेती योग्य जमीन है?', 'Do you own cultivable land?', true),
        _EligibilityQ('क्या आपका आधार कार्ड बैंक खाते से लिंक है?', 'Is your Aadhaar card linked to your bank account?', true),
        _EligibilityQ('क्या आप सरकारी कर्मचारी या आयकर दाता हैं?', 'Are you a government employee or taxpayer?', false),
      ],
    ),
    _Scheme(
      emoji: '🌾',
      title: 'पीएम फसल बीमा योजना (PMFBY)',
      titleEn: 'PM Fasal Bima Yojana (PMFBY)',
      subtitle: 'फसलों के नुकसान पर बीमा क्लेम',
      subtitleEn: 'Insurance claim for crop damage',
      color: Colors.orange,
      helpline: '18001801551',
      statusUrl: 'https://pmfby.gov.in/claimStatus',
      statusLabel: '📋 क्लेम स्टेटस चेक करें',
      statusLabelEn: '📋 Check claim status',
      officialUrl: 'https://pmfby.gov.in',
      eligibility: [
        'सभी किसान (लोन लेने वाले और बिना लोन वाले)',
        'अधिसूचित फसलों की खेती करने वाले',
        'बुवाई के 10 दिन के अंदर बीमा कराना जरूरी',
      ],
      eligibilityEn: [
        'All farmers (both loanee and non-loanee)',
        'Cultivating notified crops',
        'Must get insurance within 10 days of sowing',
      ],
      documents: ['आधार कार्ड', 'बैंक पासबुक', 'खतौनी / भूमि रिकॉर्ड', 'बुवाई प्रमाण पत्र (सरपंच/पटवारी)', 'पासपोर्ट साइज फोटो'],
      documentsEn: ['Aadhaar Card', 'Bank Passbook', 'Land Records (Khatauni)', 'Sowing Certificate (from Sarpanch/Patwari)', 'Passport size photo'],
      howToApply: '1. नजदीकी बैंक शाखा या CSC जाएं।\n2. pmfby.gov.in पर ऑनलाइन भी आवेदन कर सकते हैं।\n3. प्रीमियम: खरीफ में 2%, रबी में 1.5%, बागवानी में 5%।\n4. फसल नुकसान होने पर 72 घंटे के भीतर सूचित करें।',
      howToApplyEn: '1. Visit nearest bank branch or CSC.\n2. You can also apply online at pmfby.gov.in.\n3. Premium: Kharif 2%, Rabi 1.5%, Horticulture crops 5%.\n4. Inform within 72 hours of crop damage.',
      eligibilityQuestions: [
        _EligibilityQ('क्या आपने अधिसूचित फसल की बुवाई की है?', 'Have you sown notified crops?', true),
        _EligibilityQ('क्या बुवाई को 10 दिन से कम हुए हैं?', 'Was sowing done less than 10 days ago?', true),
      ],
    ),
    _Scheme(
      emoji: '💳',
      title: 'किसान क्रेडिट कार्ड (KCC)',
      titleEn: 'Kisan Credit Card (KCC)',
      subtitle: '4% ब्याज पर ₹3 लाख तक लोन',
      subtitleEn: 'Up to ₹3 Lakh loan at 4% interest',
      color: Colors.blue,
      helpline: '14440',
      statusUrl: '',
      statusLabel: '',
      statusLabelEn: '',
      officialUrl: 'https://pmkisan.gov.in/KCCForm.aspx',
      eligibility: [
        'सभी किसान (व्यक्तिगत या संयुक्त)',
        'किराये/बटाई पर खेती करने वाले भी पात्र',
        'पशुपालक और मछुआरे भी पात्र',
      ],
      eligibilityEn: [
        'All farmers (individual or joint)',
        'Sharecroppers/tenant farmers are also eligible',
        'Animal husbandry farmers and fishermen are also eligible',
      ],
      documents: ['आधार कार्ड', 'पैन कार्ड', 'बैंक पासबुक', 'खतौनी / भूमि रिकॉर्ड', '2 पासपोर्ट साइज फोटो', 'शपथ पत्र (Affidavit)'],
      documentsEn: ['Aadhaar Card', 'PAN Card', 'Bank Passbook', 'Land Records (Khatauni)', '2 Passport size photos', 'Affidavit'],
      howToApply: '1. नजदीकी बैंक शाखा (SBI, PNB, कृषि बैंक) जाएं।\n2. KCC आवेदन फॉर्म भरें।\n3. दस्तावेज जमा करें।\n4. 15-30 दिन में KCC कार्ड मिल जाएगा।\n5. ₹1.60 लाख तक बिना गिरवी, ₹3 लाख तक जमीन गिरवी पर।',
      howToApplyEn: '1. Visit nearest bank branch (SBI, PNB, Cooperative Bank).\n2. Fill KCC application form.\n3. Submit documents.\n4. KCC card will be issued in 15-30 days.\n5. Up to ₹1.60 Lakh without collateral, up to ₹3 Lakh with land collateral.',
      eligibilityQuestions: [
        _EligibilityQ('क्या आप खेती, पशुपालन या मछली पालन करते हैं?', 'Are you involved in farming, animal husbandry or fishing?', true),
        _EligibilityQ('क्या आपके पास बैंक खाता है?', 'Do you have a bank account?', true),
      ],
    ),
    _Scheme(
      emoji: '🧪',
      title: 'मृदा स्वास्थ्य कार्ड',
      titleEn: 'Soil Health Card Scheme',
      subtitle: 'मुफ्त मिट्टी जांच रिपोर्ट',
      subtitleEn: 'Free soil testing report',
      color: Colors.brown,
      helpline: '1800115526',
      statusUrl: 'https://soilhealth.dac.gov.in',
      statusLabel: '🧾 कार्ड स्टेटस चेक करें',
      statusLabelEn: '🧾 Check card status',
      officialUrl: 'https://soilhealth.dac.gov.in',
      eligibility: [
        'भारत के सभी किसान पात्र हैं',
        'कोई भूमि सीमा नहीं',
        'प्रत्येक 3 वर्ष में नया कार्ड मिलता है',
      ],
      eligibilityEn: [
        'All farmers in India are eligible',
        'No land ownership limit',
        'Get a new card every 3 years',
      ],
      documents: ['आधार कार्ड', 'मिट्टी का नमूना (खेत से)'],
      documentsEn: ['Aadhaar Card', 'Soil sample (from farm)'],
      howToApply: '1. नजदीकी कृषि विज्ञान केंद्र (KVK) या कृषि विभाग कार्यालय जाएं।\n2. खेत के 5 कोनों से V-आकार में मिट्टी का नमूना लें।\n3. आधा किलो मिट्टी जमा करें।\n4. 15-30 दिन में मृदा स्वास्थ्य कार्ड मिलेगा।\n5. कार्ड पर N, P, K और सूक्ष्म पोषक तत्वों की मात्रा लिखी होगी।',
      howToApplyEn: '1. Visit nearest Krishi Vigyan Kendra (KVK) or Agriculture Dept office.\n2. Take soil sample in V-shape from 5 corners of the field.\n3. Submit half kg of soil.\n4. Get Soil Health Card in 15-30 days.\n5. Card shows levels of N, P, K and micro-nutrients.',
      eligibilityQuestions: [
        _EligibilityQ('क्या आपके पास खेती योग्य जमीन है?', 'Do you own cultivable land?', true),
      ],
    ),
    _Scheme(
      emoji: '💧',
      title: 'सूक्ष्म सिंचाई सब्सिडी (Drip/Sprinkler)',
      titleEn: 'Micro Irrigation Subsidy (Drip/Sprinkler)',
      subtitle: '55-90% सब्सिडी',
      subtitleEn: '55-90% subsidy on equipment',
      color: Colors.cyan,
      helpline: '1800115526',
      statusUrl: '',
      statusLabel: '',
      statusLabelEn: '',
      officialUrl: 'https://pmksy.gov.in',
      eligibility: [
        'सभी श्रेणी के किसान पात्र',
        'लघु/सीमांत किसानों को 55% सब्सिडी',
        'अन्य किसानों को 45% सब्सिडी',
        'कुछ राज्यों में अतिरिक्त टॉप-अप (90% तक)',
      ],
      eligibilityEn: [
        'All categories of farmers eligible',
        'Small/marginal farmers get 55% subsidy',
        'Other farmers get 45% subsidy',
        'Some states offer extra top-up (up to 90%)',
      ],
      documents: ['आधार कार्ड', 'खतौनी / भूमि रिकॉर्ड', 'बैंक पासबुक', 'सिंचाई उपकरण का कोटेशन (Dealer से)'],
      documentsEn: ['Aadhaar Card', 'Land Records (Khatauni)', 'Bank Passbook', 'Quotation of irrigation equipment (from dealer)'],
      howToApply: '1. राज्य कृषि/उद्यान विभाग की वेबसाइट पर ऑनलाइन आवेदन करें।\n2. या नजदीकी कृषि कार्यालय जाएं।\n3. उपकरण लगवाने के बाद सत्यापन (verification) होगा।\n4. सब्सिडी सीधे बैंक खाते में आएगी।',
      howToApplyEn: '1. Apply online on State Agriculture/Horticulture Dept website.\n2. Or visit the nearest agriculture office.\n3. Verification will be done after equipment installation.\n4. Subsidy will be directly credited to bank account.',
      eligibilityQuestions: [
        _EligibilityQ('क्या आपके पास सिंचाई के लिए पानी का स्रोत (बोरवेल/नहर) है?', 'Do you have a water source (borewell/canal) for irrigation?', true),
        _EligibilityQ('क्या आपके पास कम से कम 0.5 हेक्टेयर ज़मीन है?', 'Do you own at least 0.5 hectare of land?', true),
      ],
    ),
    _Scheme(
      emoji: '🐄',
      title: 'पशु किसान क्रेडिट कार्ड',
      titleEn: 'Animal Husbandry KCC',
      subtitle: 'गाय/भैंस खरीद के लिए लोन',
      subtitleEn: 'Loan for buying Cow/Buffalo',
      color: Colors.deepOrange,
      helpline: '14440',
      statusUrl: '',
      statusLabel: '',
      statusLabelEn: '',
      officialUrl: 'https://dahd.nic.in',
      eligibility: [
        'सभी पशुपालक किसान पात्र',
        'गाय/भैंस/बकरी/मुर्गी पालन करने वाले',
        'किराये पर जमीन वाले भी पात्र',
      ],
      eligibilityEn: [
        'All animal husbandry farmers eligible',
        'Rearing cows, buffaloes, goats, poultry, etc.',
        'Tenant farmers also eligible',
      ],
      documents: ['आधार कार्ड', 'पैन कार्ड', 'बैंक पासबुक', 'पशु स्वास्थ्य प्रमाण पत्र (पशु चिकित्सक से)', '2 फोटो'],
      documentsEn: ['Aadhaar Card', 'PAN Card', 'Bank Passbook', 'Animal health certificate (from vet)', '2 photos'],
      howToApply: '1. नजदीकी बैंक शाखा जाएं।\n2. पशु KCC आवेदन फॉर्म भरें।\n3. ₹1.60 लाख तक बिना गिरवी के लोन।\n4. गाय के लिए ₹40,783/गाय, भैंस के लिए ₹60,249/भैंस।\n5. 4% ब्याज दर (समय पर चुकाने पर)।',
      howToApplyEn: '1. Visit nearest bank branch.\n2. Fill Animal Husbandry KCC application form.\n3. Up to ₹1.60 Lakh loan without collateral.\n4. Limit: ₹40,783/cow, ₹60,249/buffalo.\n5. 4% interest rate (on timely repayment).',
      eligibilityQuestions: [
        _EligibilityQ('क्या आप पशुपालन (गाय/भैंस/बकरी आदि) करते हैं?', 'Are you involved in animal husbandry (cow, buffalo, goat rearing)?', true),
        _EligibilityQ('क्या आपके पास बैंक खाता है?', 'Do you have a bank account?', true),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('hi-IN');
    _tts.setSpeechRate(0.55);
    _tts.setCompletionHandler(() => setState(() { _isSpeaking = false; _speakingIndex = null; }));
    _tts.setErrorHandler((_) => setState(() { _isSpeaking = false; _speakingIndex = null; }));
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text, int idx) async {
    if (_isSpeaking && _speakingIndex == idx) {
      await _tts.stop();
      setState(() { _isSpeaking = false; _speakingIndex = null; });
      return;
    }
    await _tts.stop();
    final isHi = AppLocalizations.isHindiLike(context);
    await _tts.setLanguage(isHi ? 'hi-IN' : 'en-IN');
    setState(() { _speakingIndex = idx; _isSpeaking = true; });
    await _tts.speak(text);
  }

  Future<void> _launchUrl(String url) async {
    // canLaunchUrl नहीं — Android 11+ पर भरोसेमंद नहीं
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _callHelpline(String number) async {
    try {
      await launchUrl(Uri.parse('tel:$number'),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(context, 'moreYojana')),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _schemes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Card(
                color: Colors.amber.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.shade300, width: 0.5),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.get(context, 'yojanaDisclaimer'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final s = _schemes[index - 1];
            return _SchemeCard(
              scheme: s,
              index: index - 1,
              isSpeaking: _speakingIndex == (index - 1) && _isSpeaking,
              onSpeak: (text) => _speak(text, index - 1),
              onCall: () => _callHelpline(s.helpline),
              onStatus: () => _launchUrl(s.statusUrl),
              onOfficial: () => _launchUrl(s.officialUrl),
            );
          },
        ),
      ),
    );
  }
}

// ── Scheme Card Widget ─────────────────────────────────────────────────────
class _SchemeCard extends StatefulWidget {
  final _Scheme scheme;
  final int index;
  final bool isSpeaking;
  final void Function(String) onSpeak;
  final VoidCallback onCall;
  final VoidCallback onStatus;
  final VoidCallback onOfficial;

  const _SchemeCard({
    required this.scheme,
    required this.index,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onCall,
    required this.onStatus,
    required this.onOfficial,
  });

  @override
  State<_SchemeCard> createState() => _SchemeCardState();
}

class _SchemeCardState extends State<_SchemeCard> {
  bool _expanded = false;
  bool _showEligibility = false;
  List<bool> _eligAnswers = [];
  String? _eligResult;
  List<bool> _docChecked = [];

  _Scheme get s => widget.scheme;
  String _t(String k) => AppLocalizations.get(context, k);
  bool get _isHi => AppLocalizations.isHindiLike(context);

  @override
  void initState() {
    super.initState();
    _docChecked = List.filled(s.documents.length, false);
  }

  void _resetEligibility() {
    setState(() {
      _showEligibility = false;
      _eligAnswers = [];
      _eligResult = null;
    });
  }

  void _checkEligibility() {
    bool eligible = true;
    for (int i = 0; i < s.eligibilityQuestions.length; i++) {
      final answer = i < _eligAnswers.length ? _eligAnswers[i] : false;
      if (answer != s.eligibilityQuestions[i].expectedAnswer) {
        eligible = false;
        break;
      }
    }
    setState(() {
      _eligResult = eligible ? _t('yEligibleYes') : _t('yEligibleNo');
    });
  }

  String _fullSpeechText() {
    final buf = StringBuffer();
    final isHi = _isHi;
    buf.writeln('${isHi ? s.title : s.titleEn}।');
    buf.writeln('${isHi ? "लाभ" : "Benefits"}: ${isHi ? s.subtitle : s.subtitleEn}।');
    buf.writeln(isHi ? 'पात्रता:' : 'Eligibility:');
    final elList = isHi ? s.eligibility : s.eligibilityEn;
    for (var e in elList) { buf.writeln('$e।'); }
    buf.writeln('${isHi ? "आवश्यक दस्तावेज" : "Required documents"}: ${(isHi ? s.documents : s.documentsEn).join(', ')}।');
    buf.writeln(isHi ? 'आवेदन प्रक्रिया:' : 'Application process:');
    buf.writeln(isHi ? s.howToApply : s.howToApplyEn);
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final docDone = _docChecked.where((v) => v).length;
    final title = _isHi ? s.title : s.titleEn;
    final subtitle = _isHi ? s.subtitle : s.subtitleEn;
    final eligibilityList = _isHi ? s.eligibility : s.eligibilityEn;
    final documentsList = _isHi ? s.documents : s.documentsEn;
    final howToApplyText = _isHi ? s.howToApply : s.howToApplyEn;
    final statusLabelText = _isHi ? s.statusLabel : s.statusLabelEn;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() { _expanded = !_expanded; _resetEligibility(); }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [s.color.withValues(alpha: 0.08), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(s.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(fontSize: 14, color: s.color, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),

          // ── Expanded Details ──
          if (_expanded) ...[
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eligibility
                  _sectionHeader(Icons.verified_user_rounded, _t('yEligibility'), s.color),
                  const SizedBox(height: 6),
                  ...eligibilityList.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: s.color),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e, style: const TextStyle(fontSize: 15, height: 1.35))),
                      ],
                    ),
                  )),

                  const SizedBox(height: 16),

                  // ── Interactive Eligibility Checker ──
                  OutlinedButton.icon(
                    onPressed: () => setState(() { _showEligibility = !_showEligibility; _eligResult = null; _eligAnswers = List.filled(s.eligibilityQuestions.length, false); }),
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: Text(_showEligibility ? _t('yCheckClose') : _t('yCheckElig')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: s.color,
                      side: BorderSide(color: s.color),
                    ),
                  ),

                  if (_showEligibility) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: s.color.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_t('yAnswerQ'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 10),
                          ...List.generate(s.eligibilityQuestions.length, (qi) {
                            final questionText = _isHi ? s.eligibilityQuestions[qi].question : s.eligibilityQuestions[qi].questionEn;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Text(questionText, style: const TextStyle(fontSize: 15))),
                                  ToggleButtons(
                                    isSelected: [
                                      qi < _eligAnswers.length && _eligAnswers[qi] == true,
                                      qi < _eligAnswers.length && _eligAnswers[qi] == false,
                                    ],
                                    onPressed: (btnIdx) {
                                      setState(() {
                                        if (_eligAnswers.length <= qi) {
                                          _eligAnswers = List.filled(s.eligibilityQuestions.length, false);
                                        }
                                        _eligAnswers[qi] = btnIdx == 0;
                                        _eligResult = null;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    selectedColor: Colors.white,
                                    fillColor: s.color,
                                    constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
                                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    children: [Text(_t('yYes')), Text(_t('yNo'))],
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _checkEligibility,
                              style: ElevatedButton.styleFrom(backgroundColor: s.color, foregroundColor: Colors.white),
                              child: Text(_t('ySeeResult'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if (_eligResult != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _eligResult!.startsWith('✅') || _eligResult!.contains('Congrat') ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_eligResult!, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _eligResult!.startsWith('✅') || _eligResult!.contains('Congrat') ? Colors.green.shade800 : Colors.red.shade800,
                              )),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Document Checklist ──
                  _sectionHeader(Icons.checklist_rounded, '${_t('yDocChecklist')} ($docDone/${documentsList.length} ${_t('yReady')})', Colors.indigo),
                  const SizedBox(height: 6),
                  ...List.generate(documentsList.length, (di) => CheckboxListTile(
                    value: _docChecked[di],
                    onChanged: (v) => setState(() => _docChecked[di] = v!),
                    title: Text(documentsList[di], style: TextStyle(
                      fontSize: 15,
                      decoration: _docChecked[di] ? TextDecoration.lineThrough : null,
                      color: _docChecked[di] ? Colors.grey : Colors.black87,
                    )),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )),

                  if (docDone == documentsList.length)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(_t('yAllDocs'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),

                  const SizedBox(height: 16),

                  // ── How to Apply ──
                  _sectionHeader(Icons.assignment_rounded, _t('yHowApply'), Colors.teal),
                  const SizedBox(height: 6),
                  Text(howToApplyText, style: const TextStyle(fontSize: 15, height: 1.55)),

                  const Divider(height: 28),

                  // ── Action Buttons ──
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Speak
                      _actionChip(
                        icon: widget.isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        label: widget.isSpeaking ? _t('yStop') : _t('ySpeak'),
                        color: widget.isSpeaking ? Colors.red : DairyTheme.primaryTeal,
                        onTap: () => widget.onSpeak(_fullSpeechText()),
                      ),
                      // Call Helpline
                      _actionChip(
                        icon: Icons.phone_rounded,
                        label: '${_t('yHelpline')} (${s.helpline})',
                        color: Colors.blue,
                        onTap: widget.onCall,
                      ),
                      // Status Check
                      if (s.statusUrl.isNotEmpty)
                        _actionChip(
                          icon: Icons.fact_check_rounded,
                          label: statusLabelText,
                          color: Colors.purple,
                          onTap: widget.onStatus,
                        ),
                      // Official Website
                      _actionChip(
                        icon: Icons.language_rounded,
                        label: _t('yOfficial'),
                        color: Colors.teal,
                        onTap: widget.onOfficial,
                      ),
                      // Share
                      _actionChip(
                        icon: Icons.share_rounded,
                        label: _t('yShare'),
                        color: Colors.green,
                        onTap: () {
                          Share.share(
                            '🏛️ *${title}*\n\n💰 ${subtitle}\n\n📞 ${_t('yHelpline')}: ${s.helpline}\n🔗 ${s.officialUrl}\n\n📲 *${_t('appName')}* ${_isHi ? 'से भेजा गया' : 'app'}',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ),
      ],
    );
  }

  Widget _actionChip({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      onPressed: onTap,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      backgroundColor: color.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────────
class _Scheme {
  final String emoji, title, titleEn, subtitle, subtitleEn, helpline, statusUrl, statusLabel, statusLabelEn, officialUrl, howToApply, howToApplyEn;
  final Color color;
  final List<String> eligibility, eligibilityEn, documents, documentsEn;
  final List<_EligibilityQ> eligibilityQuestions;

  const _Scheme({
    required this.emoji, required this.title, required this.titleEn,
    required this.subtitle, required this.subtitleEn,
    required this.color, required this.helpline, required this.statusUrl,
    required this.statusLabel, required this.statusLabelEn,
    required this.officialUrl, required this.eligibility, required this.eligibilityEn,
    required this.documents, required this.documentsEn,
    required this.howToApply, required this.howToApplyEn,
    required this.eligibilityQuestions,
  });
}

class _EligibilityQ {
  final String question, questionEn;
  final bool expectedAnswer;
  const _EligibilityQ(this.question, this.questionEn, this.expectedAnswer);
}
