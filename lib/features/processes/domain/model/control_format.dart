import 'package:cocina360/features/processes/domain/model/control_format_status.dart';

/// The data type a format field captures.
enum FieldType { text, number, boolean, date, select }

FieldType fieldTypeFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'NUMBER':
      return FieldType.number;
    case 'BOOLEAN':
      return FieldType.boolean;
    case 'DATE':
      return FieldType.date;
    case 'SELECT':
      return FieldType.select;
    default:
      return FieldType.text;
  }
}

/// Validation rules of a field, discriminated by [kind] on the wire
/// (`none | text | number | select`). Only the members matching the kind are
/// populated; the rest stay null/empty.
class ValidationRules {
  final String kind;

  // kind == 'text'
  final int? minLength;
  final int? maxLength;
  final String? pattern;

  // kind == 'number' — numberKind is INTEGER or DECIMAL.
  final String? numberKind;
  final double? min;
  final double? max;

  // kind == 'select'
  final List<String> options;

  const ValidationRules({
    this.kind = 'none',
    this.minLength,
    this.maxLength,
    this.pattern,
    this.numberKind,
    this.min,
    this.max,
    this.options = const [],
  });

  bool get integerOnly => numberKind?.toUpperCase() == 'INTEGER';
}

/// One field of a format's structure. The [key] is server-owned (derived from
/// the label) and is the key under which values live in a registry's data map.
class FormatField {
  final String id;
  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final int displayOrder;
  final ValidationRules validationRules;

  const FormatField({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.displayOrder,
    required this.validationRules,
  });
}

/// A document template of a control process: a named, versioned-by-lifecycle
/// set of fields that gets filled into registries.
class ControlFormat {
  final String id;
  final String processId;
  final String name;
  final ControlFormatStatus status;
  final List<FormatField> fields;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ControlFormat({
    required this.id,
    required this.processId,
    required this.name,
    required this.status,
    required this.fields,
    this.createdAt,
    this.updatedAt,
  });

  /// Fields in their configured display order.
  List<FormatField> get orderedFields {
    final sorted = [...fields]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return sorted;
  }
}
