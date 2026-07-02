import 'package:cocina360/features/processes/domain/model/control_process.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `ControlProcessResponse` into [ControlProcess].
class ControlProcessDto {
  final String id;
  final String organizationId;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  const ControlProcessDto({
    required this.id,
    required this.organizationId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory ControlProcessDto.fromJson(JSON json) {
    return ControlProcessDto(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  ControlProcess toDomain() {
    return ControlProcess(
      id: id,
      organizationId: organizationId,
      name: name,
      createdAt: DateTime.tryParse(createdAt ?? ''),
      updatedAt: DateTime.tryParse(updatedAt ?? ''),
    );
  }
}
