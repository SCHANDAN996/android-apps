import 'package:flutter/material.dart';
import '../../data/palan/palan_data.dart';
import '../../data/palan/palan_meta.dart';
import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';
import 'palan_detail_screen.dart';

/// पशु पालन गाइड चुनने का पन्ना — खोज + श्रेणी + 2 × 2 बड़े कार्ड।
///
/// पहले 3 कतार का grid था — कार्ड छोटे थे और उनमें सिर्फ़ चित्र और नाम आता
/// था। किसान को यह पता नहीं चलता था कि किस पालन में क्या ख़ास है। अब हर
/// कार्ड में **tagline भी दिखती है** ("कम लागत, कम जगह", "रोज़ की कमाई")
/// जिससे वह बिना खोले ही अंदाज़ा लगा सके।
class PalanPickerScreen extends StatefulWidget {
  const PalanPickerScreen({super.key});

  @override
  State<PalanPickerScreen> createState() => _PalanPickerScreenState();
}

class _PalanPickerScreenState extends State<PalanPickerScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  PalanGroup? _group;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isHi => AppLocalizations.isHindiLike(context);

  /// चुनी हुई भाषा का कोड — `tx()` इसी से अनुवाद की परत देखता है
  String get _lang => AppLocalizations.langCode(context);

  List<PalanGuide> get _filtered => kPalanGuides
      .where((g) => palanMatches(g, _query))
      .where((g) => _group == null || palanGroup(g.id) == _group)
      .toList();

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: DairyTheme.creamBg,
      appBar: AppBar(title: Text(_isHi ? 'पशु पालन गाइड' : 'Livestock Guide')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isHi ? 'कौन-सा पालन करना है?' : 'Which one do you want to start?',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                _isHi
                    ? 'हर गाइड में — नस्ल, आवास, चारा, टीका, लागत-मुनाफ़ा और सरकारी मदद'
                    : 'Each guide covers breeds, housing, feed, vaccines, economics and government support',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.35),
              ),
              const SizedBox(height: 12),
              _searchBar(),
              const SizedBox(height: 10),
              _groupChips(),
              const SizedBox(height: 12),
              if (list.isEmpty)
                _nothingFound()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.80,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _card(list[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() => TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: _isHi ? 'खोजें… (बकरी, bakri, goat)' : 'Search…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: _isHi ? 'हटाएँ' : 'Clear',
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: DairyTheme.primaryTeal, width: 2),
          ),
        ),
      );

  Widget _groupChips() => SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _chip(null, _isHi ? 'सब' : 'All'),
            for (final g in PalanGroup.values) _chip(g, g.label(_isHi)),
          ],
        ),
      );

  Widget _chip(PalanGroup? g, String label) {
    final on = _group == g;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        onSelected: (_) => setState(() => _group = g),
        labelStyle: TextStyle(
          fontSize: 13.5,
          fontWeight: on ? FontWeight.bold : FontWeight.w500,
          color: on ? Colors.white : Colors.grey.shade800,
        ),
        selectedColor: DairyTheme.primaryTeal,
        backgroundColor: Colors.white,
        side: BorderSide(color: on ? DairyTheme.primaryTeal : Colors.grey.shade300),
        showCheckmark: false,
      ),
    );
  }

  Widget _nothingFound() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _isHi ? 'यह पालन नहीं मिला' : 'Not found',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );

  Widget _card(PalanGuide g) {
    final img = palanImage(g.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PalanDetailScreen(guide: g)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: g.color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            // ⚠️ चित्र `Expanded` में है और लिखा हुआ नीचे तय ऊँचाई में —
            // उल्टा नहीं।
            //
            // पहले चित्र की ऊँचाई 68 पर बँधी थी और tagline `Expanded` में
            // थी। नतीजा: चित्र कार्ड के हिसाब से छोटा रह जाता और लिखा हुआ
            // बची हुई जगह के **बीच में** तैरता रहता — हर कार्ड में अलग
            // जगह पर, क्योंकि tagline कहीं एक लाइन की है कहीं दो की।
            //
            // अब उल्टा है: नाम और tagline नीचे अपनी तय जगह लेते हैं, और जो
            // भी बचता है वह पूरा चित्र को मिल जाता है। इससे चित्र बड़ा
            // दिखता है और सारे कार्ड में लिखा हुआ **एक ही रेखा पर** बैठता है।
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: img == null
                        ? Text(g.emoji, style: const TextStyle(fontSize: 56))
                        : Image.asset(
                            img,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(g.emoji,
                                style: const TextStyle(fontSize: 56)),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tx(g.name, _isHi, _lang),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: g.color,
                  ),
                ),
                const SizedBox(height: 4),
                // tagline — बिना खोले ही पता चले कि इसमें ख़ास क्या है।
                //
                // ऊँचाई दो लाइनों पर तय (11.5 × 1.3 × 2 ≈ 30) ताकि एक लाइन
                // वाली tagline भी उतनी ही जगह घेरे — तभी सारे कार्ड के चित्र
                // बराबर बड़े होंगे और नाम एक ही रेखा पर आएँगे।
                SizedBox(
                  height: 30,
                  child: Text(
                    tx(g.tagline, _isHi, _lang),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
