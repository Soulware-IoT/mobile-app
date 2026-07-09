import 'package:flutter/material.dart';
import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';

/// Vertical device list for the Live Readings page: one row per IoT device
/// with a presence dot (green online / red offline / grey no-signal) and a
/// highlight tint on the selected row.
class LiveDeviceSelector extends StatelessWidget {
  final List<IotDevice> devices;
  final Map<String, DevicePresence> presenceByDevice;
  final String? selectedDeviceId;
  final ValueChanged<String> onSelect;

  const LiveDeviceSelector({
    super.key,
    required this.devices,
    required this.presenceByDevice,
    required this.selectedDeviceId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          for (final (index, device) in devices.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
            _DeviceRow(
              device: device,
              presence: presenceByDevice[device.deviceId],
              selected: device.deviceId == selectedDeviceId,
              onTap: () => onSelect(device.deviceId),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final IotDevice device;
  final DevicePresence? presence;
  final bool selected;
  final VoidCallback onTap;

  const _DeviceRow({
    required this.device,
    required this.presence,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = switch (presence) {
      DevicePresence(online: true) => const Color(0xFF1B7A3D),
      DevicePresence(online: false) => const Color(0xFF9A2530),
      null => const Color(0xFF5A6470),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    device.code,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
