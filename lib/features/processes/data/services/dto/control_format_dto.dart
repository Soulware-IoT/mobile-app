import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_format_status.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `ControlFormatResponse` (format + fields + validation
/// rules) into [ControlFormat].
class ControlFormatDto {
  final String id;
  final String processId;
  final String name;
  final String? status;
  final List<JSON> fields;
  final String? createdAt;
  final String? updatedAt;

  const ControlFormatDto({
    required this.id,
    required this.processId,
    required this.name,
    required this.status,
    required this.fields,
    this.createdAt,
    this.updatedAt,
  });

  factory ControlFormatDto.fromJson(JSON json) {
    return ControlFormatDto(
      id: json['id'] as String,
      processId: json['processId'] as String,
      name: json['name'] as String,
      status: json['status'] as String?,
      fields: (json['fields'] as List? ?? const []).cast<JSON>(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  ControlFormat toDomain() {
    return ControlFormat(
      id: id,
      processId: processId,
      name: name,
      status: controlFormatStatusFromString(status),
      fields: fields.map(_fieldFromJson).toList(),
      createdAt: DateTime.tryParse(createdAt ?? ''),
      updatedAt: DateTime.tryParse(updatedAt ?? ''),
    );
  }

  static FormatField _fieldFromJson(JSON json) {
    return FormatField(
      id: json['id'] as String,
      key: json['key'] as String,
      label: json['label'] as String,
      type: fieldTypeFromString(json['type'] as String?),
      required: json['required'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      validationRules: _rulesFromJson(json['validationRules'] as JSON?),
    );
  }

  /// The wire shape is discriminated by `kind` (none | text | number | select).
  static ValidationRules _rulesFromJson(JSON? json) {
    if (json == null) return const ValidationRules();
    return ValidationRules(
      kind: (json['kind'] as String?) ?? 'none',
      minLength: (json['minLength'] as num?)?.toInt(),
      maxLength: (json['maxLength'] as num?)?.toInt(),
      pattern: json['pattern'] as String?,
      numberKind: json['numberKind'] as String?,
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      options:
          (json['options'] as List? ?? const []).map((o) => '$o').toList(),
    );
  }
}
