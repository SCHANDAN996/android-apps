import 'package:flutter/material.dart';

import '../vidhi/aane_wale_din.dart'
    show tyoharKaGranth, tyoharKaVrat, tyoharKiPuja;
import '../vidhi/bhandar.dart';
import '../vidhi/granth.dart';
import '../widgets/design_system.dart';
import 'granth_screen.dart';
import 'vidhi_screen.dart';
import 'vrat_panna_screen.dart';

/// पर्व के हिस्से वाले त्योहार की अपनी विधि — दशहरा नवरात्रि पर्व का दसवाँ
/// दिन है (→ D-074), इसलिए «आने वाले» में उसका अलग पत्ता नहीं बनता; पर कैलेंडर
/// और "आज" पर वह अपने नाम से दिखता है, और वहाँ से विजयादशमी की विधि खुले
/// (→ D-155)। `tyoharKiPuja` में नहीं, क्योंकि वह सूची `_suchi` की पूजाएँ माँगती है।
const Map<String, String> parvDinKiVidhi = {'दशहरा': 'vijayadashami'};

/// अपना पन्ना न हो तो event केवल तारीख़ की तरह दिखे, नक़ली विधि न खुले।
/// विधि न हो पर व्रत-पन्ना हो (शरद पूर्णिमा), तो वह (→ D-130); वह भी न हो पर
/// ग्रंथ हो (गीता जयंती), तो ग्रंथ (→ D-153)।
Widget? festivalDestination(String name) {
  final vidhiId = tyoharKiPuja[name] ?? parvDinKiVidhi[name];
  if (vidhiId != null) return VidhiScreen(id: vidhiId);
  final vratId = tyoharKaVrat[name];
  if (vratId != null) return VratPannaScreen(id: vratId);
  final granthId = tyoharKaGranth[name];
  return granthId == null ? null : GranthIdSe(id: granthId);
}

/// ग्रंथ सिर्फ़ उसकी `id` से — [GranthScreen] को सूची वाली पूरी entry चाहिए,
/// और सूची asset से async आती है; यह बीच की कड़ी है।
class GranthIdSe extends StatefulWidget {
  final String id;

  const GranthIdSe({super.key, required this.id});

  @override
  State<GranthIdSe> createState() => _GranthIdSeState();
}

class _GranthIdSeState extends State<GranthIdSe> {
  late final Future<List<GranthSuchiEntry>> _suchi = granthBhandar.suchi();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GranthSuchiEntry>>(
      future: _suchi,
      builder: (context, snap) {
        final mila = [
          ...?snap.data,
          GranthSuchiEntry.saptashati,
        ].where((g) => g.id == widget.id).firstOrNull;
        if (snap.hasData && mila != null) return GranthScreen(granth: mila);
        return Scaffold(
          appBar: AppBar(title: const Text('ग्रंथ')),
          body: SafeArea(
            top: false,
            child: VidhivatSacredBackdrop(
              child: snap.hasError || snap.hasData
                  ? const VidhivatStateView(
                      title: 'यह ग्रंथ खुल नहीं सका',
                      message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                      icon: Icons.error_outline,
                      tone: VidhivatStateTone.error,
                    )
                  : const VidhivatStateView(
                      title: 'ग्रंथ खुल रहा है', loading: true),
            ),
          ),
        );
      },
    );
  }
}
