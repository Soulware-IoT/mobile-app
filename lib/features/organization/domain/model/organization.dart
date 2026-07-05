/// The organization's owner, embedded on `OrganizationResponse.owner`
/// (a `ProfileSummary`) so callers don't need a separate profile fetch.
class OrganizationOwner {
  final String fullName;
  final String email;
  final String? avatarUrl;

  const OrganizationOwner({
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });
}

class Organization {
  final String id;
  final String name;
  final String? imageUrl;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? addressReference;
  final String? ownedBy;
  final OrganizationOwner? owner;

  const Organization({
    required this.id,
    required this.name,
    this.imageUrl,
    this.addressLineOne,
    this.addressLineTwo,
    this.addressReference,
    this.ownedBy,
    this.owner,
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
