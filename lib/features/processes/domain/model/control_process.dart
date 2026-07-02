/// An internal-control process of an organization (e.g. "Daily Safety
/// Checklist"). Formats (document templates) hang from it.
class ControlProcess {
  final String id;
  final String organizationId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ControlProcess({
    required this.id,
    required this.organizationId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
}
