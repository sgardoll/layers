import 'package:freezed_annotation/freezed_annotation.dart';

import 'layer.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    required String sourceImagePath,
    @Default([]) List<Layer> layers,
    required DateTime createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
