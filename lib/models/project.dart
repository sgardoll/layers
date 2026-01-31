import 'package:flutter/foundation.dart';
import 'package:layers/models/layer.dart';

/// App project model.
///
/// This is intentionally implemented without code generation (freezed/json
/// serializable) so the project can build reliably in environments where build
/// runner outputs are not present.
@immutable
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.sourceImagePath,
    this.status = 'queued',
    this.layers = const <Layer>[],
    required this.createdAt,
    this.updatedAt,
    this.settings,
  });

  final String id;
  final String name;
  final String sourceImagePath;
  final String status;
  final List<Layer> layers;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? settings;

  Project copyWith({
    String? id,
    String? name,
    String? sourceImagePath,
    String? status,
    List<Layer>? layers,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      status: status ?? this.status,
      layers: layers ?? this.layers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  static Project fromJson(Map<String, dynamic> json) {
    final rawLayers = json['layers'];
    final layers = (rawLayers is List)
        ? rawLayers
            .whereType<Map>()
            .map((e) => Layer.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <Layer>[];

    return Project(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sourceImagePath: (json['sourceImagePath'] ?? '').toString(),
      status: (json['status'] ?? 'queued').toString(),
      layers: layers,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
      settings: json['settings'] is Map
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'sourceImagePath': sourceImagePath,
        'status': status,
        'layers': layers.map((l) => l.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'settings': settings,
      };
}
