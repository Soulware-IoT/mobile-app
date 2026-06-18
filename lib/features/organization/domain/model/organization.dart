class Organization {
  final String id;
  final String name;
  final String? imageUrl;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? addressReference;
  final String? ownedBy;

  const Organization({
    required this.id,
    required this.name,
    this.imageUrl,
    this.addressLineOne,
    this.addressLineTwo,
    this.addressReference,
    this.ownedBy,
  });

  /// Single-line address built from the two address lines, for the header card.
  String get addressLine {
    final parts = [
      addressLineOne,
      addressLineTwo,
    ].where((p) => p != null && p.trim().isNotEmpty).cast<String>();
    return parts.join(', ');
  }
}
