/// Subscription-driven device quota of an organization, as reported by the
/// backend alongside the device list (`{devices: [...], quota: {used, limit}}`).
///
/// A negative [limit] mirrors `SubscriptionPlan.maxDevices`'s convention for
/// the Professional plan: no cap. Check [isUnlimited] instead of comparing
/// against [limit] directly.
class DeviceQuota {
  final int used;
  final int limit;

  const DeviceQuota({required this.used, required this.limit});

  bool get isUnlimited => limit < 0;

  bool get reached => !isUnlimited && used >= limit;
}
