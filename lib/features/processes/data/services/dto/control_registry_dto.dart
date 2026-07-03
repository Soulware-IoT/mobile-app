import 'package:cocina360/features/processes/domain/model/control_registry.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `ControlRegistryResponse` into [ControlRegistry].
class ControlRegistryDto {
  final String id;
  final String formatId;
  final Map<String, Object?> data;
  final String? createdAt;

  const ControlRegistryDto({
    required this.id,
    required this.formatId,
    required this.data,
    this.createdAt,
  });

  factory ControlRegistryDto.fromJson(JSON json) {
    return ControlRegistryDto(
      id: json['id'] as String,
      formatId: json['formatId'] as String,
      data: Map<String, Object?>.from(json['data'] as Map? ?? const {}),
      createdAt: json['createdAt'] as String?,
    );
  }

  ControlRegistry toDomain() {
    return ControlRegistry(
      id: id,
      formatId: formatId,
      data: data,
      createdAt: DateTime.tryParse(createdAt ?? ''),
    );
  }
}
