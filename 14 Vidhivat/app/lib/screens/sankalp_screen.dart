import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:share_plus/share_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// संकल्प जनरेटर — **ऐप का सबसे बड़ा हथियार।**
///
/// हर पूजा संकल्प से शुरू होती है, और उसमें आज का संवत्, अयन, ऋतु, मास,
/// पक्ष, तिथि, वार, नक्षत्र सब बोलना पड़ता है। यहीं हर आदमी अटकता है।
///
/// हमारे पास पंचांग इंजन है, इसलिए यह वाक्य अपने आप बन जाता है — बस
/// नाम, गोत्र और काम चुनना है।
class SankalpScreen extends StatefulWidget {
  const SankalpScreen({super.key});

  @override
  State<SankalpScreen> createState() => _SankalpScreenState();
}

class _SankalpScreenState extends State<SankalpScreen> {
  String _purposeLabel = 'नित्य पूजा';
  bool _showFull = true;

  Future<void> _openPeopleManager() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _SankalpPeopleManager(
        onChanged: () {
          if (mounted) setState(() {});
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final day = DateTime.now();
    final p = settings.panchangFor(day);

    if (!settings.hasSankalpPerson) {
      return NaamPoochho(onDone: () => setState(() {}));
    }
    final person = settings.activeSankalpPerson!;

    final sankalp = buildSankalp(
      p,
      SankalpDetails(
        name: person.name,
        gotra: person.gotra,
        place: settings.city.name,
        purpose: commonPurposes[_purposeLabel] ?? 'देवपूजनं',
      ),
    );

    final text = _showFull ? sankalp.full : sankalp.simple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('संकल्प'),
        actions: [
          VidhivatIconAction(
            tooltip: 'संकल्प के लोग',
            onPressed: _openPeopleManager,
            icon: Icons.manage_accounts_outlined,
          ),
          VidhivatIconAction(
            tooltip: 'नक़ल करो',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('संकल्प नक़ल हो गया')),
              );
            },
            icon: Icons.copy_outlined,
          ),
          VidhivatIconAction(
            tooltip: 'भेजो',
            onPressed: () => SharePlus.instance.share(ShareParams(text: text)),
            icon: Icons.share_outlined,
          ),
        ],
      ),
      body: VidhivatSacredBackdrop(
        child: Panna(
          children: [
            VidhivatSacredHero(
              eyebrow: '${tarikh(day)} · ${settings.city.name}',
              title: 'संकल्प',
              subtitle:
                  '${p.varaName} · ${p.masaFullName} ${p.pakshaName} ${p.tithi.name}',
              icon: Icons.auto_awesome_outlined,
              compact: true,
              semanticLabel: 'आज का संकल्प, ${tarikh(day)}',
            ),
            const SizedBox(height: VidhivatSpacing.xl),

            // ── किस काम का संकल्प ──
            const VidhivatSectionHeader(title: 'किस काम का संकल्प?'),
            const SizedBox(height: VidhivatSpacing.sm),
            Wrap(
              spacing: VidhivatSpacing.xs,
              runSpacing: VidhivatSpacing.xs,
              children: [
                for (final label in commonPurposes.keys)
                  ChoiceChip(
                    label: Text(label),
                    selected: _purposeLabel == label,
                    onSelected: (_) => setState(() => _purposeLabel = label),
                  ),
              ],
            ),
            const SizedBox(height: VidhivatSpacing.xl),

            // ── पूरा या सरल ──
            _SankalpFormatSelector(
              showFull: _showFull,
              onChanged: (value) => setState(() => _showFull = value),
            ),
            const SizedBox(height: VidhivatSpacing.lg),
            const _SankalpVisualIntro(),
            const SizedBox(height: VidhivatSpacing.lg),

            // ── संकल्प का पाठ — बहुत बड़े अक्षरों में ──
            //
            // आदमी ज़मीन पर बैठा है, हाथ में जल है, फ़ोन दो फ़ुट दूर।
            // यहाँ छोटा फ़ॉन्ट किसी काम का नहीं।
            VidhivatSurfaceCard(
              variant: VidhivatCardVariant.elevated,
              semanticLabel: 'बना हुआ ${_showFull ? 'पूरा' : 'सरल'} संकल्प',
              child: SelectableText(
                text,
                style: type.mantra.copyWith(
                  fontSize: type.bodyLarge.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: VidhivatSpacing.lg),

            if (sankalp.needsPanditReview)
              const Chetavni(
                'यह संकल्प पंचांग से अपने आप बना है। संस्कृत का रूप अभी '
                'पंडित जी से जाँचा नहीं गया — पहली बार किसी जानकार से मिला लें।',
                serious: true,
              ),

            // ── हिस्सों में — साथ-साथ बोलने के लिए ──
            const VidhivatSectionHeader(
              title: 'हिस्सों में',
              supportingText: 'एक-एक करके बोलना हो तो',
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final part in sankalp.parts)
                    Pankti(part.label, part.value),
                ],
              ),
            ),
            const SizedBox(height: VidhivatSpacing.xl),

            VidhivatSurfaceCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('${person.name} · ${person.gotra} गोत्र'),
                subtitle: Text(
                  person.isDefaultProfile
                      ? 'आपका default profile · बदलने के लिए दबाएँ'
                      : 'अभी इसी व्यक्ति के नाम से संकल्प बन रहा है · बदलने के लिए दबाएँ',
                ),
                onTap: _openPeopleManager,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// संकल्प को किसी deity artwork से नहीं, उसके अपने household ritual cues से
/// पहचान देता है। यह सजावटी है; असल संकल्प, पंचांग और warning नीचे वाले
/// factual widgets ही दिखाते हैं।
class _SankalpVisualIntro extends StatelessWidget {
  const _SankalpVisualIntro();

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.elevated,
      semanticLabel: 'संकल्प की तैयारी का सजावटी चित्र',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360 || textScale > 1.25;
          final artworkWidth = compact ? 88.0 : 116.0;
          final pixelRatio = MediaQuery.devicePixelRatioOf(context);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'आज का आपका संकल्प',
                      style: type.cardTitle.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: VidhivatSpacing.xs),
                    Text(
                      'नाम, गोत्र और आज के पंचांग को साथ रखकर शांत मन से पाठ करें।',
                      style: type.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VidhivatSpacing.sm),
              ExcludeSemantics(
                child: SizedBox(
                  width: artworkWidth,
                  height: compact ? 118 : 136,
                  child: Image.asset(
                    'assets/images/devotional/sankalp_ritual.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    cacheWidth: (artworkWidth * pixelRatio).round(),
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// एक ही घर के अलग-अलग लोगों के लिए, बिना account या server के, स्थानीय
/// संकल्प-profile switcher.
class _SankalpPeopleManager extends StatefulWidget {
  final VoidCallback onChanged;

  const _SankalpPeopleManager({required this.onChanged});

  @override
  State<_SankalpPeopleManager> createState() => _SankalpPeopleManagerState();
}

class _SankalpPeopleManagerState extends State<_SankalpPeopleManager> {
  Future<void> _addPerson() async {
    final draft = await showDialog<_SankalpPersonDraft>(
      context: context,
      builder: (_) => const _SankalpPersonEditor(),
    );
    if (draft == null) return;

    await settings.addSankalpPerson(name: draft.name, gotra: draft.gotra);
    if (!mounted) return;
    setState(() {});
    widget.onChanged();
  }

  Future<void> _removePerson(SankalpPerson person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('यह व्यक्ति हटाएँ?'),
        content: Text(
          '“${person.name}” का नाम और गोत्र केवल इस फ़ोन से हटेगा।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('रहने दें'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('हटाएँ'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await settings.removeSankalpPerson(person.id);
    if (!mounted) return;
    setState(() {});
    widget.onChanged();
  }

  Future<void> _clearPeople() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('सभी लोग हटाएँ?'),
        content: const Text(
          'इस फ़ोन के सभी संकल्प profiles हट जाएँगे। यह वापस नहीं होगा।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('रहने दें'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('सभी हटाएँ'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await settings.clearSankalpPeople();
    if (!mounted) return;
    widget.onChanged();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final people = settings.sankalpPeople;
    final activeId = settings.activeSankalpPerson?.id;
    final colors = VidhivatTheme.colorsOf(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Panna(
          children: [
            Text(
              'संकल्प करने वाला व्यक्ति',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(
              'जिस व्यक्ति का नाम चुनेंगे, संकल्प में वही नाम और गोत्र आएगा।',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: VidhivatSpacing.lg),
            for (final person in people)
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(
                    person.isDefaultProfile
                        ? Icons.person_outline
                        : Icons.person_2_outlined,
                  ),
                  title: Text(person.name),
                  subtitle: Text(
                    '${person.gotra} गोत्र${person.isDefaultProfile ? ' · default profile' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (person.id == activeId)
                        Icon(Icons.check_circle, color: colors.success),
                      IconButton(
                        tooltip: '${person.name} को हटाएँ',
                        onPressed: () => _removePerson(person),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  selected: person.id == activeId,
                  onTap: () async {
                    await settings.selectSankalpPerson(person.id);
                    if (!mounted) return;
                    setState(() {});
                    widget.onChanged();
                  },
                ),
              ),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatButton(
              label: 'नया व्यक्ति जोड़ें',
              icon: Icons.person_add_alt_1_outlined,
              onPressed: _addPerson,
              fullWidth: true,
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            TextButton.icon(
              onPressed: people.isEmpty ? null : _clearPeople,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('सभी profiles हटाएँ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SankalpPersonDraft {
  final String name;
  final String gotra;

  const _SankalpPersonDraft({required this.name, required this.gotra});
}

/// यह नामों के लिए एक local phonetic *suggestion* है, अनुवाद नहीं। इसलिए
/// English input पर दूसरा editable field हमेशा दिखता है और user की पुष्टि
/// के बिना वही spelling संकल्प में नहीं जाती।
String _suggestHindiName(String raw) => raw.replaceAllMapped(
      RegExp(r'[A-Za-z]+'),
      (match) => _transliterateLatinWord(match.group(0)!),
    );

String _transliterateLatinWord(String word) {
  const consonants = <String, String>{
    'ksh': 'क्ष',
    'chh': 'छ',
    'sh': 'श',
    'kh': 'ख',
    'gh': 'घ',
    'ch': 'च',
    'jh': 'झ',
    'th': 'थ',
    'dh': 'ध',
    'ph': 'फ',
    'bh': 'भ',
    'ng': 'ङ',
    'ny': 'ञ',
    't': 'त',
    'd': 'द',
    'n': 'न',
    'p': 'प',
    'b': 'ब',
    'm': 'म',
    'y': 'य',
    'r': 'र',
    'l': 'ल',
    'v': 'व',
    'w': 'व',
    's': 'स',
    'h': 'ह',
    'g': 'ग',
    'j': 'ज',
    'f': 'फ',
    'q': 'क',
    'x': 'क्स',
    'z': 'ज़',
    'c': 'क',
  };
  const vowels = <String, (String, String)>{
    'aa': ('आ', 'ा'),
    'ai': ('ऐ', 'ै'),
    'au': ('औ', 'ौ'),
    'ee': ('ई', 'ी'),
    'ii': ('ई', 'ी'),
    'oo': ('ऊ', 'ू'),
    'uu': ('ऊ', 'ू'),
    'a': ('अ', ''),
    'i': ('इ', 'ि'),
    'u': ('उ', 'ु'),
    'e': ('ए', 'े'),
    'o': ('ओ', 'ो'),
  };
  const consonantKeys = [
    'ksh',
    'chh',
    'sh',
    'kh',
    'gh',
    'ch',
    'jh',
    'th',
    'dh',
    'ph',
    'bh',
    'ng',
    'ny',
    't',
    'd',
    'n',
    'p',
    'b',
    'm',
    'y',
    'r',
    'l',
    'v',
    'w',
    's',
    'h',
    'g',
    'j',
    'f',
    'q',
    'x',
    'z',
    'c',
  ];
  const vowelKeys = [
    'aa',
    'ai',
    'au',
    'ee',
    'ii',
    'oo',
    'uu',
    'a',
    'i',
    'u',
    'e',
    'o'
  ];

  final lower = word.toLowerCase();
  final out = StringBuffer();
  var index = 0;
  while (index < lower.length) {
    final consonant = _startingKey(lower, index, consonantKeys);
    if (consonant != null) {
      out.write(consonants[consonant]);
      index += consonant.length;
      final vowel = _startingKey(lower, index, vowelKeys);
      if (vowel != null) {
        out.write(vowels[vowel]!.$2);
        index += vowel.length;
      } else if (_startingKey(lower, index, consonantKeys) != null) {
        // Chandan जैसे नामों में n + d एक संयुक्त अक्षर है: न् + द = न्द।
        // यह फिर भी सुझाव ही है; नीचे user अपनी spelling बदल सकता है।
        out.write('्');
      }
      continue;
    }

    final vowel = _startingKey(lower, index, vowelKeys);
    if (vowel != null) {
      out.write(vowels[vowel]!.$1);
      index += vowel.length;
    } else {
      out.write(word[index]);
      index++;
    }
  }
  return out.toString();
}

String? _startingKey(String text, int start, List<String> keys) {
  for (final key in keys) {
    if (text.startsWith(key, start)) return key;
  }
  return null;
}

class _SankalpPersonEditor extends StatefulWidget {
  const _SankalpPersonEditor();

  @override
  State<_SankalpPersonEditor> createState() => _SankalpPersonEditorState();
}

class _SankalpPersonEditorState extends State<_SankalpPersonEditor> {
  final _enteredName = TextEditingController();
  final _hindiName = TextEditingController();
  String _gotra = 'कश्यप';
  bool _hindiEdited = false;
  bool _useHindiSuggestion = true;

  bool get _needsHindiConfirmation =>
      RegExp(r'[A-Za-z]').hasMatch(_enteredName.text) &&
      !RegExp(r'[\u0900-\u097F]').hasMatch(_enteredName.text);

  void _onNameChanged() {
    if (_needsHindiConfirmation && !_hindiEdited) {
      _hindiName.text = _suggestHindiName(_enteredName.text);
    }
    if (!_needsHindiConfirmation) _hindiName.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _enteredName.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _enteredName
      ..removeListener(_onNameChanged)
      ..dispose();
    _hindiName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalName = _needsHindiConfirmation && _useHindiSuggestion
        ? _hindiName.text.trim()
        : _enteredName.text.trim();

    return AlertDialog(
      title: const Text('नया संकल्प व्यक्ति'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('नाम हिन्दी या English में लिख सकते हैं।'),
            const SizedBox(height: VidhivatSpacing.sm),
            TextField(
              controller: _enteredName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'नाम',
                hintText: 'जैसे — चन्दन सिंह / Chandan Singh',
                border: OutlineInputBorder(),
              ),
            ),
            if (_needsHindiConfirmation) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              TextField(
                controller: _hindiName,
                onChanged: (_) {
                  _hindiEdited = true;
                  _useHindiSuggestion = true;
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'संकल्प में जाने वाला हिन्दी नाम',
                  helperText: 'कृपया spelling देखकर confirm या सुधार लें।',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                'संकल्प में कौन-सा नाम आए?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('हिन्दी सुझाव')),
                  ButtonSegment(value: false, label: Text('English नाम')),
                ],
                selected: {_useHindiSuggestion},
                onSelectionChanged: (selection) {
                  setState(() => _useHindiSuggestion = selection.first);
                },
              ),
            ],
            const SizedBox(height: VidhivatSpacing.lg),
            Text('गोत्र', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: VidhivatSpacing.xs),
            Wrap(
              spacing: VidhivatSpacing.xs,
              runSpacing: VidhivatSpacing.xs,
              children: [
                for (final gotra in commonGotras)
                  ChoiceChip(
                    label: Text(gotra),
                    selected: _gotra == gotra,
                    onSelected: (_) => setState(() => _gotra = gotra),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('रहने दें'),
        ),
        FilledButton(
          onPressed: finalName.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    _SankalpPersonDraft(name: finalName, gotra: _gotra),
                  ),
          child: const Text('जोड़ें और चुनें'),
        ),
      ],
    );
  }
}

class _SankalpFormatSelector extends StatelessWidget {
  final bool showFull;
  final ValueChanged<bool> onChanged;

  const _SankalpFormatSelector({
    required this.showFull,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final baseBodySize =
        VidhivatTheme.typographyOf(context).bodyMedium.fontSize!;
    final useVertical = media.size.width < 360 ||
        media.textScaler.scale(baseBodySize) > baseBodySize * 1.25;

    if (useVertical) {
      return VidhivatSurfaceCard(
        padding: EdgeInsets.zero,
        child: RadioGroup<bool>(
          groupValue: showFull,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          child: const Column(
            children: [
              RadioListTile<bool>(
                value: true,
                title: Text('पूरा संकल्प'),
              ),
              RadioListTile<bool>(
                value: false,
                title: Text('सरल (हिंदी में)'),
              ),
            ],
          ),
        ),
      );
    }

    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('पूरा संकल्प')),
        ButtonSegment(value: false, label: Text('सरल (हिंदी में)')),
      ],
      selected: {showFull},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// नाम और गोत्र पूछने वाला पन्ना — एक बार भरो, फिर हमेशा याद।
///
/// विधि प्लेयर भी इसी को खोलता है, इसलिए यह सार्वजनिक है।
class NaamPoochho extends StatefulWidget {
  final VoidCallback onDone;

  const NaamPoochho({super.key, required this.onDone});

  @override
  State<NaamPoochho> createState() => NaamPoochhoState();
}

class NaamPoochhoState extends State<NaamPoochho> {
  late final _naam = TextEditingController(text: settings.name);
  final _hindiNaam = TextEditingController();
  late String _gotra = settings.gotra;
  bool _hindiNaamEdited = false;
  bool _useHindiSuggestion = true;

  bool get _needsHindiConfirmation =>
      RegExp(r'[A-Za-z]').hasMatch(_naam.text) &&
      !RegExp(r'[\u0900-\u097F]').hasMatch(_naam.text);

  String get _confirmedNaam => _needsHindiConfirmation && _useHindiSuggestion
      ? _hindiNaam.text.trim()
      : _naam.text.trim();

  @override
  void initState() {
    super.initState();
    // ⚠️ यह सुनना ज़रूरी है। बिना इसके "संकल्प बनाइए" वाला बटन नाम भरने
    // पर भी बंद रहता है — क्योंकि widget दोबारा बनता ही नहीं।
    // असली फ़ोन पर चलाने पर ही यह पकड़ में आया।
    _naam.addListener(_onNaamBadla);
    _onNaamBadla();
  }

  void _onNaamBadla() {
    if (_needsHindiConfirmation && !_hindiNaamEdited) {
      _hindiNaam.text = _suggestHindiName(_naam.text);
    }
    if (!_needsHindiConfirmation) _hindiNaam.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _naam.removeListener(_onNaamBadla);
    _naam.dispose();
    _hindiNaam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('संकल्प')),
      body: Panna(
        children: [
          Text('आपका नाम और गोत्र', style: theme.textTheme.headlineSmall),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            'संकल्प में यही बोला जाता है। एक बार भरिए — फिर हर बार अपने आप '
            'आ जाएगा।\n\nयह सिर्फ़ आपके फ़ोन में रहेगा, कहीं नहीं जाएगा।',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: VidhivatSpacing.xl),
          TextField(
            controller: _naam,
            style: VidhivatTheme.typographyOf(context).bodyLarge,
            decoration: const InputDecoration(
              labelText: 'नाम',
              hintText: 'जैसे — चन्दन सिंह',
              border: OutlineInputBorder(),
            ),
          ),
          if (_needsHindiConfirmation) ...[
            const SizedBox(height: VidhivatSpacing.sm),
            TextField(
              controller: _hindiNaam,
              onChanged: (_) {
                _hindiNaamEdited = true;
                _useHindiSuggestion = true;
                setState(() {});
              },
              style: VidhivatTheme.typographyOf(context).bodyLarge,
              decoration: const InputDecoration(
                labelText: 'संकल्प में जाने वाला हिन्दी नाम',
                helperText:
                    'यह सुझाव है — spelling देखकर confirm या सुधार लें।',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(
              'संकल्प में कौन-सा नाम आए?',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('हिन्दी सुझाव')),
                ButtonSegment(value: false, label: Text('English नाम')),
              ],
              selected: {_useHindiSuggestion},
              onSelectionChanged: (selection) {
                setState(() => _useHindiSuggestion = selection.first);
              },
            ),
          ],
          const SizedBox(height: VidhivatSpacing.xl),
          Text('गोत्र', style: theme.textTheme.titleMedium),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(
            'न पता हो तो "कश्यप" चुन लीजिए — यही आम चलन है।',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: VidhivatSpacing.sm),
          Wrap(
            spacing: VidhivatSpacing.xs,
            runSpacing: VidhivatSpacing.xs,
            children: [
              for (final g in commonGotras)
                ChoiceChip(
                  label: Text(g),
                  selected: _gotra == g,
                  onSelected: (_) => setState(() => _gotra = g),
                ),
            ],
          ),
          const SizedBox(height: VidhivatSpacing.lg),
          VidhivatButton(
            label: 'संकल्प बनाइए',
            onPressed: _confirmedNaam.isEmpty
                ? null
                : () async {
                    await settings.setYajman(
                      name: _confirmedNaam,
                      gotra: _gotra,
                    );
                    widget.onDone();
                  },
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
