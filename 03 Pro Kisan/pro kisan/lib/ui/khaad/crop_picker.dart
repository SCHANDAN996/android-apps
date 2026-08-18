import 'package:flutter/material.dart';
import '../../data/crop_meta.dart';
import '../../data/crops.dart';
import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';

/// फ़सल चुनने का पन्ना — खोज पट्टी + 2 × 2 बड़े कार्ड, ऊपर से नीचे।
///
/// पहले 30 फ़सलें एक पतली **आड़ी** पट्टी में थीं — किसान को 30 बार बग़ल में
/// खिसकाना पड़ता था और पीछे की फ़सलें दिखती ही नहीं थीं। अब:
///  • खोज — हिंदी, अंग्रेज़ी और रोमन (gehu/dhan) तीनों से
///  • श्रेणी की चिप्पियाँ — अनाज / दलहन / तिलहन / सब्ज़ी / नक़दी
///  • बड़े कार्ड — चित्र 64px (पहले 36px था)
class CropPicker extends StatefulWidget {
  /// अभी कौन-सी फ़सल चुनी हुई है (उस पर निशान लगेगा)
  final Crop? selected;
  final ValueChanged<Crop> onPicked;

  const CropPicker({super.key, this.selected, required this.onPicked});

  @override
  State<CropPicker> createState() => _CropPickerState();
}

class _CropPickerState extends State<CropPicker> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  CropGroup? _group;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isHi => AppLocalizations.isHindiLike(context);

  /// चुनी हुई भाषा का कोड — नाम के अनुवाद के लिए
  String get _lang => AppLocalizations.langCode(context);

  List<Crop> get _filtered => kCrops
      .where((c) => cropMatches(c, _query))
      .where((c) => _group == null || cropGroup(c.id) == _group)
      .toList();

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              childAspectRatio: 0.92,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => _cropCard(list[i]),
          ),
      ],
    );
  }

  Widget _searchBar() => TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: _isHi ? 'फ़सल खोजें… (गेहूं, gehu, wheat)' : 'Search crop…',
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
            for (final g in CropGroup.values) _chip(g, g.label(_isHi)),
          ],
        ),
      );

  Widget _chip(CropGroup? g, String label) {
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
              _isHi ? 'यह फ़सल नहीं मिली' : 'No crop found',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );

  Widget _cropCard(Crop c) {
    final on = widget.selected?.id == c.id;
    final img = cropImage(c.id);
    return Material(
      color: on ? DairyTheme.primaryTeal.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => widget.onPicked(c),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: on ? DairyTheme.primaryTeal : Colors.grey.shade300,
              width: on ? 2.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 64,
                  child: img == null
                      ? Text(cropEmoji(c.id), style: const TextStyle(fontSize: 44))
                      : Image.asset(
                          img,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Text(cropEmoji(c.id), style: const TextStyle(fontSize: 44)),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.name(_isHi, _lang),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: on ? FontWeight.bold : FontWeight.w600,
                    color: on ? DairyTheme.primaryTeal : Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.seasonName(_isHi),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// पूरी screen के रूप में — जहाँ से भी फ़सल चुनवानी हो।
/// चुनी हुई फ़सल `Navigator.pop` से वापस आती है।
class CropPickerScreen extends StatelessWidget {
  final Crop? selected;
  const CropPickerScreen({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    return Scaffold(
      backgroundColor: DairyTheme.creamBg,
      appBar: AppBar(title: Text(isHi ? 'फ़सल चुनिए' : 'Choose crop')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: CropPicker(
            selected: selected,
            onPicked: (c) => Navigator.pop(context, c),
          ),
        ),
      ),
    );
  }
}
