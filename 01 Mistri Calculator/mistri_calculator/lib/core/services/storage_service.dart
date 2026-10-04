import 'package:shared_preferences/shared_preferences.dart';

import '../math/brick_calculator.dart';
import '../models/project_item.dart';

/// Persists language, unit preference, rates, and calculation count.
class StorageService {
  late SharedPreferences _prefs;

  // Keys
  static const String _langKey = 'language';
  static const String _unitKey = 'default_unit';
  static const String _calcCountKey = 'calc_count';
  static const String _reviewShownKey = 'review_shown';
  static const String _projectsKey = 'projects';
  static const String _currentProjectKey = 'current_project';
  static const String _ratesUpdatedKey = 'rates_updated_at';

  // Brick size keys
  static const String _brickSizeIdKey = 'brick_size_id';
  static const String _brickLenKey = 'brick_len_mm';
  static const String _brickWidKey = 'brick_wid_mm';
  static const String _brickHgtKey = 'brick_hgt_mm';

  // Rate keys
  static const String _brickRateKey = 'rate_brick';
  static const String _cementRateKey = 'rate_cement';
  static const String _sandRateKey = 'rate_sand';
  static const String _aggregateRateKey = 'rate_aggregate';
  static const String _steelRateKey = 'rate_steel';
  static const String _tileRateKey = 'rate_tile';
  static const String _paintRateKey = 'rate_paint';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Language ---
  String get language => _prefs.getString(_langKey) ?? 'hi';
  Future<void> setLanguage(String lang) => _prefs.setString(_langKey, lang);

  // --- Theme ---
  /// 'system' (follow the phone), 'light' or 'dark'.
  String get themeMode => _prefs.getString('theme_mode') ?? 'system';
  Future<void> setThemeMode(String mode) =>
      _prefs.setString('theme_mode', mode);

  // --- Unit ---
  String get defaultUnit => _prefs.getString(_unitKey) ?? 'ft';
  Future<void> setDefaultUnit(String unit) => _prefs.setString(_unitKey, unit);

  // --- Calculation counter (for ad + review trigger) ---
  int get calcCount => _prefs.getInt(_calcCountKey) ?? 0;
  Future<void> incrementCalcCount() =>
      _prefs.setInt(_calcCountKey, calcCount + 1);

  // --- Review ---
  bool get reviewShown => _prefs.getBool(_reviewShownKey) ?? false;
  Future<void> setReviewShown() => _prefs.setBool(_reviewShownKey, true);

  // --- My House projects ---
  /// Every project, oldest first. There is always at least the default one.
  List<Project> get projects {
    final saved = [
      for (final s in _prefs.getStringList(_projectsKey) ?? const <String>[])
        ?Project.tryParse(s),
    ];
    return saved.isEmpty ? const [Project(id: Project.defaultId)] : saved;
  }

  Future<void> _saveProjects(List<Project> list) =>
      _prefs.setStringList(_projectsKey, [for (final p in list) p.toJson()]);

  /// The project new calculations are added to.
  Project get currentProject {
    final all = projects;
    final id = _prefs.getString(_currentProjectKey);
    return all.firstWhere((p) => p.id == id, orElse: () => all.first);
  }

  Future<void> setCurrentProject(String id) =>
      _prefs.setString(_currentProjectKey, id);

  /// Creates a project and switches to it.
  Future<Project> addProject(String name) async {
    final project = Project(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    await _saveProjects([...projects, project]);
    await setCurrentProject(project.id);
    return project;
  }

  Future<void> renameProject(String id, String name) => _saveProjects([
    for (final p in projects) p.id == id ? Project(id: id, name: name) : p,
  ]);

  /// Removes a project with everything in it. The last project is emptied
  /// instead, so there is always one to add to.
  Future<void> deleteProject(String id) async {
    await _prefs.remove(_itemsKey(id));
    await _prefs.remove(_labourKey(id));
    final rest = [...projects.where((p) => p.id != id)];
    if (rest.isEmpty) {
      await _prefs.remove(_projectsKey);
    } else {
      await _saveProjects(rest);
    }
  }

  // The default project keeps the key the single-project version used, so
  // what people saved before still shows up.
  static String _itemsKey(String projectId) => projectId == Project.defaultId
      ? 'project_items'
      : 'project_items_$projectId';
  static String _labourKey(String projectId) => 'project_labour_$projectId';

  /// The current project's saved calculations, oldest first. Entries that
  /// fail to parse are skipped.
  List<ProjectItem> get projectItems => [
    for (final s
        in _prefs.getStringList(_itemsKey(currentProject.id)) ??
            const <String>[])
      ?ProjectItem.tryParse(s),
  ];

  Future<void> _saveItems(List<ProjectItem> items) => _prefs.setStringList(
    _itemsKey(currentProject.id),
    [for (final i in items) i.toJson()],
  );

  Future<void> addProjectItem(ProjectItem item) =>
      _saveItems([...projectItems, item]);

  Future<void> removeProjectItem(String id) =>
      _saveItems([...projectItems.where((i) => i.id != id)]);

  Future<void> renameProjectItem(String id, String name) => _saveItems([
    for (final i in projectItems) i.id == id ? i.renamed(name) : i,
  ]);

  Future<void> clearProject() => _prefs.remove(_itemsKey(currentProject.id));

  /// Labour charge for the current project, in rupees. Zero when not set.
  double get projectLabour =>
      _prefs.getDouble(_labourKey(currentProject.id)) ?? 0;

  Future<void> setProjectLabour(double rupees) => rupees > 0
      ? _prefs.setDouble(_labourKey(currentProject.id), rupees)
      : _prefs.remove(_labourKey(currentProject.id));

  // --- When the rates were last saved ---
  DateTime? get ratesUpdatedAt {
    final ms = _prefs.getInt(_ratesUpdatedKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markRatesUpdated() =>
      _prefs.setInt(_ratesUpdatedKey, DateTime.now().millisecondsSinceEpoch);

  /// Days since the rates were saved; null if that was never recorded.
  int? get ratesAgeDays {
    final at = ratesUpdatedAt;
    return at == null ? null : DateTime.now().difference(at).inDays;
  }

  /// Prices move — after this many days the user is asked to re-check them.
  static const int ratesStaleAfterDays = 30;

  // --- Brick size ---
  /// Preset id ('desi', 'modular', 'big') or 'custom'. Defaults to desi.
  String get brickSizeId =>
      _prefs.getString(_brickSizeIdKey) ?? BrickSize.desi.id;
  Future<void> setBrickSizeId(String id) =>
      _prefs.setString(_brickSizeIdKey, id);

  /// The last custom size the user typed, if any.
  BrickSize? get customBrickSize {
    final l = _prefs.getDouble(_brickLenKey);
    final w = _prefs.getDouble(_brickWidKey);
    final h = _prefs.getDouble(_brickHgtKey);
    if (l == null || w == null || h == null) return null;
    return BrickSize.custom(l, w, h);
  }

  Future<void> setCustomBrickSize(BrickSize size) async {
    await _prefs.setDouble(_brickLenKey, size.lengthMm);
    await _prefs.setDouble(_brickWidKey, size.widthMm);
    await _prefs.setDouble(_brickHgtKey, size.heightMm);
  }

  /// The brick to start the screen with — the saved preset, or the saved
  /// custom size, falling back to the default brick.
  BrickSize get brickSize {
    final id = brickSizeId;
    if (id == BrickSize.customId) {
      return customBrickSize ?? BrickCalculator.defaultBrick;
    }
    return BrickSize.presetById(id) ?? BrickCalculator.defaultBrick;
  }

  // --- Rates ---
  double? get brickRate => _prefs.getDouble(_brickRateKey);
  double? get cementRate => _prefs.getDouble(_cementRateKey);
  double? get sandRate => _prefs.getDouble(_sandRateKey);
  double? get aggregateRate => _prefs.getDouble(_aggregateRateKey);
  double? get steelRate => _prefs.getDouble(_steelRateKey);
  double? get tileRate => _prefs.getDouble(_tileRateKey);
  double? get paintRate => _prefs.getDouble(_paintRateKey);

  Future<void> setBrickRate(double v) => _prefs.setDouble(_brickRateKey, v);
  Future<void> setCementRate(double v) => _prefs.setDouble(_cementRateKey, v);
  Future<void> setSandRate(double v) => _prefs.setDouble(_sandRateKey, v);
  Future<void> setAggregateRate(double v) =>
      _prefs.setDouble(_aggregateRateKey, v);
  Future<void> setSteelRate(double v) => _prefs.setDouble(_steelRateKey, v);
  Future<void> setTileRate(double v) => _prefs.setDouble(_tileRateKey, v);
  Future<void> setPaintRate(double v) => _prefs.setDouble(_paintRateKey, v);

  // Empty fields in My Rates mean that the user no longer wants that material
  // included in estimates. They must remove the stored value, not leave the
  // previous rate silently active.
  Future<void> clearBrickRate() => _prefs.remove(_brickRateKey);
  Future<void> clearCementRate() => _prefs.remove(_cementRateKey);
  Future<void> clearSandRate() => _prefs.remove(_sandRateKey);
  Future<void> clearAggregateRate() => _prefs.remove(_aggregateRateKey);
  Future<void> clearSteelRate() => _prefs.remove(_steelRateKey);
  Future<void> clearTileRate() => _prefs.remove(_tileRateKey);
  Future<void> clearPaintRate() => _prefs.remove(_paintRateKey);

  /// Returns a map of all set rates (non-null only).
  Map<String, double> get allRates {
    final rates = <String, double>{};
    if (brickRate != null) rates['brick'] = brickRate!;
    if (cementRate != null) rates['cement'] = cementRate!;
    if (sandRate != null) rates['sand'] = sandRate!;
    if (aggregateRate != null) rates['aggregate'] = aggregateRate!;
    if (steelRate != null) rates['steel'] = steelRate!;
    if (tileRate != null) rates['tile'] = tileRate!;
    if (paintRate != null) rates['paint'] = paintRate!;
    return rates;
  }
}
