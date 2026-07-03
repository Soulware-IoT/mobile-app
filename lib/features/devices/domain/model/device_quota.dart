/// Subscription-driven device quota of an organization, as reported by the
/// backend alongside the device list (`{devices: [...], quota: {used, limit}}`).
class DeviceQuota {
  final int used;
  final int limit;

  const DeviceQuota({required this.used, required this.limit});

  bool get reached => used >= limit;
}
