/// Lifecycle status of a device, as reported by the backend (UPPERCASE in REST).
enum DeviceStatus {
  provisioned,
  active,
  inactive;

  /// Spanish label for the status pill.
  String get label => switch (this) {
    DeviceStatus.provisioned => 'Aprovisionado',
    DeviceStatus.active => 'Activo',
    DeviceStatus.inactive => 'Inactivo',
  };
}

/// Parses the backend status (case-insensitive). Unknown values fall back to
/// [DeviceStatus.inactive] so the UI degrades gracefully.
DeviceStatus deviceStatusFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'PROVISIONED':
      return DeviceStatus.provisioned;
    case 'ACTIVE':
      return DeviceStatus.active;
    case 'INACTIVE':
      return DeviceStatus.inactive;
    default:
      return DeviceStatus.inactive;
  }
}
