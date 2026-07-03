import 'package:cocina360/shared/data/types/json.dart';

/// Body for `POST /organizations` (backend `CreateOrganizationRequest`).
///
/// `name` is the only required field. The address nests under
/// `address: {lineOne, lineTwo, reference}`, matching the backend contract.
class CreateOrganizationRequest {
  final String name;
  final String? imageUrl;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? addressReference;

  const CreateOrganizationRequest({
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
