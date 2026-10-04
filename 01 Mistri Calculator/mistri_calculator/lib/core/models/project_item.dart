import 'dart:convert';

import '../utils/purchase.dart';

/// One house (or one customer's job). A mason runs several at a time.
class Project {
  /// The first project every install starts with.
  static const String defaultId = 'default';

  final String id;

  /// What the user called it. Empty until they name it — the screen then
  /// shows the translated "My House".
  final String name;

  const Project({required this.id, this.name = ''});

  String toJson() => jsonEncode({'id': id, 'name': name});

  static Project? tryParse(String source) {
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      return Project(id: map['id'] as String, name: map['name'] as String);
    } catch (_) {
      return null;
    }
  }
}

/// One saved calculation in "My House" — a wall, a slab, a room's paint.
class ProjectItem {
  /// Unique within the project; the time it was added.
  final String id;

  /// Which calculator it came from. Also the [AppStrings] key of its name, so
  /// the title follows the app language: brick, concrete, steel, plaster,
  /// tiles, paint.
  final String type;

  /// The inputs in one line — "10 × 10 ft · 9" · 1:6".
  final String detail;

  /// Exact (un-rounded) quantities, keyed by the [ProjectMaterial] constants.
  /// Rounding happens once, on the project total — two walls needing 7.3 and
  /// 4.4 bags need 12 bags together, not 8 + 5.
  final Map<String, double> materials;

  /// The user's own label — "bedroom wall". Empty until they give one.
  final String name;

  const ProjectItem({
    required this.id,
    required this.type,
    required this.detail,
    required this.materials,
    this.name = '',
  });

  ProjectItem renamed(String name) => ProjectItem(
    id: id,
    type: type,
    detail: detail,
    materials: materials,
    name: name,
  );

  factory ProjectItem.create({
    required String type,
    required String detail,
    required Map<String, double> materials,
  }) => ProjectItem(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    type: type,
    detail: detail,
    materials: materials,
  );

  String toJson() => jsonEncode({
    'id': id,
    'type': type,
    'detail': detail,
    'materials': materials,
    if (name.isNotEmpty) 'name': name,
  });

  /// Returns null for anything that is not a well-formed item, so one bad
  /// entry can never take the whole project down.
  static ProjectItem? tryParse(String source) {
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      return ProjectItem(
        id: map['id'] as String,
        type: map['type'] as String,
        detail: map['detail'] as String,
        materials: (map['materials'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        name: map['name'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Keys of [ProjectItem.materials].
class ProjectMaterial {
  const ProjectMaterial._();

  static const String bricks = 'bricks';
  static const String cementBags = 'cementBags';
  static const String sandCft = 'sandCft';
  static const String aggregateCft = 'aggregateCft';
  static const String steelKg = 'steelKg';
  static const String tiles = 'tiles';
  static const String tileBoxes = 'tileBoxes';
  static const String paintLitres = 'paintLitres';
  static const String excavationCft = 'excavationCft';
}

/// Everything the whole project needs, added up across its items.
class ProjectTotals {
  final Map<String, double> _sum;

  ProjectTotals(List<ProjectItem> items) : _sum = {} {
    for (final item in items) {
      item.materials.forEach((k, v) => _sum[k] = (_sum[k] ?? 0) + v);
    }
  }

  double _of(String key) => _sum[key] ?? 0;

  // Counted things are bought whole; steel and paint are weighed / poured.
  int get bricks => roundUpToBuy(_of(ProjectMaterial.bricks));
  int get cementBags => roundUpToBuy(_of(ProjectMaterial.cementBags));
  int get sandCft => roundUpToBuy(_of(ProjectMaterial.sandCft));
  int get aggregateCft => roundUpToBuy(_of(ProjectMaterial.aggregateCft));
  double get steelKg => _of(ProjectMaterial.steelKg);
  int get tiles => roundUpToBuy(_of(ProjectMaterial.tiles));
  int get tileBoxes => roundUpToBuy(_of(ProjectMaterial.tileBoxes));
  double get paintLitres => _of(ProjectMaterial.paintLitres);
  int get excavationCft => roundUpToBuy(_of(ProjectMaterial.excavationCft));

  /// Cost of each material that has a rate, keyed like `allRates`
  /// (brick, cement, sand, aggregate, steel, tile, paint).
  Map<String, double> costs(Map<String, double> rates) {
    final quantities = <String, double>{
      'brick': bricks / 1000, // rate is per 1000 bricks
      'cement': cementBags.toDouble(),
      'sand': sandCft.toDouble(),
      'aggregate': aggregateCft.toDouble(),
      'steel': steelKg,
      'tile': tileBoxes.toDouble(), // rate is per box
      'paint': paintLitres,
    };
    return {
      for (final e in quantities.entries)
        if (e.value > 0 && rates.containsKey(e.key))
          e.key: e.value * rates[e.key]!,
    };
  }
}
