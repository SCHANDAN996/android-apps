import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/strings.dart';
import '../core/models/project_item.dart';
import '../core/services/storage_service.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/indian_formatter.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/shared_widgets.dart';
import 'brick_screen.dart';
import 'concrete_screen.dart';
import 'excavation_screen.dart';
import 'paint_screen.dart';
import 'plaster_screen.dart';
import 'stairs_screen.dart';
import 'steel_screen.dart';
import 'tile_screen.dart';

/// "My House" — every calculation the user chose to keep, added up into one
/// shopping list and one bill. A mason can keep several houses side by side.
class ProjectScreen extends StatefulWidget {
  final StorageService storage;
  const ProjectScreen({super.key, required this.storage});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

/// Asks for one line of text or a rupee amount; pops with what was typed.
///
/// A widget of its own so the text controller lives exactly as long as the
/// dialog does — including its closing animation.
class _TextDialog extends StatefulWidget {
  final String title;
  final String initial;
  final bool number;

  const _TextDialog({
    required this.title,
    required this.initial,
    required this.number,
  });

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final number = widget.number;
    return AlertDialog(
      title: Text(widget.title, style: const TextStyle(fontSize: 18)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLength: number ? LargeInputField.maxDigits : 40,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters: [if (number) FilteringTextInputFormatter.digitsOnly],
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          counterText: '',
          prefixText: number ? '₹ ' : null,
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.get('cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(AppStrings.get('save')),
        ),
      ],
    );
  }
}

/// One line of the shopping list.
class _MaterialLine {
  final String emoji;
  final IconData icon;
  final String label;
  final String value;

  /// Key of this material's rate in `allRates`, if it is priced.
  final String? rateKey;

  const _MaterialLine(
    this.emoji,
    this.icon,
    this.label,
    this.value, [
    this.rateKey,
  ]);
}

class _ProjectScreenState extends State<ProjectScreen> {
  StorageService get _storage => widget.storage;

  late Project _project = _storage.currentProject;
  late List<ProjectItem> _items = _storage.projectItems;
  late double _labour = _storage.projectLabour;

  /// The part of the screen that becomes the bill picture.
  final _billKey = GlobalKey();

  /// True for the one frame the bill is photographed — hides the edit and
  /// remove buttons so they don't end up in the picture.
  bool _capturing = false;

  static const Map<String, String> _typeEmoji = {
    'brick': '🧱',
    'concrete': '🏗️',
    'steel': '⚙️',
    'plaster': '🪣',
    'tiles': '🔲',
    'paint': '🎨',
    'stairs': '🪜',
    'excavation': '⛏️',
  };

  String get _projectName => _nameOf(_project);

  String _nameOf(Project p) =>
      p.name.isEmpty ? AppStrings.get('myProject') : p.name;

  void _reload() {
    if (!mounted) return;
    setState(() {
      _project = _storage.currentProject;
      _items = _storage.projectItems;
      _labour = _storage.projectLabour;
    });
  }

  /// The materials the project actually needs — zero rows are left out.
  List<_MaterialLine> _lines(ProjectTotals t) => [
    if (t.bricks > 0)
      _MaterialLine(
        '🧱',
        Icons.view_comfy_alt_outlined,
        AppStrings.get('brickCount'),
        IndianFormatter.format(t.bricks.toDouble()),
        'brick',
      ),
    if (t.cementBags > 0)
      _MaterialLine(
        '📦',
        Icons.inventory_2_outlined,
        AppStrings.get('cementBags'),
        '${t.cementBags}',
        'cement',
      ),
    if (t.sandCft > 0)
      _MaterialLine(
        '🏖️',
        Icons.grain_outlined,
        AppStrings.get('sandCft'),
        IndianFormatter.format(t.sandCft.toDouble()),
        'sand',
      ),
    if (t.aggregateCft > 0)
      _MaterialLine(
        '🪨',
        Icons.landscape_outlined,
        AppStrings.get('aggregateCft'),
        IndianFormatter.format(t.aggregateCft.toDouble()),
        'aggregate',
      ),
    if (t.steelKg > 0)
      _MaterialLine(
        '⚙️',
        Icons.straighten_outlined,
        AppStrings.get('steelWeight'),
        '${IndianFormatter.format(t.steelKg, decimals: 1)} kg',
        'steel',
      ),
    if (t.tiles > 0)
      _MaterialLine(
        '🔲',
        Icons.grid_view_outlined,
        AppStrings.get('totalTiles'),
        IndianFormatter.format(t.tiles.toDouble()),
      ),
    if (t.tileBoxes > 0)
      _MaterialLine(
        '🔲',
        Icons.inventory_outlined,
        AppStrings.get('totalBoxes'),
        '${t.tileBoxes}',
        'tile',
      ),
    if (t.paintLitres > 0)
      _MaterialLine(
        '🎨',
        Icons.color_lens_outlined,
        AppStrings.get('paintLitres'),
        '${t.paintLitres.toStringAsFixed(1)} L',
        'paint',
      ),
    if (t.excavationCft > 0)
      _MaterialLine(
        '⛏️',
        Icons.terrain_outlined,
        AppStrings.get('excavationVolume'),
        '${IndianFormatter.format(t.excavationCft.toDouble())} cft',
      ),
  ];

  // --- Dialogs ---

  /// Asks for a line of text. Returns null when cancelled.
  Future<String?> _askText({
    required String title,
    String initial = '',
    bool number = false,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) =>
          _TextDialog(title: title, initial: initial, number: number),
    );
    return result?.trim();
  }

  Future<bool> _confirm(String title, String message) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.get('remove')),
          ),
        ],
      ),
    );
    return yes == true;
  }

  // --- Items ---

  Future<void> _removeItem(ProjectItem item) async {
    await _storage.removeProjectItem(item.id);
    _reload();
  }

  Future<void> _renameItem(ProjectItem item) async {
    final name = await _askText(
      title: AppStrings.get('itemName'),
      initial: item.name,
    );
    if (name == null) return;
    await _storage.renameProjectItem(item.id, name);
    _reload();
  }

  Future<void> _confirmClear() async {
    if (!await _confirm(
      AppStrings.get('clearAll'),
      AppStrings.get('clearAllConfirm'),
    )) {
      return;
    }
    await _storage.clearProject();
    _reload();
  }

  Future<void> _editLabour() async {
    final text = await _askText(
      title: '${AppStrings.get('labourCost')} (₹)',
      initial: _labour > 0 ? _labour.round().toString() : '',
      number: true,
    );
    if (text == null) return;
    await _storage.setProjectLabour(double.tryParse(text) ?? 0);
    _reload();
  }

  // --- Projects ---

  Future<void> _addProject() async {
    final name = await _askText(title: AppStrings.get('projectName'));
    if (name == null || name.isEmpty) return;
    await _storage.addProject(name);
    _reload();
  }

  Future<void> _renameProject(Project p) async {
    final name = await _askText(
      title: AppStrings.get('projectName'),
      initial: p.name,
    );
    if (name == null) return;
    await _storage.renameProject(p.id, name);
    _reload();
  }

  Future<void> _deleteProject(Project p) async {
    if (!await _confirm(
      '${AppStrings.get('deleteProject')}: ${_nameOf(p)}',
      AppStrings.get('deleteProjectConfirm'),
    )) {
      return;
    }
    await _storage.deleteProject(p.id);
    _reload();
  }

  void _showProjects() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final p in _storage.projects)
              ListTile(
                leading: Icon(
                  p.id == _project.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                title: Text(
                  _nameOf(p),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: AppStrings.get('rename'),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pop(sheet);
                        _renameProject(p);
                      },
                    ),
                    IconButton(
                      tooltip: AppStrings.get('deleteProject'),
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        Navigator.pop(sheet);
                        _deleteProject(p);
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(sheet);
                  await _storage.setCurrentProject(p.id);
                  _reload();
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_home_outlined),
              title: Text(AppStrings.get('newProject')),
              onTap: () {
                Navigator.pop(sheet);
                _addProject();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Sharing ---

  double _materialCost(ProjectTotals totals) =>
      totals.costs(_storage.allRates).values.fold<double>(0, (a, b) => a + b);

  String _itemTitle(ProjectItem item) =>
      item.name.isEmpty ? AppStrings.get(item.type) : item.name;

  String _buildShareText() {
    final totals = ProjectTotals(_items);
    final total = _materialCost(totals) + _labour;

    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🏠 $_projectName\n';
    for (final item in _items) {
      text +=
          '${_typeEmoji[item.type] ?? '•'} ${_itemTitle(item)}: ${item.detail}\n';
    }
    text += '\n📊 ${AppStrings.get('totalMaterial')}:\n';
    for (final line in _lines(totals)) {
      text += '${line.label}: ${line.value}\n';
    }
    if (_labour > 0) {
      text +=
          '${AppStrings.get('labourCost')}: ${IndianFormatter.formatCurrency(_labour)}\n';
    }
    if (total > 0) {
      text +=
          '\n💰 ${AppStrings.get('estimatedCost')}: ${IndianFormatter.formatCurrency(total)}\n';
    }
    text += AppStrings.get('shareFooter');
    return text;
  }

  /// Photographs the bill part of the screen and hands it to the share sheet.
  Future<void> _shareBillImage() async {
    setState(() => _capturing = true);
    await WidgetsBinding.instance.endOfFrame;
    try {
      final boundary =
          _billKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) return;
      await Share.shareXFiles(
        [XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png')],
        fileNameOverrides: const ['mistri_bill.png'],
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Opens a calculator from here and picks up whatever was added there.
  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: _showProjects,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _projectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, size: 28),
              ],
            ),
          ),
        ),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              tooltip: AppStrings.get('clearAll'),
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _confirmClear,
            ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: _items.isEmpty ? _buildEmpty() : _buildProject(),
      ),
    );
  }

  /// One tap to each calculator — the way to put something into the project.
  Widget _buildShortcuts() {
    final s = _storage;
    final shortcuts = <(String, Widget)>[
      ('brick', BrickScreen(storage: s)),
      ('concrete', ConcreteScreen(storage: s)),
      ('steel', SteelScreen(storage: s)),
      ('plaster', PlasterScreen(storage: s)),
      ('tiles', TileScreen(storage: s)),
      ('paint', PaintScreen(storage: s)),
      ('stairs', StairsScreen(storage: s)),
      ('excavation', ExcavationScreen(storage: s)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (type, screen) in shortcuts)
              SizedBox(
                width: width,
                child: OutlinedButton(
                  onPressed: () => _open(screen),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _typeEmoji[type]!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.get(type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Image.asset(
            'assets/images/house_estimate.webp',
            width: 130,
            height: 130,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              AppStrings.get('projectEmpty'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // What to look for on the calculator screen — the real button's
          // label, so the user recognises it there.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppStrings.get('addToProject'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildShortcuts(),
        ],
      ),
    );
  }

  Widget _buildItem(ProjectItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 8, _capturing ? 14 : 0, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(
              _typeEmoji[item.type] ?? '•',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _itemTitle(item),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      // A named item still says what kind of work it is.
                      item.name.isEmpty
                          ? item.detail
                          : '${AppStrings.get(item.type)} · ${item.detail}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_capturing) ...[
              IconButton(
                tooltip: AppStrings.get('rename'),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
                onPressed: () => _renameItem(item),
              ),
              IconButton(
                tooltip: AppStrings.get('remove'),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
                onPressed: () => _removeItem(item),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProject() {
    final totals = ProjectTotals(_items);
    final lines = _lines(totals);
    final costs = totals.costs(_storage.allRates);
    final materialCost = _materialCost(totals);
    final totalCost = materialCost + _labour;
    final ratesAge = _storage.ratesAgeDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Everything inside this boundary is the bill picture.
        RepaintBoundary(
          key: _billKey,
          child: Container(
            color: AppColors.background,
            padding: EdgeInsets.all(_capturing ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_capturing) ...[
                  Text(
                    _projectName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${AppStrings.get('appName')} · ${DateFormat('d MMM yyyy').format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // What the bill is made of
                SectionLabel(title: AppStrings.get('projectItems')),
                for (final item in _items) _buildItem(item),

                // The shopping list
                const SizedBox(height: 6),
                SectionLabel(title: AppStrings.get('totalMaterial')),
                FormSurface(
                  child: Column(
                    children: [
                      for (var i = 0; i < lines.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ResultRow(
                          label: lines[i].label,
                          value: lines[i].value,
                          icon: lines[i].icon,
                        ),
                      ],
                    ],
                  ),
                ),

                if (totalCost > 0) ...[
                  const SizedBox(height: 16),
                  CostCard(
                    totalCost: totalCost,
                    items: [
                      for (final line in lines)
                        if (costs.containsKey(line.rateKey))
                          CostItem(
                            '${line.emoji} ${line.label} (${line.value})',
                            costs[line.rateKey]!,
                          ),
                      if (_labour > 0)
                        CostItem('👷 ${AppStrings.get('labourCost')}', _labour),
                    ],
                  ),
                ],
                if (_capturing) const DisclaimerFooter(),
              ],
            ),
          ),
        ),

        // Old rates make a wrong bill — say so before it is sent.
        if (materialCost > 0 &&
            ratesAge != null &&
            ratesAge > StorageService.ratesStaleAfterDays)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('ratesOld').replaceAll('{n}', '$ratesAge'),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Labour — the half of the bill that is not material
        const SizedBox(height: 12),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _editLabour,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.engineering_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get('labourCost'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    _labour > 0 ? IndianFormatter.formatCurrency(_labour) : '₹',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _labour > 0
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _labour > 0 ? Icons.edit_outlined : Icons.add_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _capturing ? null : _shareBillImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              AppStrings.get('billImage'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ShareCopyButtons(
          onShare: () {
            Share.share(_buildShareText());
          },
          onCopy: () {
            Clipboard.setData(ClipboardData(text: _buildShareText()));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(AppStrings.get('copied'))));
          },
        ),

        // More to add
        const SizedBox(height: 20),
        SectionLabel(title: AppStrings.get('addToProject')),
        _buildShortcuts(),

        const DisclaimerFooter(),
      ],
    );
  }
}
