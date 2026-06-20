import 'package:cocina360/shared/data/types/json.dart';

/// Body for `PATCH /organizations/{id}` (backend `UpdateOrganizationRequest`).
///
/// `name` is required; the other fields are sent as-is — unedited values
/// (`imageUrl`, `addressLineTwo`) are forwarded unchanged so the PATCH does not
/// wipe them.
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
    'addressLineOne': addressLineOne,
    'addressLineTwo': addressLineTwo,
    'addressReference': addressReference,
  };
}
