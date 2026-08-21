import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import 'samagri_screen.dart';
import 'sankalp_screen.dart';

/// विधि प्लेयर — **यहीं असली पूजा होती है।**
///
/// यह पन्ना बाक़ी ऐप से अलग है, क्योंकि इसकी हालत अलग है: आदमी ज़मीन पर
/// बैठा है, हाथ में जल है, फ़ोन दो फ़ुट दूर रखा है, और वो पढ़ते-पढ़ते
/// बोल रहा है। इसलिए —
///
/// - **अक्षर बहुत बड़े।** मंत्र 26px पर, विवरण 20px पर।
/// - **स्क्रीन बंद नहीं होती** (`WakelockPlus`) — बीच पूजा में फ़ोन
///   काला हो जाना सबसे बुरी बात है।
/// - **एक कदम, एक पन्ना।** नीचे बड़े बटन, ताकि गीली उँगली से भी लगें।
///
/// ## ⛔ इस स्क्रीन पर विज्ञापन कभी नहीं (→ D-008)
/// चाहे मुफ़्त यूज़र हो। आदमी संकल्प ले रहा है और स्क्रीन पर विज्ञापन आ
/// गया — वो 1 स्टार देगा और लिखेगा कि ऐप ने पूजा भ्रष्ट कर दी। Drik
/// Panchang की सबसे बड़ी शिकायत यही है; उसकी सबसे बड़ी कमज़ोरी को अपनी
/// सबसे बड़ी ताक़त बनाना है। **यहाँ कोई ad widget मत जोड़ना।**
class VidhiPlayerScreen extends StatefulWidget {
  final Vidhi vidhi;

  const VidhiPlayerScreen({super.key, required this.vidhi});

  @override
  State<VidhiPlayerScreen> createState() => _VidhiPlayerScreenState();
}

class _VidhiPlayerScreenState extends State<VidhiPlayerScreen> {
  final _pages = PageController();
  int _index = 0;

  Vidhi get vidhi => widget.vidhi;

  @override
  void initState() {
    super.initState();
    _screenJagaayeRakho(true);
  }

  @override
  void dispose() {
    // पूजा ख़त्म — अब स्क्रीन को सामान्य की तरह बंद होने दो, वरना
    // बैटरी यूँ ही ख़त्म होती रहेगी।
    _screenJagaayeRakho(false);
    _pages.dispose();
    super.dispose();
  }

  /// कुछ फ़ोन/प्लेटफ़ॉर्म पर यह नहीं चलता। उसके लिए पूरी पूजा रुकनी
  /// नहीं चाहिए, इसलिए चुपचाप छोड़ देते हैं।
  Future<void> _screenJagaayeRakho(bool jagaao) async {
    try {
      await WakelockPlus.toggle(enable: jagaao);
    } catch (_) {
      // कोई बात नहीं — बस स्क्रीन सामान्य की तरह बंद होगी।
    }
  }

  void _jao(int naya) {
    if (naya < 0 || naya >= vidhi.charan.length) return;
    _pages.animateToPage(
      naya,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kul = vidhi.charan.length;
    final aakhri = _index == kul - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / $kul'),
        actions: [
          IconButton(
            tooltip: 'सामग्री',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SamagriScreen(vidhi: vidhi)),
            ),
            icon: const Icon(Icons.checklist),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / kul,
            minHeight: 4,
          ),
        ),
      ),

      body: PageView.builder(
        controller: _pages,
        itemCount: kul,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => _CharanPanna(
          vidhi: vidhi,
          charan: vidhi.charan[i],
          number: i + 1,
        ),
      ),

      // ── नीचे के बटन — बड़े, ताकि गीली उँगली से भी लगें ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _index == 0 ? null : () => _jao(_index - 1),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('पीछे'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: aakhri
                      ? () => Navigator.of(context).pop()
                      : () => _jao(_index + 1),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: aakhri ? VidhivatTheme.tulsi : null,
                  ),
                  child: Text(
                    aakhri ? 'पूजा पूरी हुई' : 'आगे',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// एक कदम का पूरा पन्ना।
class _CharanPanna extends StatelessWidget {
  final Vidhi vidhi;
  final Charan charan;
  final int number;

  const _CharanPanna({
    required this.vidhi,
    required this.charan,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Panna(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: VidhivatTheme.haldi.withValues(alpha: 0.15),
              child: Text(
                '$number',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: VidhivatTheme.haldi,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                charan.shirshak,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── क्या करना है — बड़े अक्षरों में ──
        Text(
          charan.vivaran,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            height: 1.75,
          ),
        ),
        const SizedBox(height: 24),

        if (charan.vishesh == CharanVishesh.sankalp)
          _SankalpKhand(vidhi: vidhi),

        if (charan.vishesh == CharanVishesh.katha)
          const Chetavni(
            'कथा का पूरा पाठ अभी ऐप में नहीं जोड़ा गया है। तब तक अपनी '
            'कथा-पुस्तिका से पढ़ें।',
          ),

        if (charan.mantra != null) _MantraKhand(mantra: charan.mantra!),

        if (charan.samayMinute > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'लगभग ${charan.samayMinute} मिनट',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// संकल्प वाला कदम — **यहीं ऐप अपना सबसे बड़ा काम करता है।**
///
/// पंचांग इंजन से आज का पूरा संकल्प वाक्य बनकर सामने आ जाता है, संवत् से
/// नक्षत्र तक सब भरा हुआ। यही वो जगह है जहाँ हर आदमी अटकता है (→ D-006)।
class _SankalpKhand extends StatefulWidget {
  final Vidhi vidhi;

  const _SankalpKhand({required this.vidhi});

  @override
  State<_SankalpKhand> createState() => _SankalpKhandState();
}

class _SankalpKhandState extends State<_SankalpKhand> {
  bool _pooraRoop = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!settings.hasYajman) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chetavni(
            'संकल्प में आपका नाम और गोत्र बोला जाता है। एक बार भर दीजिए — '
            'फिर हर पूजा में अपने आप आ जाएगा।',
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NaamPoochho(onDone: () {
                  Navigator.of(context).pop();
                  setState(() {});
                }),
              ),
            ),
            icon: const Icon(Icons.person_outline),
            label: const Text('नाम और गोत्र भरिए'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
        ],
      );
    }

    final p = settings.panchangFor(DateTime.now());
    final sankalp = buildSankalp(
      p,
      SankalpDetails(
        name: settings.name,
        gotra: settings.gotra,
        place: settings.city.name,
        purpose: commonPurposes[widget.vidhi.sankalpPurpose] ?? 'देवपूजनं',
      ),
    );
    final path = _pooraRoop ? sankalp.full : sankalp.simple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('पूरा संकल्प')),
            ButtonSegment(value: false, label: Text('सरल (हिंदी में)')),
          ],
          selected: {_pooraRoop},
          onSelectionChanged: (s) => setState(() => _pooraRoop = s.first),
        ),
        const SizedBox(height: 14),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              path,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                height: 1.85,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${tarikh(DateTime.now())} · ${settings.city.name} · '
          '${p.varaName} · ${p.masaFullName} ${p.pakshaName} ${p.tithi.name}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 14),

        if (sankalp.needsPanditReview)
          const Chetavni(
            'संकल्प के मान पंचांग से बने हैं और जाँचे हुए हैं, पर संस्कृत '
            'का रूप अभी पंडित जी से पास नहीं हुआ है।',
            serious: true,
          ),
      ],
    );
  }
}

/// मंत्र वाला हिस्सा।
///
/// पाठ न भरा हो तो **ख़ाली डिब्बा दिखाते हैं, बना हुआ मंत्र नहीं।**
/// अंदाज़े से मंत्र लिखना इस प्रोजेक्ट में सबसे बड़ी ग़लती मानी गई है —
/// मंत्र ग़लत होना तिथि ग़लत होने से भी बुरा है।
class _MantraKhand extends StatelessWidget {
  final Mantra mantra;

  const _MantraKhand({required this.mantra});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!mantra.hasPath) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chetavni(
            'इस कदम का मंत्र अभी ऐप में नहीं जोड़ा गया है। जब तक प्रामाणिक '
            'स्रोत से न आ जाए, हम अंदाज़े से कुछ नहीं लिखेंगे — तब तक अपनी '
            'पूजा-पुस्तिका से पढ़ें, या मन ही मन भगवान का नाम लें।',
          ),
          if (mantra.vikalp.isNotEmpty)
            Text(mantra.vikalp, style: theme.textTheme.bodySmall),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'मंत्र',
          style: theme.textTheme.titleMedium?.copyWith(
            color: VidhivatTheme.haldi,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // सबसे बड़ा अक्षर पूरे ऐप में — यही बोलकर पढ़ा जाता है।
                SelectableText(
                  mantra.devanagari,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 26,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (mantra.roman.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    mantra.roman,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                if (mantra.arth.isNotEmpty) ...[
                  const Divider(height: 28),
                  Text(
                    'अर्थ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mantra.arth,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (mantra.needsPanditReview)
          Chetavni(
            'यह मंत्र अभी पंडित जी से पास नहीं हुआ है '
            '(भरोसा — ${mantra.bharosa.naam})।',
            serious: true,
          ),

        // ── जहाँ एक से ज़्यादा चलन हैं, वो छिपाना नहीं है ──
        //
        // पंडित जी के लिए यही सबसे काम की लाइन है — वे यहीं बता देंगे कि
        // आपके घर में कौन सा रूप चलता है।
        if (mantra.vikalp.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'दूसरा चलन — ${mantra.vikalp}',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),

        if (mantra.strot.isNotEmpty)
          Text(
            'स्रोत — ${mantra.strot}',
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}
