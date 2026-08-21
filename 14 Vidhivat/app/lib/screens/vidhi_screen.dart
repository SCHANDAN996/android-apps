import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import 'samagri_screen.dart';
import 'vidhi_player_screen.dart';

/// एक पूजा का विवरण — शुरू करने से पहले वाला पन्ना।
///
/// यहाँ यूज़र यह तय करता है कि आज यह पूजा कर सकता है या नहीं: कब करनी
/// है, कितना समय लगेगा, कितनी सामग्री चाहिए। **इसीलिए सामग्री की सूची
/// विधि से पहले आती है** — बाज़ार जाना पड़ सकता है।
class VidhiScreen extends StatefulWidget {
  final String id;

  const VidhiScreen({super.key, required this.id});

  @override
  State<VidhiScreen> createState() => _VidhiScreenState();
}

class _VidhiScreenState extends State<VidhiScreen> {
  late Future<Vidhi> _vidhi;

  @override
  void initState() {
    super.initState();
    _vidhi = vidhiBhandar.vidhi(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Vidhi>(
      future: _vidhi,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('पूजा')),
            body: Panna(
              children: [
                Chetavni(
                  'यह पूजा नहीं खुल सकी।\n\n${snap.error}',
                  icon: Icons.error_outline,
                  serious: true,
                ),
              ],
            ),
          );
        }
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('पूजा')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return _Vivaran(vidhi: snap.data!);
      },
    );
  }
}

class _Vivaran extends StatelessWidget {
  final Vidhi vidhi;

  const _Vivaran({required this.vidhi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mantraAdhure = vidhi.mantraKul - vidhi.mantraBhareHue;

    return Scaffold(
      appBar: AppBar(title: Text(vidhi.naam)),
      body: Panna(
        children: [
          Text(
            vidhi.parichay,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 20),

          // ── चेतावनियाँ — सबसे ऊपर, छिपाकर नहीं ──
          //
          // "मंत्र ग़लत होना तिथि ग़लत होने से भी बुरा है" — इसलिए जब तक
          // पंडित जी पास न कर दें, यह बात यूज़र को पहले ही दिख जानी चाहिए।
          if (vidhi.needsPanditReview)
            const Chetavni(
              'यह विधि अभी किसी पंडित जी से जाँच करवाकर पास नहीं हुई है। '
              'ढाँचा आम घरेलू चलन के अनुसार है — अपने घर की परंपरा से '
              'मिला लीजिए।',
              serious: true,
            ),
          if (mantraAdhure > 0)
            Chetavni(
              'इस पूजा के $mantraAdhure मंत्रों का पाठ अभी ऐप में जोड़ा नहीं '
              'गया है। जब तक प्रामाणिक स्रोत से न आ जाए, हम अंदाज़े से कुछ '
              'नहीं लिखेंगे।',
            ),

          // ── एक नज़र में ──
          Khand(
            title: 'एक नज़र में',
            child: Column(
              children: [
                Pankti('कब करें', vidhi.kabKarein.saral,
                    note: vidhi.kabKarein.note.isEmpty
                        ? null
                        : vidhi.kabKarein.note),
                const Divider(),
                Pankti('कितना समय', vidhi.samayLikha),
                const Divider(),
                Pankti('कितनी कठिन', vidhi.kathinai.naam),
                const Divider(),
                Pankti('कदम', '${vidhi.charan.length}'),
                const Divider(),
                Pankti(
                  'सामग्री',
                  '${vidhi.zaruriSamagri.length} ज़रूरी',
                  note: vidhi.samagri.length > vidhi.zaruriSamagri.length
                      ? '${vidhi.samagri.length - vidhi.zaruriSamagri.length} '
                          'वैकल्पिक भी'
                      : null,
                ),
              ],
            ),
          ),

          // ── कदमों की झलक ──
          Khand(
            title: 'कदम',
            subtitle: 'पूरी विधि में क्या-क्या आएगा',
            child: Column(
              children: [
                for (var i = 0; i < vidhi.charan.length; i++) ...[
                  if (i > 0) const Divider(),
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundColor:
                          VidhivatTheme.haldi.withValues(alpha: 0.15),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      vidhi.charan[i].shirshak,
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: vidhi.charan[i].samayMinute > 0
                        ? Text(
                            '${vidhi.charan[i].samayMinute} मि',
                            style: theme.textTheme.bodySmall,
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),

          // ── आम सवाल ──
          if (vidhi.sawaal.isNotEmpty)
            Khand(
              title: 'आम सवाल',
              child: Column(
                children: [
                  for (final s in vidhi.sawaal)
                    ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(
                        s.sawaal,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            s.jawaab,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          // ── यह विधि कहाँ से आई — भरोसा इसी से बनता है ──
          Khand(
            title: 'यह विधि कहाँ से आई',
            child: Column(
              children: [
                Pankti('पद्धति', vidhi.strot.paddhati),
                const Divider(),
                Pankti('क्षेत्र', vidhi.strot.kshetra),
                const Divider(),
                Pankti(
                  'जाँच',
                  vidhi.jaanch.paas
                      ? '${vidhi.jaanch.panditNaam} · ${vidhi.jaanch.tarikh}'
                      : 'अभी बाक़ी है',
                  valueColour: vidhi.jaanch.paas
                      ? VidhivatTheme.tulsi
                      : theme.colorScheme.secondary,
                ),
                if (vidhi.strot.note.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      vidhi.strot.note,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      // ── दो बटन, हमेशा नीचे टिके हुए ──
      //
      // पहले ये पन्ने के अंदर थे, और परिचय + चेतावनी + "एक नज़र में" के
      // बाद तह के नीचे चले जाते थे — यानी मुख्य काम के लिए स्क्रॉल करना
      // पड़ता। सबसे ज़रूरी बटन कभी ढूँढना नहीं पड़ना चाहिए।
      //
      // सामग्री पहले रखी है क्योंकि बाज़ार जाना पड़ सकता है।
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SamagriScreen(vidhi: vidhi),
                    ),
                  ),
                  icon: const Icon(Icons.checklist),
                  label: const Text('सामग्री'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VidhiPlayerScreen(vidhi: vidhi),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('विधि शुरू करें'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
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
