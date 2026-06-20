/// Safety thresholds configured for an IoT device. All fields are optional: a
/// freshly-provisioned device may have none configured yet.
class Thresholds {
  final int? warnTemperatureC;
  final int? critTemperatureC;
  final double? warnGasPpm;
  final double? critGasPpm;

  const Thresholds({
    this.warnTemperatureC,
    this.critTemperatureC,
    this.warnGasPpm,
    this.critGasPpm,
  });

  /// True when no threshold is configured (nothing to show).
  bool get isEmpty =>
      warnTemperatureC == null &&
      critTemperatureC == null &&
      warnGasPpm == null &&
      critGasPpm == null;
}
