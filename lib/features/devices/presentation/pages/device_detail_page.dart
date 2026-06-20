import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_state.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_badge.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Read-only detail of an IoT device. Shows the device passed via `extra`
/// immediately, then refreshes it through `GET /iot-devices/{id}`.
class DeviceDetailPage extends StatefulWidget {
  final IotDevice device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceDetailCubit>().load(
        widget.device.organizationId,
        widget.device.deviceId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: BlocBuilder<DeviceDetailCubit, DeviceDetailState>(
        builder: (context, state) {
          // Fall back to the device handed in via `extra` while the refresh is
          // in flight, so the screen is never blank.
          final device = switch (state) {
            DeviceDetailLoaded(:final device) => device,
            _ => widget.device,
          };

          if (state is DeviceDetailError) {
            return _ErrorView(
              message: localizedError(context, state.error),
              onRetry: () => context.read<DeviceDetailCubit>().load(
                widget.device.organizationId,
                widget.device.deviceId,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _HeaderCard(device: device),
              const SizedBox(height: 16),
              _ThresholdsCard(device: device),
              const SizedBox(height: 16),
              _MetadataCard(device: device),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final IotDevice device;

  const _HeaderCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Card(
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sensors, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.code,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          DeviceStatusBadge(status: device.status),
        ],
      ),
    );
  }
}

class _ThresholdsCard extends StatelessWidget {
  final IotDevice device;

  const _ThresholdsCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final t = device.thresholds;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Umbrales'),
          const SizedBox(height: 12),
          if (t.isEmpty)
            const Text('Sin umbrales configurados')
          else ...[
            _Row(label: 'Temp. aviso', value: _temp(t.warnTemperatureC)),
            _Row(label: 'Temp. crítica', value: _temp(t.critTemperatureC)),
            _Row(label: 'Gas aviso', value: _gas(t.warnGasPpm)),
            _Row(label: 'Gas crítico', value: _gas(t.critGasPpm)),
          ],
        ],
      ),
    );
  }

  String _temp(int? v) => v == null ? '—' : '$v °C';
  String _gas(double? v) => v == null ? '—' : '$v ppm';
}

class _MetadataCard extends StatelessWidget {
  final IotDevice device;

  const _MetadataCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Información'),
          const SizedBox(height: 12),
          _Row(label: 'Estado', value: device.status.label),
          _Row(label: 'Creado', value: _date(device.createdAt)),
          _Row(label: 'Actualizado', value: _date(device.updatedAt)),
        ],
      ),
    );
  }

  String _date(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}

Widget _sectionTitle(BuildContext context, String text) => Text(
  text,
  style: Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
);

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
