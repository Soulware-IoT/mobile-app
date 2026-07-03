/// A filled record of a control format — one row of the "recent logs" list.
/// [data] is keyed by the format's field keys.
class ControlRegistry {
  final String id;
  final String formatId;
  final Map<String, Object?> data;
  final DateTime? createdAt;

  const ControlRegistry({
    required this.id,
    required this.formatId,
    required this.data,
    this.createdAt,
  });
}
