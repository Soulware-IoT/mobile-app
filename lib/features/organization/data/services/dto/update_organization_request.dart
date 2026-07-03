import 'package:cocina360/shared/data/types/json.dart';

/// Body for `PATCH /organizations/{id}` (backend `UpdateOrganizationRequest`).
///
/// This is a full replace of `name`/`imageUrl`/`address`, not a partial patch:
/// the backend overwrites the address wholesale from whatever is sent (an
/// absent `address` wipes it to empty), so callers must always pass the
/// organization's current values for fields the user didn't edit. The address
/// nests under `address: {lineOne, lineTwo, reference}`.
class UpdateOrganizationRequest {
  final String name;
  final String? imageUrl;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? addressReference;

  const UpdateOrganizationRequest({
    required this.name,
    this.imageUrl,
    this.addressLineOne,
    this.addressLineTwo,
    this.addressReference,
  });

  JSON toJson() => {
    'name': name,
    'imageUrl': imageUrl,
    'address': {
      'lineOne': addressLineOne,
      'lineTwo': addressLineTwo,
      'reference': addressReference,
    },
  };
}
