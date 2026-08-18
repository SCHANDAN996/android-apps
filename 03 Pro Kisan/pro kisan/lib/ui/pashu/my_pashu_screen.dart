import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../db/dao/pashu_dao.dart';
import '../../db/models/pashu.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../services/pashu_photo_service.dart';
import '../theme/dairy_theme.dart';

/// मेरे पशु — किसान की गाय/भैंस की सूची + ब्याने का रिमाइंडर + फोटो।
///
/// यही feature किसान को रोज़ ऐप में वापस लाता है: गर्भाधान (AI) की तारीख़
/// डालते ही ब्याने की तारीख़ अपने आप निकलती है और 7 दिन पहले notification
/// चला जाता है। नाम optional — खाली छोड़ो तो "गाय #3" जैसा auto name।
class MyPashuScreen extends StatelessWidget {
  const MyPashuScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DairyTheme.creamBg,
        appBar: AppBar(title: Text(AppLocalizations.get(context, 'myPashu'))),
        body: const MyPashuListView(),
      );
}

/// सूची + "जोड़ें" बटन — पशु tab के अंदर भी यही इस्तेमाल होता है।
class MyPashuListView extends StatefulWidget {
  const MyPashuListView({super.key});

  @override
  State<MyPashuListView> createState() => _MyPashuListViewState();
}

class _MyPashuListViewState extends State<MyPashuListView> {
  final _dao = PashuDao();
  List<Pashu> _list = [];
  bool _loading = true;

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _dao.getAll();
    if (!mounted) return;
    setState(() {
      _list = list;
      _loading = false;
    });
  }

  static const _months = [
    '', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुल', 'अग', 'सित', 'अक्टू', 'नव', 'दिस'
  ];
  String _fmt(DateTime d) => '${d.day} ${_months[d.month]} ${d.year}';

  IconData _icon(String type) => switch (type) {
        'bakri' => Icons.cruelty_free_rounded,
        _ => Icons.pets_rounded,
      };

  String _typeLabel(String type) => switch (type) {
        'bhains' => _t('pashuBhains'),
        'bakri' => _t('pashuBakri'),
        'bhed' => _t('pashuBhed'),
        'suar' => _t('pashuSuar'),
        'fish' || 'machhli' => _t('pashuFish'),
        'bee' || 'beekeeping' => _t('pashuBee'),
        'murgi' || 'broiler' => _t('pashuMurgi'),
        _ => _t('pashuGaay'),
      };

  /// नाम खाली हो तो "गाय #3", "भैंस #7" जैसा दिखाओ — id से आता है।
  String _displayName(Pashu p) {
    final n = p.trimmedName;
    if (n.isNotEmpty) return n;
    return '${_typeLabel(p.type)} #${p.id ?? '?'}';
  }

  Future<void> _openForm({Pashu? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PashuForm(existing: existing),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmDelete(Pashu p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_t('pashuDeleteConfirm')),
        content: Text(_displayName(p)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false), child: Text(_t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(_t('pashuDelete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && p.id != null) {
      await _dao.deactivate(p.id!);
      await NotificationService.instance.cancelPashuReminder(p.id!);
      // photo file cleanup — soft delete, पर storage खाली रहे
      await PashuPhotoService.deleteIfExists(p.photoPath);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ यह Stack है, Scaffold नहीं — इसलिए नीचे वाली पट्टी (3-बटन वाला
    // navigation bar) की जगह अपने आप नहीं छूटती। तय 20 रखने पर असली फ़ोन
    // पर "पशु जोड़ें" बटन पट्टी के पीछे चला जाता था और आधा कट जाता था।
    final neecheKiPatti = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Positioned.fill(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _list.isEmpty
                  ? _empty()
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          16, 16, 16, 96 + neecheKiPatti),
                      itemCount: _list.length,
                      itemBuilder: (_, i) => _card(_list[i]),
                    ),
        ),
        Positioned(
          right: 16,
          bottom: 20 + neecheKiPatti,
          child: FloatingActionButton.extended(
            heroTag: 'addPashu',
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text(_t('pashuAdd')),
          ),
        ),
      ],
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets_rounded, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(_t('myPashuEmpty'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(_t('myPashuEmptyHint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
            ],
          ),
        ),
      );

  Widget _card(Pashu p) {
    final calving = p.expectedCalving;
    final days = p.daysToCalving;

    // रंग की भाषा: हरा = ठीक, नारंगी = पास आ रहा, लाल = तारीख़ निकल गई
    Color statusColor = Colors.grey;
    String statusText = _t('pashuNoAi');
    if (calving != null && days != null) {
      if (days < 0) {
        statusColor = Colors.red.shade700;
        statusText = '${_fmt(calving)} · ${_t('pashuOverdue')}';
      } else if (days == 0) {
        statusColor = Colors.red.shade700;
        statusText = _t('pashuToday');
      } else {
        statusColor = days <= 15 ? Colors.orange.shade800 : DairyTheme.primaryTeal;
        statusText = '${_fmt(calving)} · $days ${_t('pashuDaysLeft')}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openForm(existing: p),
        onLongPress: () => _confirmDelete(p),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _thumb(p),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(_displayName(p),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                        ),
                        Text(_typeLabel(p.type),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.event_rounded, size: 17, color: statusColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(statusText,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor)),
                        ),
                      ],
                    ),
                    if (p.tagNo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text('🏷️ ${p.tagNo}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// photo thumbnail — फ़ाइल हो तो असली फोटो, वरना icon।
  Widget _thumb(Pashu p) {
    // DB में सिर्फ़ फ़ाइल का नाम है — फ़ोल्डर यहाँ जुड़ता है।
    // (पुराने पूरे रास्ते भी चलते हैं, देखें PashuPhotoService)
    final path = PashuPhotoService.fullPathSync(p.photoPath);
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          // corrupt file / rebuilt bytes: fallback icon
          errorBuilder: (_, __, ___) => _iconThumb(p.type),
        ),
      );
    }
    return _iconThumb(p.type);
  }

  Widget _iconThumb(String type) {
    final imgPath = switch (type) {
      'bhains' => 'assets/images/3d_buffalo_profile.webp',
      'bakri' => 'assets/images/3d_goat.webp',
      'bhed' => 'assets/images/3d_sheep.webp',
      'suar' => 'assets/images/3d_pig.webp',
      'fish' || 'machhli' => 'assets/images/3d_fish.webp',
      'bee' || 'beekeeping' => 'assets/images/3d_beekeeping.webp',
      'murgi' || 'broiler' => 'assets/images/3d_broiler.webp',
      'gaay' || 'cow' => 'assets/images/3d_cow_profile.webp',
      _ => 'assets/images/3d_cattle.webp',
    };
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: DairyTheme.accentBrown.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        imgPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(_icon(type), color: DairyTheme.accentBrown, size: 28),
      ),
    );
  }
}

/// जोड़ने/बदलने का फ़ॉर्म — bottom sheet में, ताकि एक ही screen पर काम पूरा हो।
class _PashuForm extends StatefulWidget {
  final Pashu? existing;
  const _PashuForm({this.existing});

  @override
  State<_PashuForm> createState() => _PashuFormState();
}

class _PashuFormState extends State<_PashuForm> {
  final _dao = PashuDao();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _tag =
      TextEditingController(text: widget.existing?.tagNo ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  late String _type = widget.existing?.type ?? 'gaay';
  late DateTime? _aiDate = widget.existing?.aiDate == null
      ? null
      : DateTime.tryParse(widget.existing!.aiDate!);
  late DateTime? _vaccineDate = widget.existing?.lastVaccineDate == null
      ? null
      : DateTime.tryParse(widget.existing!.lastVaccineDate!);

  /// current photo path — जब user बदलेगा तब यहीं update करते हैं। null मतलब हटाया गया।
  late String? _photoPath = widget.existing?.photoPath;

  /// यह session में जोड़ी नई फ़ोटो का path — save fail हुआ तो cleanup कर सकें।
  String? _newPhotoTemp;

  bool _saving = false;

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  void dispose() {
    _name.dispose();
    _tag.dispose();
    _note.dispose();
    super.dispose();
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isAi) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isAi ? _aiDate : _vaccineDate) ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 2),
      helpText: _t('pashuPickDate'),
    );
    if (picked == null) return;
    setState(() {
      if (isAi) {
        _aiDate = picked;
      } else {
        _vaccineDate = picked;
      }
    });
  }

  Future<void> _choosePhotoSource() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      useSafeArea: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: DairyTheme.primaryTeal),
              title: Text(_t('photoCamera')),
              onTap: () => Navigator.pop(c, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: DairyTheme.primaryTeal),
              title: Text(_t('photoGallery')),
              onTap: () => Navigator.pop(c, ImageSource.gallery),
            ),
            if (_photoPath != null || _newPhotoTemp != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text(_t('pashuRemovePhoto'),
                    style: const TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(c, null),
              ),
          ],
        ),
      ),
    );

    // user tapped "Remove" (result = null but sheet closed via nav.pop(c, null))
    // vs. tapped outside (also null). Distinguish by whether sheet had a Remove item
    // — simplest: check what user chose using a separate flow. Do a two-step:
    if (!mounted) return;

    if (choice == null) {
      // If there was a photo before, treat null as "remove". If there was none,
      // user just dismissed — do nothing.
      if (_photoPath != null || _newPhotoTemp != null) {
        // cleanup: delete the temp new photo we might've added earlier in session
        if (_newPhotoTemp != null) {
          await PashuPhotoService.deleteIfExists(_newPhotoTemp);
          _newPhotoTemp = null;
        }
        setState(() => _photoPath = null);
      }
      return;
    }

    final path = await PashuPhotoService.pickAndSave(source: choice);
    if (path == null) return; // user cancelled system picker

    // Clean up previous temp (unsaved) photo if we're replacing it
    if (_newPhotoTemp != null) {
      await PashuPhotoService.deleteIfExists(_newPhotoTemp);
    }
    setState(() {
      _newPhotoTemp = path;
      _photoPath = path;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    // पुरानी photo अगर user ने बदल दी हो, तो store से हटा दो
    final oldPhoto = widget.existing?.photoPath;
    if (oldPhoto != null && oldPhoto != _photoPath) {
      await PashuPhotoService.deleteIfExists(oldPhoto);
    }

    final p = Pashu(
      id: widget.existing?.id,
      name: _name.text.trim(),
      type: _type,
      tagNo: _tag.text.trim(),
      aiDate: _aiDate == null ? null : _iso(_aiDate!),
      lastVaccineDate: _vaccineDate == null ? null : _iso(_vaccineDate!),
      note: _note.text.trim(),
      photoPath: _photoPath,
      createdAt: widget.existing?.createdAt,
    );

    int id;
    if (p.id == null) {
      id = await _dao.insert(p);
    } else {
      await _dao.update(p);
      id = p.id!;
    }

    // ब्याने का रिमाइंडर लगाओ (AI तारीख़ हो तभी)
    //
    // ⚠️ यह **कभी** save को नहीं रोकना चाहिए। पशु ऊपर database में लिखा जा
    // चुका है — असली काम वही है। रिमाइंडर दूसरे नंबर पर है।
    //
    // 9 अगस्त 2026 को असली फ़ोन पर यही टूटा था: notification वाला plugin
    // release build में `Missing type parameter.` फेंकता था (देखें
    // `android/app/proguard-rules.pro`), अपवाद यहाँ तक चढ़ आता था, और
    // `_saving` कभी false नहीं होता — बटन हमेशा घूमता रह जाता और screen
    // बंद ही नहीं होती। पशु सेव हो चुका होता, पर किसान को यह पता ही नहीं
    // चलता; उसे ऐप बंद करनी पड़ती।
    //
    // असली वजह proguard नियम से ठीक हो गई है। यह पकड़ दूसरी दीवार है —
    // ताकि किसी भी फ़ोन पर, किसी भी वजह से रिमाइंडर न लगे, तब भी किसान
    // फँसे नहीं।
    final saved = p.copyWith(id: id);
    final calving = saved.expectedCalving;
    var reminderLaga = false;

    if (calving != null) {
      try {
        // nameless पशु के लिए भी notification में समझ आने वाला label
        final labelName = saved.trimmedName.isNotEmpty
            ? saved.trimmedName
            : '${_typeLabelFor(_type)} #$id';
        await NotificationService.instance.schedulePashuCalvingReminder(
          pashuId: id,
          pashuName: labelName,
          calvingDate: calving,
        );
        reminderLaga = true;
      } catch (e) {
        debugPrint('ब्याने का रिमाइंडर नहीं लग सका: $e');
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (reminderLaga) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_t('pashuReminderSet'))));
    }
    Navigator.pop(context, true);
  }

  String _typeLabelFor(String type) => switch (type) {
        'bhains' => _t('pashuBhains'),
        'bakri' => _t('pashuBakri'),
        _ => _t('pashuGaay'),
      };

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final calving = Pashu(
      type: _type,
      aiDate: _aiDate == null ? null : _iso(_aiDate!),
    ).expectedCalving;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, 22 + MediaQuery.of(context).padding.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                  widget.existing == null
                      ? _t('pashuAdd')
                      : _t('pashuEdit'),
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),

              // ── Photo picker (केंद्रित, बड़ा circle) ──
              Center(child: _photoPicker()),
              const SizedBox(height: 18),

              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _t('pashuNameOptional'),
                  hintText: _t('pashuNameHint'),
                  helperText: _t('pashuAutoName'),
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 14),

              Text(_t('pashuType'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in const [
                    ['gaay', 'pashuGaay'],
                    ['bhains', 'pashuBhains'],
                    ['bakri', 'pashuBakri'],
                    ['bhed', 'pashuBhed'],
                    ['suar', 'pashuSuar'],
                    ['murgi', 'pashuMurgi'],
                    ['fish', 'pashuFish'],
                    ['bee', 'pashuBee'],
                  ])
                    ChoiceChip(
                      label: Text(_t(e[1])),
                      selected: _type == e[0],
                      showCheckmark: false,
                      selectedColor: DairyTheme.primaryTeal,
                      labelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _type == e[0]
                              ? Colors.white
                              : Colors.grey.shade800),
                      onSelected: (_) => setState(() => _type = e[0]),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              _dateField(_t('pashuAiDate'), _aiDate, () => _pickDate(true)),
              if (calving != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DairyTheme.primaryTeal.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded,
                          color: DairyTheme.primaryTeal, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_t('pashuCalvingOn')}: ${calving.day}/${calving.month}/${calving.year}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: DairyTheme.primaryTeal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              _dateField(
                  _t('pashuVaccineDate'), _vaccineDate, () => _pickDate(false)),
              const SizedBox(height: 14),

              TextField(
                controller: _tag,
                decoration: InputDecoration(labelText: _t('pashuTag')),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: InputDecoration(labelText: _t('pashuNote')),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white))
                    : const Icon(Icons.check_rounded),
                label: Text(_t('pashuSave')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// बड़ा circular photo — tap करके camera/gallery पिकर खुले।
  Widget _photoPicker() {
    final resolved = PashuPhotoService.fullPathSync(_photoPath);
    final hasPhoto = resolved != null && File(resolved).existsSync();

    return Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: _choosePhotoSource,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: hasPhoto
                  ? Colors.transparent
                  : DairyTheme.primaryTeal.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.35),
                  width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? Image.file(File(_photoPath!), fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _addPhotoHint())
                : _addPhotoHint(),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: DairyTheme.primaryTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
              ],
            ),
            child: Icon(
              hasPhoto ? Icons.edit_rounded : Icons.photo_camera_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoHint() {
    final imgPath = switch (_type) {
      'bhains' => 'assets/images/3d_buffalo_profile.webp',
      'bakri' => 'assets/images/3d_goat.webp',
      'bhed' => 'assets/images/3d_sheep.webp',
      'suar' => 'assets/images/3d_pig.webp',
      'fish' || 'machhli' => 'assets/images/3d_fish.webp',
      'bee' || 'beekeeping' => 'assets/images/3d_beekeeping.webp',
      'murgi' || 'broiler' => 'assets/images/3d_broiler.webp',
      _ => 'assets/images/3d_cow_profile.webp',
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            imgPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.add_a_photo_rounded,
                color: DairyTheme.primaryTeal, size: 32),
          ),
        ),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_camera_rounded,
                  color: Colors.white, size: 26),
              const SizedBox(height: 2),
              Text(
                _t('pashuAddPhoto'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                size: 20, color: DairyTheme.primaryTeal),
            const SizedBox(width: 10),
            Text(
              value == null
                  ? _t('pashuPickDate')
                  : '${value.day}/${value.month}/${value.year}',
              style: TextStyle(
                  fontSize: 16,
                  color: value == null ? Colors.grey.shade600 : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
